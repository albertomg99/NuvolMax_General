
@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string 

@description('Switch to enable/disable BGP Propagation on route table. Default: false')
param parDisableBgpRoutePropagation bool 

@description('Id of the DdosProtectionPlan which will be applied to the Virtual Network.  Default: Empty String')
param parDdosProtectionPlanId string 

@description('The IP address range for all virtual networks to use. Default: 10.11.0.0/16')
param parSpokeNetworkAddressPrefix string 

@description('The Name of the Spoke Virtual Network. Default: vnet-spoke')
param parSpokeNetworkName string 

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDnsServerIpsSpk array = []

@description('The name and IP address range for each subnet in the virtual networks Spoke.')
param parSubnetsspk array = []

@description('IP Address where network traffic should route to leveraged with DNS Proxy. Default: Empty String')
param parNextHopIpAddress string = ''

@description('Name of Route table to create for the default route of Hub. Default: rtb-spoke-to-hub')
param parSpokeToHubRouteTableName string 

@description('Tags you would like to be applied to all resources in this module. Default: Empty Object')
param parTags object = {}


var varSubnetProperties = [for subnet in parSubnetsspk: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange

  }
}]

//If Ddos parameter is true Ddos will be Enabled on the Virtual Network
//If Azure Firewall is enabled and Network DNS Proxy is enabled DNS will be configured to point to AzureFirewall
resource resSpokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: parSpokeNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parSpokeNetworkAddressPrefix
      ]
    }
    subnets: varSubnetProperties
    enableDdosProtection: (!empty(parDdosProtectionPlanId) ? true : false)
    ddosProtectionPlan: (!empty(parDdosProtectionPlanId) ? true : false) ? {
      id: parDdosProtectionPlanId
    } : null
    dhcpOptions: (!empty(parDnsServerIpsSpk) ? true : false) ? {
      dnsServers: parDnsServerIpsSpk
    } : null
  }
}




resource resSpokeToHubRouteTable 'Microsoft.Network/routeTables@2021-08-01' = if (!empty(parNextHopIpAddress)) {
  name: parSpokeToHubRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    routes: [
      {
        name: 'udr-default-to-hub-nva'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parNextHopIpAddress
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
}



output outSpokeVirtualNetworkName string = resSpokeVirtualNetwork.name
output outSpokeVirtualNetworkId string = resSpokeVirtualNetwork.id

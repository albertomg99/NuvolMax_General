@description('The Azure Region to deploy the resources into. Default: resourceGroup().location')
param parLocation string 


@description('Prefix Used for Hub Network. Default: {parCompanyPrefix}-hub-{parLocation}')
param parHubNetworkName string 

@description('The IP address range for all virtual networks to use. Default: 10.10.0.0/16')
param parHubNetworkAddressPrefix string 

@description('The name and IP address range for each subnet in the virtual networks. Default: AzureBastionSubnet, GatewaySubnet, AzureFirewall Subnet')
param parSubnetshub array = []

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDnsServerIpsHub array = []

@description('Public IP Address SKU. Default: Standard')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIpSku string

@description('Switch to enable/disable Azure Bastion deployment. Default: true')
param parAzBastionEnabled bool

@description('Name Associated with Bastion Service:  Default: {parCompanyPrefix}-bastion')
param parAzBastionName string 

@description('Azure Bastion SKU or Tier to deploy.  Currently two options exist Basic and Standard. Default: Standard')
param parAzBastionSku string 

@description('NSG Name for Azure Bastion Subnet NSG. Default: nsg-AzureBastionSubnet')
param parAzBastionNsgName string 

@description('Switch to enable/disable DDoS Standard deployment. Default: true')
param parDdosEnabled bool 

@description('DDoS Plan Name. Default: {parCompanyPrefix}-ddos-plan')
param parDdosPlanName string 

@description('Switch to enable/disable Azure Firewall deployment. Default: true')
param parAzFirewallEnabled bool 

@description('Azure Firewall Name. Default: {parCompanyPrefix}-azure-firewall ')
param parAzFirewallName string 

@description('Azure Firewall Policies Name. Default: {parCompanyPrefix}-fwpol-{parLocation}')
param parAzFirewallPoliciesName string 

@description('Azure Firewall Tier associated with the Firewall to deploy. Default: Standard ')
@allowed([
  'Standard'
  'Premium'
])
param parAzFirewallTier string 

@allowed([
  '1'
  '2'
  '3'
])
@description('Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAzFirewallAvailabilityZones array = []

@description('Switch to enable/disable Azure Firewall DNS Proxy. Default: true')
param parAzFirewallDnsProxyEnabled bool

@description('Name of Route table to create for the default route of Hub. Default: {parCompanyPrefix}-hub-routetable')
param parHubRouteTableName string 

@description('Switch to enable/disable BGP Propagation on route table. Default: false')
param parDisableBgpRoutePropagation bool 

//ASN must be 65515 if deploying VPN & ER for co-existence to work: https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager#limits-and-limitations
@description('''Configuration for VPN virtual network gateway to be deployed. If a VPN virtual network gateway is not desired an empty object should be used as the input parameter in the parameter file, i.e. 
"parVpnGatewayConfig": {
  "value": {}
}''')
param parVpnGatewayConfig object = {}



@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}


var varSubnetProperties = [for subnet in parSubnetshub: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
    networkSecurityGroup: subnet.name != 'AzureBastionSubnet' ? null : {
      id: '${resourceGroup().id}/providers/Microsoft.Network/networkSecurityGroups/${parAzBastionNsgName}'
    }
  }
}]

var varVpnGwConfig = ((!empty(parVpnGatewayConfig)) ? parVpnGatewayConfig : json('{"name": "noconfigVpn"}'))



var varGwConfig = [
  varVpnGwConfig
  
]

resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-08-01' = if (parDdosEnabled) {
  name: parDdosPlanName
  location: parLocation
  tags: parTags
}

//DDos Protection plan will only be enabled if parDdosEnabled is true.  
resource resHubVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  dependsOn: [
    resBastionNsg
  ]
  name: parHubNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: parDnsServerIpsHub
    }
    subnets: varSubnetProperties
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan: (parDdosEnabled) ? {
      id: resDdosProtectionPlan.id
    } : null
  }
}

module modBastionPublicIp './alz.dev.PublicIP.bicep' = if (parAzBastionEnabled) {
  name: 'deploy-Bastion-Public-IP'
  params: {
    parLocation: parLocation
    parPublicIpName: '${parAzBastionName}-PublicIp'
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parTags: parTags
    
  }
}

resource resBastionSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  parent: resHubVnet
  name: 'AzureBastionSubnet'
}

resource resBastionNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: parAzBastionNsgName
  location: parLocation
  tags: parTags

  properties: {
    securityRules: [
      // Inbound Rules
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 130
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 140
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 150
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      // Outbound Rules
      {
        name: 'AllowSshRDPOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 100
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 110
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 120
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 130
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

// AzureBastionSubnet is required to deploy Bastion service. This subnet must exist in the parsubnets array if you enable Bastion Service.
// There is a minimum subnet requirement of /27 prefix.  
// If you are deploying standard this needs to be larger. https://docs.microsoft.com/en-us/azure/bastion/configuration-settings#subnet
resource resBastion 'Microsoft.Network/bastionHosts@2021-08-01' = if (parAzBastionEnabled) {
  location: parLocation
  name: parAzBastionName
  tags: parTags
  sku: {
    name: parAzBastionSku
  }
  properties: {
    dnsName: uniqueString(resourceGroup().id)
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: resBastionSubnetRef.id
          }
          publicIPAddress: {
            id: parAzBastionEnabled ? modBastionPublicIp.outputs.outPublicIpId : ''
          }
        }
      }
    ]
  }
}

resource resGatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  parent: resHubVnet
  name: 'GatewaySubnet'
}

module modGatewayPublicIp './alz.dev.PublicIP.bicep' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
  name: 'deploy-Gateway-Public-IP-${i}'
  params: {
    parLocation: parLocation
    parPublicIpName: '${gateway.name}-PublicIp'
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parTags: parTags
    
  }
}]

//Minumum subnet size is /27 supporting documentation https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub
//Desplegamos el VPN Gateway
resource resGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = [for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
  name: gateway.name
  location: parLocation
  tags: parTags
  properties: {
    activeActive: gateway.activeActive
    enableBgp: gateway.enableBgp
    enableBgpRouteTranslationForNat: gateway.enableBgpRouteTranslationForNat
    enableDnsForwarding: gateway.enableDnsForwarding
    bgpSettings: (gateway.enableBgp) ? gateway.bgpSettings : null
    gatewayType: gateway.gatewayType
    vpnGatewayGeneration: (gateway.gatewayType == 'VPN') ? gateway.generation : 'None'
    vpnType: gateway.vpnType
    sku: {
      name: gateway.sku
      tier: gateway.sku
    }
    ipConfigurations: [
      {
        id: resHubVnet.id
        name: 'vnetGatewayConfig'
        properties: {
          publicIPAddress: {
            id: (((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) ? modGatewayPublicIp[i].outputs.outPublicIpId : 'na')
          }
          subnet: {
            id: resGatewaySubnetRef.id
          }
        }
      }
    ]
  }
}]

resource resAzureFirewallSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  parent: resHubVnet
  name: 'AzureFirewallSubnet'
}

module modAzureFirewallPublicIp './alz.dev.PublicIP.bicep' = if (parAzFirewallEnabled) {
  name: 'deploy-Firewall-Public-IP'
  params: {
    parLocation: parLocation
    parAvailabilityZones: parAzFirewallAvailabilityZones
    parPublicIpName: '${parAzFirewallName}-PublicIp'
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parTags: parTags
    
  }
}

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2021-08-01' = if (parAzFirewallEnabled) {
  name: parAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: {
    dnsSettings: {
      enableProxy: parAzFirewallDnsProxyEnabled
    }
    sku: {
      tier: parAzFirewallTier
    }
  }
}

// AzureFirewallSubnet is required to deploy Azure Firewall . This subnet must exist in the parsubnets array if you deploy.
// There is a minimum subnet requirement of /26 prefix.  
resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2021-08-01' = if (parAzFirewallEnabled) {
  name: parAzFirewallName
  location: parLocation
  tags: parTags
  zones: (!empty(parAzFirewallAvailabilityZones) ? parAzFirewallAvailabilityZones : json('null'))
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resAzureFirewallSubnetRef.id
          }
          publicIPAddress: {
            id: parAzFirewallEnabled ? modAzureFirewallPublicIp.outputs.outPublicIpId : ''
          }
        }
      }
    ]
    sku: {
      name: 'AZFW_VNet'
      tier: parAzFirewallTier
    }
    firewallPolicy: {
      id: resFirewallPolicies.id
    }
  }
}

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
resource resHubRouteTable 'Microsoft.Network/routeTables@2021-08-01' = if (parAzFirewallEnabled) {
  name: parHubRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    routes: [
      {
        name: 'udr-default-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parAzFirewallEnabled ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
}



//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallPrivateIp string = parAzFirewallEnabled ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallName string = parAzFirewallEnabled ? parAzFirewallName : ''


output outDdosPlanResourceId string = resDdosProtectionPlan.id
output outHubVirtualNetworkName string = resHubVnet.name
output outHubVirtualNetworkId string = resHubVnet.id

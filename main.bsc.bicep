//Param deployment_location string = deployment().location
param currentDateTime string = utcNow()

//Param grupo de recursos Grupos de Recursos

@description('Location Resource Groups')
param parLocation string

@description('Nombre de los Resource Groups')
param rg_p_hub_networking_01_name string
param rg_p_spk_networking_01_name string
param rg_p_log_analitics_01_name string  

@description('Tags de los Resource Groups')
param parTagsHub object
param parTagsSpk object
param parTagsLogAnalitics object
param parTagsLarule01 object
param parTagsLarule02 object


// Definicion de Jerarquia de Management Group

@description('Nivel 1 Management Group')
param tier1MgmtGroups array = []

@description('Nivel 2 Management Group')
param tier2MgmtGroups array = []

@description('Nivel 3 Management Group')
param tier3MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool

@description('ID de la Subscripción que queremos mover al defaul Management Group')
param subscripcionid string 

//Parametros relacionado con el Networking del Hub

@description('Prefix Used for Hub Network. Default: {parCompanyPrefix}-hub-{parLocation}')
param parHubNetworkName string 

@description('The IP address range for all virtual networks to use. Default: 10.10.0.0/16')
param parHubNetworkAddressPrefix string 

@description('The name and IP address range for each subnet in the virtual networks. Default: AzureBastionSubnet, GatewaySubnet, AzureFirewall Subnet')
param parSubnetshub array = []

@description('The name and IP address range for each subnet in the virtual networks Spoke.')
param parSubnetsspk array = []

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDnsServerIpsHub array = []


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


param parAzFirewallTier string 

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


//Parametros relacionados con el spoke 01

@description('Id of the DdosProtectionPlan which will be applied to the Virtual Network.  Default: Empty String')
param parDdosProtectionPlanId string 

@description('The IP address range for all virtual networks to use. Default: 10.11.0.0/16')
param parSpokeNetworkAddressPrefix string 

@description('The Name of the Spoke Virtual Network. Default: vnet-spoke')
param parSpokeNetworkName string 

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDnsServerIpsSpk array = []

@description('Name of Route table to create for the default route of Hub. Default: rtb-spoke-to-hub')
param parSpokeToHubRouteTableName string 

//Parametros relacionados con el Peering Hub-Spoke

@description('Name of source Virtual Network we are peering. No default')
param parSourceVirtualNetworkName string

@description('Name of destination virtual network we are peering. No default')
param parDestinationVirtualNetworkName string

@description('Switch to enable/disable Virtual Network Access for the Network Peer. Default = true')
param parAllowVirtualNetworkAccess bool 

@description('Switch to enable/disable forwarded traffic for the Network Peer. Default = true')
param parAllowForwardedTraffic bool 

@description('Switch to enable/disable gateway transit for the Network Peer. Default = false')
param parAllowGatewayTransit bool

@description('Switch to enable/disable remote gateway for the Network Peer. Default = false')
param parUseRemoteGateways bool

//Parametros para las politicas
param policy01 object = {}
param policy02 object = {}
param policy03 object = {}
param allowedlocations array = []

//Parametros para la monitorización y Log Analitics
param parlaWorkspace_name string


param laalertrule01 object
param laalertrule02 object



// Nombres de los deployments

param deploy_alz_dev_mgmntgroup_hierarchy_name string = '${'deploy_alz_dev_mgmntgroup_hierarchy_'}${currentDateTime}'
param deploy_alz_dev_resourcegroups_name string = '${'deploy_alz_dev_resourcegroups_'}${currentDateTime}'
param deploy_alz_dev_networking_hub01_name string = '${'deploy_alz_dev_networking_hub01_'}${currentDateTime}'
param deploy_alz_dev_networking_spk01_name string = '${'deploy_alz_dev_networking_spk01_'}${currentDateTime}'
param deploy_alz_dev_peering_SpktoHub_name string = '${'deploy_alz_dev_peering_SpktoHub_'}${currentDateTime}'
param deploy_alz_dev_peering_HubtoSpk_name string = '${'deploy_alz_dev_peering_HubtoSpk_'}${currentDateTime}'
param deploy_alz_dev_policies_Name string = '${'deploy_alz_dev_policies_'}${currentDateTime}'
param deploy_alz_dev_monitoring_Name string = '${'deploy_alz_dev_monitoring_'}${currentDateTime}'

/*######################################################################################################################################*/

targetScope = 'subscription'


// Vamos lanzando los distintos deploys que van a conformoar nuestra arquitectura 

module deploy_alz_dev_mgmntgroup_hierarchy './modules/alz.dev.mgmntgroup.hierarchy.bicep' = {
  name: deploy_alz_dev_mgmntgroup_hierarchy_name
  scope: tenant() 
  params: {
    
    subscripcionid: subscripcionid
    tier1MgmtGroups: tier1MgmtGroups
    tier2MgmtGroups: tier2MgmtGroups
    tier3MgmtGroups: tier3MgmtGroups

    defaultMgId: defaultMgId
    authForNewMG: authForNewMG
    configMGSettings: configMGSettings
  }
}

module deploy_alz_dev_resourcegroups './modules/alz.dev.resourcegroups.bicep' = {
  name: deploy_alz_dev_resourcegroups_name
  
  params: {
    rg_p_hub_networking_01_name: rg_p_hub_networking_01_name
    rg_p_spk_networking_01_name: rg_p_spk_networking_01_name
    rg_p_log_analitics_01_name: rg_p_log_analitics_01_name
    parLocation: parLocation
    parTagsHub: parTagsHub
    parTagsSpk: parTagsSpk
    parTagsLogAnalitics: parTagsLogAnalitics
    
  }
}

module deploy_alz_dev_networking_hub01 './modules/alz.dev.networking.hub01.bicep' = {
  name: deploy_alz_dev_networking_hub01_name
  scope: resourceGroup(rg_p_hub_networking_01_name)
  params: {
    
   parLocation: parLocation
   parHubNetworkName:parHubNetworkName
   parHubNetworkAddressPrefix: parHubNetworkAddressPrefix
   parSubnetshub: parSubnetshub
   parDnsServerIpsHub: parDnsServerIpsHub
   parPublicIpSku: parPublicIpSku
   parAzBastionEnabled: parAzBastionEnabled
   parAzBastionName: parAzBastionName
   parAzBastionSku: parAzBastionSku
   parAzBastionNsgName: parAzBastionNsgName
   parDdosEnabled: parDdosEnabled
   parDdosPlanName: parDdosPlanName
   parAzFirewallAvailabilityZones: parAzFirewallAvailabilityZones
   parAzFirewallEnabled: parAzFirewallEnabled
   parAzFirewallName: parAzFirewallName
   parAzFirewallPoliciesName: parAzFirewallPoliciesName
   parAzFirewallTier: parAzFirewallTier
   parAzFirewallDnsProxyEnabled: parAzFirewallDnsProxyEnabled
   parHubRouteTableName: parHubRouteTableName
   parDisableBgpRoutePropagation: parDisableBgpRoutePropagation
   parVpnGatewayConfig: parVpnGatewayConfig
   
   
   }
   dependsOn:[
    deploy_alz_dev_resourcegroups
    ]
}


module deploy_alz_dev_networking_spk01 './modules/alz.dev.networking.spk01.bicep' = {
  name: deploy_alz_dev_networking_spk01_name
  scope: resourceGroup(rg_p_spk_networking_01_name)
  params: {
   parSubnetsspk:parSubnetsspk 
   parLocation: parLocation
   parSpokeNetworkName: parSpokeNetworkName
   parSpokeNetworkAddressPrefix: parSpokeNetworkAddressPrefix
   parDdosProtectionPlanId: parDdosProtectionPlanId
   parDnsServerIpsSpk: parDnsServerIpsSpk
   parDisableBgpRoutePropagation: parDisableBgpRoutePropagation
   parSpokeToHubRouteTableName: parSpokeToHubRouteTableName
   
   }
   dependsOn:[
    deploy_alz_dev_resourcegroups
    ]
}

module deploy_alz_peering_SpktoHub './modules/alz.dev.peeringsSpktoHub.bicep' = {
  name: deploy_alz_dev_peering_SpktoHub_name
  scope: resourceGroup(rg_p_spk_networking_01_name)
  params: {
    
    parSourceVirtualNetworkName: parSourceVirtualNetworkName
    parAllowForwardedTraffic: parAllowForwardedTraffic
    parAllowGatewayTransit: parAllowGatewayTransit
    parDestinationVirtualNetworkName: parDestinationVirtualNetworkName
    parAllowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    parUseRemoteGateways: parUseRemoteGateways
    parHubNetworkName: parHubNetworkName
    rg_p_hub_networking_01_name: rg_p_hub_networking_01_name

   }
   dependsOn:[
    deploy_alz_dev_resourcegroups
    deploy_alz_dev_networking_hub01
    deploy_alz_dev_networking_spk01

    ]
}

module deploy_alz_peering_HubtoSpk './modules/alz.dev.peeringsHubtoSpk.bicep' = {
  name: deploy_alz_dev_peering_HubtoSpk_name
  scope: resourceGroup(rg_p_hub_networking_01_name)
  params: {
    
    parSourceVirtualNetworkName: parSourceVirtualNetworkName
    parAllowForwardedTraffic: parAllowForwardedTraffic
    parAllowGatewayTransit: parAllowGatewayTransit
    parDestinationVirtualNetworkName: parDestinationVirtualNetworkName
    parAllowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    parUseRemoteGateways: parUseRemoteGateways
    parSpokeNetworkName: parSpokeNetworkName
    rg_p_spk_networking_01_name: rg_p_spk_networking_01_name

   }
   dependsOn:[
    deploy_alz_dev_resourcegroups
    deploy_alz_dev_networking_hub01
    deploy_alz_dev_networking_spk01

    ]
}


module deploy_alz_dev_policies './modules/alz.dev.policies.bicep' ={
  name: deploy_alz_dev_policies_Name 
    scope:subscription()
    params:{
    policy01: policy01
    policy02: policy02
    policy03: policy03
    allowedlocations:allowedlocations
        
  }
  dependsOn:[
  ]
}

// Deploy Azure Monitoring - Log Analitics
module deploy_alz_dev_monitoring './modules/alz.dev.monitoring.bicep' = {
  name: deploy_alz_dev_monitoring_Name 
  scope: resourceGroup(rg_p_log_analitics_01_name)
  params:{
  
  parlaWorkspace_name: parlaWorkspace_name
  laalertrule01:laalertrule01
  laalertrule02:laalertrule02
  location:parLocation
  parTagsLarule01:parTagsLarule01
  parTagsLarule02:parTagsLarule02
  
  }
  dependsOn:[
    deploy_alz_dev_resourcegroups
    deploy_alz_dev_networking_hub01
    deploy_alz_dev_networking_spk01
  ]
}

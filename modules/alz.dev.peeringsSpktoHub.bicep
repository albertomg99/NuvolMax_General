param parDestinationVirtualNetworkName string
param parSourceVirtualNetworkName string
param parAllowForwardedTraffic bool
param parAllowGatewayTransit bool
param parAllowVirtualNetworkAccess bool
param parUseRemoteGateways bool
param rg_p_hub_networking_01_name string
param parHubNetworkName string


/*######################################################################################################################################*/


// Importamos la VNET de destino del peering
resource resHubVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: parHubNetworkName
  scope: resourceGroup(rg_p_hub_networking_01_name)
}


// Vamos a crear un Peering Spk to Hub
resource res_networking_peering_spk_to_hub  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${parSourceVirtualNetworkName}/peer-to-${parDestinationVirtualNetworkName}'
  
  properties: {
    allowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    allowForwardedTraffic: parAllowForwardedTraffic
    allowGatewayTransit: parAllowGatewayTransit
    useRemoteGateways: parUseRemoteGateways
    remoteVirtualNetwork: {
      id: resHubVnet.id
    }
  }
  dependsOn:[

  ]
}

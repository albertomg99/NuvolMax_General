param parDestinationVirtualNetworkName string
param parSourceVirtualNetworkName string
param parAllowForwardedTraffic bool
param parAllowGatewayTransit bool
param parAllowVirtualNetworkAccess bool
param parUseRemoteGateways bool
param rg_p_spk_networking_01_name string
param parSpokeNetworkName string

/*######################################################################################################################################*/

// Importamos la VNET de destino del peering

resource resSpkVnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: parSpokeNetworkName
  scope: resourceGroup(rg_p_spk_networking_01_name)
}

resource res_networking_peering_hub_to_spoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${parDestinationVirtualNetworkName}/peer-to-${parSourceVirtualNetworkName}'

  properties: {
    allowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    allowForwardedTraffic: parAllowForwardedTraffic
    allowGatewayTransit: parAllowGatewayTransit
    useRemoteGateways: parUseRemoteGateways
    remoteVirtualNetwork: {
      id: resSpkVnet.id
    }
  }
  dependsOn: []
}

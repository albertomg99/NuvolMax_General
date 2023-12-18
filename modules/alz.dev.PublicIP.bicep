@description('Azure Region to deploy Public IP Address to. Default: Current Resource Group')
param parLocation string = resourceGroup().location

@description('Name of Public IP to create in Azure. Default: None')
param parPublicIpName string

@description('Public IP Address SKU. Default: None')
param parPublicIpSku object

@description('Properties of Public IP to be deployed. Default: None')
param parPublicIpProperties object

@allowed([
  '1'
  '2'
  '3'
])
@description('Availability Zones to deploy the Public IP across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAvailabilityZones array = []

@description('Tags to be applied to resource when deployed.  Default: None')
param parTags object = {}


resource resPublicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' ={
  name: parPublicIpName
  tags: parTags
  location: parLocation
  zones: parAvailabilityZones
  sku: parPublicIpSku
  properties: parPublicIpProperties
}


output outPublicIpId string = resPublicIp.id

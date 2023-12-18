targetScope = 'subscription'

@description('Azure Region where Resource Group will be created.  No Default')
param parLocation string

@description('Name of Resource Group to be created.  No Default')

param rg_p_hub_networking_01_name string
param rg_p_spk_networking_01_name string
param rg_p_log_analitics_01_name string 

@description('Tags you would like to be applied to all resources in this module')
param parTagsHub object = {}
param parTagsSpk object = {}
param parTagsLogAnalitics object = {}



resource rg_p_hub_networking_01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name: rg_p_hub_networking_01_name
  tags: parTagsHub
}

resource rg_p_spk_networking_01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name: rg_p_spk_networking_01_name
  tags: parTagsSpk
}

resource rg_p_log_analitics_01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: parLocation
  name: rg_p_log_analitics_01_name
  tags: parTagsLogAnalitics
}

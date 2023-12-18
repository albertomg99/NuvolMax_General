

targetScope = 'tenant'

@description('Tier 1 management groups. Must contain id and displayName properties.')
param tier1MgmtGroups array = []

@description('Optional. Tier 2 management groups. Must contain id, displayName and ParentId properties.')
param tier2MgmtGroups array = []

@description('Optional. Tier 3 management groups. Must contain id, displayName and ParentId properties.')
param tier3MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool = false

@description('ID de la Subscripción que queremos mover al defaul Management Group')
param subscripcionid string 

var tenantRootMgId = tenant().tenantId

var allMgs = union(tier1MgmtGroups, tier2MgmtGroups, tier3MgmtGroups)

//Deploy tier 1 Mgmt Groups
@batchSize(1)
resource tier_1_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier1MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', tenantRootMgId)
      }
    }
  }
}]

//Deploy tier 2 Mgmt Groups
@batchSize(1)
resource tier_2_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier2MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_1_mgs
  ]
}]


//Deploy tier 3 Mgmt Groups
@batchSize(1)
resource tier_3_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier3MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_2_mgs
  ]
}]


resource mg_creation_auth 'Microsoft.Management/managementGroups/settings@2021-04-01' = if (configMGSettings) {
  name: '${tenantRootMgId}/default'
  properties: {
    requireAuthorizationForGroupCreation: authForNewMG
    defaultManagementGroup: empty(defaultMgId) ? null : tenantResourceId('Microsoft.Management/managementGroups', defaultMgId)
  }
  dependsOn: [
    tier_1_mgs
    tier_2_mgs
    tier_3_mgs
   ]
}

output managementGroups array = [for mg in allMgs: {
  id: tenantResourceId('Microsoft.Management/managementGroups', mg.id)
  displayName: mg.displayName
}]

output tier_1_mgs array = [for (mg, i) in tier1MgmtGroups: {
  id: tier_1_mgs[i].id
  displayName: tier_1_mgs[i].properties.displayName
  parentId: tier_1_mgs[i].properties.details.parent.id
}]

output tier_2_mgs array = [for (mg, i) in tier2MgmtGroups: {
  id: tier_2_mgs[i].id
  displayName: tier_2_mgs[i].properties.displayName
  parentId: tier_2_mgs[i].properties.details.parent.id
}]

output tier_3_mgs array = [for (mg, i) in tier3MgmtGroups: {
  id: tier_3_mgs[i].id
  displayName: tier_3_mgs[i].properties.displayName
  parentId: tier_3_mgs[i].properties.details.parent.id
}]


output root_mg_settings object = mg_creation_auth



resource subscripcionToManagementGroup 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  scope: tenant()
  name: '${defaultMgId}/${subscripcionid}'
    dependsOn: [
    tier_1_mgs
    tier_2_mgs
    tier_3_mgs
    mg_creation_auth
   ]
}

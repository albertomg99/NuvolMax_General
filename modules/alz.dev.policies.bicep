targetScope = 'subscription'

param policy01 object = {}
param policy02 object = {}
param policy03 object = {}
param allowedlocations array = [
  'northeurope'
  'westeurope'
]

resource policyAssignment01 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: policy01.name
  properties: {
    policyDefinitionId: policy01.definitionId
    description: policy01.description
    displayName: policy01.displayName
    parameters: {
      tagName: {
        value: 'cor-ctx-projectcode'
      }
      tagValue: {
        value: 'Basic Azure Landing'
      }
    }
  }
}

resource policyAssignment02 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: policy02.name
  properties: {
    policyDefinitionId: policy02.definitionId
    description: policy02.description
    displayName: policy02.displayName
    notScopes: []
  }
}

resource policyDefinition03 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: '${policy03.name}-Def'

  properties: {
    description: policy03.description
    displayName: '${policy03.displayName}-customDef'
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            //equals: 'Microsoft.Resources/subscriptions/resourceGroups'
            equals: 'Microsoft.Resources/resourceGroups'
          }
          {
            field: 'location'
            notIn: allowedlocations
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

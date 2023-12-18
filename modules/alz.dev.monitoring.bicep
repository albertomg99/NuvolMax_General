/*#############################           PARAMETROS           #######################################*/
param location string = resourceGroup().location


param parlaWorkspace_name string


param laalertrule01 object
param laalertrule02 object
param parTagsLarule01 object
param parTagsLarule02 object

var environmentName = 'Production'
var costCenterName = 'IT'

/*######################################################################################################################################*/





// Creamos el Log Analytics
resource res_alz_laWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: parlaWorkspace_name
  location: location
  tags: {
    Environment: environmentName
    CostCenter: costCenterName
  }
  properties: any({
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource azneu_s_laWorkspace_Diagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: res_alz_laWorkspace
  name: 'diagnosticSettings'
  properties: {
    workspaceId: res_alz_laWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}



// Creamos alertas del Log Analytics
resource azneu_s_la_alertrule01 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: laalertrule01.name
  location: 'global'
  tags: parTagsLarule01
  properties: {
    description: laalertrule01.description
    severity: 3
    enabled: true
    scopes: [
      //laalertrule01.la_id
      res_alz_laWorkspace.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 25
          name: 'Metric1'
          metricNamespace: 'Microsoft.OperationalInsights/workspaces'
          metricName: 'Average_% Free Space'
          operator: 'LessThan'
          timeAggregation: 'Minimum'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.OperationalInsights/workspaces'
    actions: []
  }
  dependsOn:[
    //res_laWorkspace_cesa
    azneu_s_laWorkspace_Diagnostics

  ]
}

resource azneu_s_la_alertrule02 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: laalertrule02.name
  location: 'global'
  tags: parTagsLarule02
  properties: {
    description: laalertrule02.description
    severity: 3
    enabled: true
    scopes: [
      //laalertrule02.la_id
      res_alz_laWorkspace.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 10
          name: 'Metric1'
          metricNamespace: 'Microsoft.OperationalInsights/workspaces'
          metricName: 'Average_% Available Memory'
          operator: 'LessThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.OperationalInsights/workspaces'
    actions: []
  }
  dependsOn:[
    //res_laWorkspace_cesa
    azneu_s_laWorkspace_Diagnostics

  ]
}



param location string
param spokeVnetName string
param spokeVnetCidr string
param controlPlaneSubnetCidr string
param computeSubnetCidr string
param tags object
param controlPlaneVnetName string
param computeVnetName string
param routeTableName string
param spoke_rg string

resource routeTable_resource 'Microsoft.Network/routeTables@2022-01-01' existing = {
  name: routeTableName
  scope: resourceGroup(spoke_rg)
}

resource cluster_vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: spokeVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetCidr
      ]
    }
    subnets: [
      {
        name: controlPlaneVnetName
        properties: {
          addressPrefix: controlPlaneSubnetCidr
          serviceEndpoints: [ { service: 'Microsoft.ContainerRegistry' } ]
          privateLinkServiceNetworkPolicies: 'Disabled'
          routeTable: {
            id: routeTable_resource.id
            location: location
          }
        }
      }
      {
        name: computeVnetName
        properties: {
          addressPrefix: computeSubnetCidr
          serviceEndpoints: [ { service: 'Microsoft.ContainerRegistry' } ]
          routeTable: {
            id: routeTable_resource.id
            location: location
          }
        }
      }
    ]
  }
  dependsOn: [
    routeTable_resource
  ]
}
//  Telemetry Deployment
@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true
var telemetryId = '69ef933a-eff0-450b-8a46-331cf62e160f-springmsaro-${location}'
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}

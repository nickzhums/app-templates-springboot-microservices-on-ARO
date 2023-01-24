@description('The name of the Azure Container Registry')
param acrName string

@description('The location to deploy the resources to')
param location string

@description('An array of fully qualified images names to import')
param images array

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
}

module acrImport 'br/public:deployment-scripts/import-acr:1.0.1' = {
  name: 'ImportAcrImages'
  params: {
    acrName: acr.name
    location: location
    images: images
  }
}

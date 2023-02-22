param location string
param spokeVnetName string
param spokeVnetCidr string
param controlPlaneSubnetCidr string
param computeSubnetCidr string
param aroSubnetCidr string
param tags object
param controlPlaneVnetName string
param computeVnetName string
param aroVnetName string


resource cluster_vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: spokeVnetName
  location: location
  tags: {
    tagName1: tags.env
    tagName2: tags.dept
  }
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
       }
      }
      {
        name: computeVnetName
        properties: {
          addressPrefix: computeSubnetCidr
        }
      }
      {
        name: aroVnetName
        properties: {
          addressPrefix: aroSubnetCidr
        }
      }
    ]
  }
  dependsOn: [
   
  ]
}

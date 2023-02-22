@secure()
param aadClientId string

@secure()
param aadClientSecret string

@secure()
param aadObjectId string

@secure()
param rpObjectId string

param location string
param clusterName string
param tags object
param domain string
param podCidr string
param serviceCidr string
param controlPlaneVmSize string
param computeVmSize string
param computeVmDiskSize int
param computeNodeCount int
param apiServerVisibility string
param ingressVisibility string
param spokeVnetName string
param controlPlaneVnetName string
param computeVnetName string
param fipsValidatedModules string
param encryptionAtHost string
param addSpRoleAssignment string
param clusterRG string
param version string
param url string
param provisioningState string
param apiurl string
param apip string
param ingressip string
@secure()
param pullSecret string 

var contribRole = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource clusterVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = { name: spokeVnetName }

resource role_for_aadObjectId 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSpRoleAssignment == 'yes') {
  name: guid(resourceGroup().id, aadObjectId, deployment().name)
  properties: {
    principalId: aadObjectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contribRole)
  }
  dependsOn: [
    clusterVnet
  ]
}

resource role_for_rpObjectId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, rpObjectId)
  properties: {
    principalId: rpObjectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contribRole)
  }
  dependsOn: [
    clusterVnet
  ]
}

resource aro 'Microsoft.RedHatOpenShift/openShiftClusters@2022-04-01' = {
  name: clusterName
  location: location
  tags: {
    tagName1: tags.env
    tagName2: tags.dept
  }
  properties: {
    apiserverProfile: {
      ip: apip
      url: apiurl
      visibility: apiServerVisibility
    }
    clusterProfile: {
      domain: domain
      fipsValidatedModules: fipsValidatedModules
      pullSecret: pullSecret
      resourceGroupId: clusterRG
      version: version
    }
    consoleProfile: {
      url: url
    }
    ingressProfiles: [
      {
        ip: ingressip
        name: 'default'
        visibility: ingressVisibility
      }
    ]
    masterProfile: {
     // diskEncryptionSetId: 'string'
      encryptionAtHost: encryptionAtHost
      subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVnetName, controlPlaneVnetName)
      vmSize: controlPlaneVmSize
    }
    networkProfile: {
      podCidr: podCidr
      serviceCidr: serviceCidr
    }
    provisioningState: provisioningState
    servicePrincipalProfile: {
      clientId: aadClientId
      clientSecret: aadClientSecret
    }
    workerProfiles: [
      {
        count: computeNodeCount
        //diskEncryptionSetId: 'string' 
        diskSizeGB: computeVmDiskSize
        encryptionAtHost: encryptionAtHost
        name: 'worker'
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVnetName, computeVnetName)
        vmSize: computeVmSize
      }
    ]
  }
}


param location string = resourceGroup().location

param VNetName string

param SubnetName string

param StorageName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param StorageSKU string


resource VNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: VNetName
  resource Subnet 'subnets' existing = {
    name: SubnetName
  }
}

resource Storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: StorageName
  location: location
  sku: {
    name: StorageSKU
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource StoragePe 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: '${StorageName}-PE'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${StorageName}-PE-Con'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: Storage.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: VNet::Subnet.id
    }
  }
}

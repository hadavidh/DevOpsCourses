param location string
param vmName string
param addressSpace array
param addressSubnet string
param adminUsername string
param adminUserpassword string

resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: { addressPrefixes: addressSpace }
    subnets: [
      {name: '${vmName}-subnet-default', properties: {addressPrefix: addressSubnet}}
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2025-01-01'= {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      { 
        name: '${vmName}-ipConfig'
        properties: { 
          privateIPAllocationMethod: 'Dynamic'
          subnet: {id: vnet.properties.subnets[0].id }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    storageProfile: {
      imageReference: {

        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminUserpassword
    }
    networkProfile: {
      networkInterfaces: [{ id: nic.id }]
    }
  }
}

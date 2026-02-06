targetScope = 'subscription'

param prefix string = 'demo-bicep'
param locations array = [
  'westeurope'
  'northeurope'
]

resource rgs 'Microsoft.Resources/resourceGroups@2025-04-01' = [for loc in locations: {
  name: '${prefix}-rg-${loc}'
  location: loc
}]

module vmDeployment './vm-stack.bicep' = [for(loc, i) in locations: {
  name: 'deploy-vm-${loc}'
  scope: rgs[i]
  params: {
    location: loc
    vmName: '${prefix}-vm-${loc}'
    addressSpace: ['10.0.0.0/16']
    addressSubnet: '10.0.1.0/24'
    adminUsername: 'flavian'
    adminUserpassword: 'Blop12345@'
  }
}]

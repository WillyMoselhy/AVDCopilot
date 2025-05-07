param Location string = resourceGroup().location
param ManagedIdentityName string = 'id-AVDCopilot-01'
param GetUserSessionLogicAppName string = 'logic-AVDGetUserSession-01'
param RemoveUserSessionLogicAppName string = 'logic-AVDRemoveUserSession-01'

@description('Location for all resources')

module ManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'deploy-${ManagedIdentityName}'
  params: {
    name: ManagedIdentityName
    location: Location

  }
}

module GetAVDUserSessions 'modules/deploy-AVDGetUserSessionLogicApp.bicep' = {
  name: 'deploy-AVDGetUserSessionLogicApp'
  params: {
    LogicAppName: GetUserSessionLogicAppName
    Location: Location
    userManagedIdentityId: ManagedIdentity.outputs.resourceId
  }
}

module RemoveAVDUserSession 'modules/deploy-AVDRemoveUserSessionLogicApp.bicep' = {
  name: 'deploy-AVDRemoveUserSessionLogicApp'
  params: {
    LogicAppName: RemoveUserSessionLogicAppName
    Location: Location
    userManagedIdentityId: ManagedIdentity.outputs.resourceId
  }
}

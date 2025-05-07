param LogicAppName string
param Location string = resourceGroup().location
param userManagedIdentityId string

module LogicApp 'br/public:avm/res/logic/workflow:0.5.1' = {
  name: 'deploy-module-AVDRemoveUserSessionLogicApp'
  params: {
    name: LogicAppName
    location: Location
    managedIdentities: {
      userAssignedResourceIds: [userManagedIdentityId]
    }
    workflowTriggers: {
      When_a_HTTP_request_is_received: {
        type: 'Request'
        kind: 'Http'
        inputs: {
          method: 'POST'
          schema: {
            type: 'object'
            properties: {
              SessionUri: {
                type: 'string'
              }
            }
          }
        }
      }
    }
    workflowActions: {
      HTTP: {
        runAfter: {}
        type: 'Http'
        inputs: {
          uri: '@triggerBody()?[\'SessionUri\']'
          method: 'DELETE'
          queries: {
            'api-version': '2024-04-03'
          }
          authentication: {
            type: 'ManagedServiceIdentity'
            identity: userManagedIdentityId
            audience: environment().resourceManager
          }
        }
        runtimeConfiguration: {
          contentTransfer: {
            transferMode: 'Chunked'
          }
        }
      }
      Response: {
        runAfter: {
          HTTP: [
            'Succeeded'
          ]
        }
        type: 'Response'
        kind: 'Http'
        inputs: {
          statusCode: '@outputs(\'HTTP\')?[\'statusCode\']'
        }
      }
    }
    workflowOutputs: {}
    workflowParameters: {
      '$connections': {
        defaultValue: {}
        type: 'Object'
      }
    }
  }
}

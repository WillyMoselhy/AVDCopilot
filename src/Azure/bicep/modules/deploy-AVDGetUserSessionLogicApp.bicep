param LogicAppName string
param Location string = resourceGroup().location
param userManagedIdentityId string

module LogicApp 'br/public:avm/res/logic/workflow:0.5.1' = {
  name: 'deploy-module-AVDGetUserSessionLogicApp'
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
              userPrincipalName: {
                type: 'string'
              }
            }
          }
        }
        operationOptions: 'EnableSchemaValidation'
      }
    }
    workflowActions: {
      Response: {
        runAfter: {
          For_each: [
            'Succeeded'
          ]
        }
        type: 'Response'
        kind: 'Http'
        inputs: {
          statusCode: 200
          body: '@variables(\'UserSessionsArray\')'
        }
      }
      Get_all_host_pools: {
        runAfter: {
          Initialize_variables: [
            'Succeeded'
          ]
        }
        type: 'Http'
        inputs: {
          uri: '${environment().resourceManager}providers/Microsoft.ResourceGraph/resources'
          method: 'POST'
          queries: {
            'api-version': '2024-04-01'
          }
          body: {
            query: 'resources | where type =~ "microsoft.desktopvirtualization/hostpools" | extend hostPoolType = properties.hostPoolType | project id, name, hostPoolType'
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
      Parse_Get_all_host_pools: {
        runAfter: {
          Get_all_host_pools: [
            'Succeeded'
          ]
        }
        type: 'ParseJson'
        inputs: {
          content: '@body(\'Get_all_host_pools\')'
          schema: {
            type: 'object'
            properties: {
              totalRecords: {
                type: 'integer'
              }
              count: {
                type: 'integer'
              }
              data: {
                type: 'array'
                items: {
                  type: 'object'
                  properties: {
                    id: {
                      type: 'string'
                    }
                    name: {
                      type: 'string'
                    }
                    hostPoolType: {
                      type: 'string'
                    }
                  }
                  required: [
                    'id'
                    'name'
                    'hostPoolType'
                  ]
                }
              }
              facets: {
                type: 'array'
              }
              resultTruncated: {
                type: 'string'
              }
            }
          }
        }
      }
      For_each: {
        foreach: '@outputs(\'Parse_Get_all_host_pools\')?[\'body\']?[\'data\']'
        actions: {
          Get_User_Sessions: {
            type: 'Http'
            inputs: {
              uri: '${environment().resourceManager}@{item()?[\'id\']}/userSessions'
              method: 'GET'
              queries: {
                'api-version': '2022-10-14-preview'
                '$filter': 'userPrincipalName eq \'@{triggerBody()?[\'userPrincipalName\']}\''
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
          value_is_null: {
            actions: {}
            runAfter: {
              Get_User_Sessions: [
                'Succeeded'
              ]
            }
            else: {
              actions: {
                Append_to_array_variable: {
                  runAfter: {
                    Compose: [
                      'Succeeded'
                    ]
                  }
                  type: 'AppendToArrayVariable'
                  inputs: {
                    name: 'UserSessionsArray'
                    value: '@outputs(\'Compose\')'
                  }
                }
                Compose: {
                  type: 'Compose'
                  inputs: {
                    SessionUri: '${environment().resourceManager}@{first(body(\'Get_User_Sessions\')?[\'value\'])?[\'id\']}'
                    createTime: '@{first(body(\'Get_User_Sessions\')?[\'value\'])?[\'properties\']?[\'createTime\']}'
                    sessionState: '@{first(body(\'Get_User_Sessions\')?[\'value\'])?[\'properties\']?[\'sessionState\']}'
                    sessionDuration: 'ForFutureUse'
                    DisplayName: '@{items(\'For_each\')?[\'name\']}'
                  }
                }
              }
            }
            expression: {
              and: [
                {
                  equals: [
                    '@empty(body(\'Get_User_Sessions\')[\'value\'])'
                    '@true'
                  ]
                }
              ]
            }
            type: 'If'
          }
        }
        runAfter: {
          Parse_Get_all_host_pools: [
            'Succeeded'
          ]
        }
        type: 'Foreach'
      }
      Initialize_variables: {
        runAfter: {}
        type: 'InitializeVariable'
        inputs: {
          variables: [
            {
              name: 'UserSessionsArray'
              type: 'array'
            }
          ]
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

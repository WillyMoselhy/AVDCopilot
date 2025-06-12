param (
    $Location = 'EastUS',
    $ResourceGroupName = 'AVDCopilot-LogicApps-RG',
    $ManagedIdentityName = 'id-AVDCopilot-01',
    $GetUserSessionLogicAppName = 'logic-AVDGetUserSession-01',
    $RemoveUserSessionLogicAppName = 'logic-AVDRemoveUserSession-01'
)

New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force

$paramNewAzResourceGroupDeployment = @{

    ResourceGroupName       = $ResourceGroupName
    TemplateFile            = ".\src\Azure\AVDCopilotLogicApps.bicep"
    TemplateParameterObject = @{
        Location                      = $Location
        ManagedIdentityName           = $ManagedIdentityName
        GetUserSessionLogicAppName    = $GetUserSessionLogicAppName
        RemoveUserSessionLogicAppName = $RemoveUserSessionLogicAppName
    }
    DeploymentName          = "AVDCopilotLogicApps"
    Location                = $Location
}
New-AzResourceGroupDeployment @paramNewAzResourceGroupDeployment
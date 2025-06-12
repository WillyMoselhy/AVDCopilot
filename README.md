### PURPOSE
The AVDCopilot allows you to do some stuff with your AVD infrastructure, all the action are triggered using natural language
The infrastructure is based on Copilot Studio, Power Automate and Logic App.

### IMPLEMENTATION

Follow those steps to implement the MVP :
- Go to https://make.powerautomate.com/en-us/widgets/manage/ and sign-in with your credentials
- Click on Solution and than import and select the *.zip file
- Deploy Bicep for the Azure Resources - you can run src\source\Deploy-AVDCopilotLogicApps.ps1 

| Deployment Type           | Link                                                                                                                                                                                                                                                                                                                                                                                                                       |
| :------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Azure Portal UI           | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAVDCopilot%2Frefs%2Fheads%2Fmain%2Fsrc%2FAzure%2Farm%2FAVDCopilotLogicApps.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAVDCopilot%2Frefs%2Fheads%2Fmain%2Fsrc%2FAzure%2Fportal-ui%2Fportal-ui.json) |
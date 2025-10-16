targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@description('Location for all resources')
// Based on the model, creating an agent is not supported in all regions. 
// The combination of allowed and usageName below is for AZD to check AI model gpt-4o-mini quota only for the allowed regions for creating an agent.
// If using different models, update the SKU,capacity depending on the model you use.
// https://learn.microsoft.com/azure/ai-services/agents/concepts/model-region-support
@allowed([
  'eastus'
  'eastus2'
  'swedencentral'
  'westus'
  'westus3'
])
@metadata({
  azd: {
    type: 'location'
    // quota-validation for ai models: gpt-4o-mini
    usageName: [
      'OpenAI.GlobalStandard.gpt-4o-mini,80'
    ]
  }
})
param location string

@description('Use this parameter to use an existing AI project resource ID')
param azureExistingAIProjectResourceId string = ''
@description('The Azure resource group where new resources will be deployed')
param resourceGroupName string = ''
@description('The Azure AI Foundry Hub resource name. If ommited will be generated')
param aiProjectName string = ''
@description('The application insights resource name. If ommited will be generated')
param applicationInsightsName string = ''
@description('The AI Services resource name. If ommited will be generated')
param aiServicesName string = ''
@description('The Azure Search resource name. If ommited will be generated')
param searchServiceName string = ''
@description('The Azure Search connection name. If ommited will use a default value')
param searchConnectionName string = ''
@description('The search index name')
param aiSearchIndexName string = ''
@description('The Azure Storage Account resource name. If ommited will be generated')
param storageAccountName string = ''
@description('The log analytics workspace name. If ommited will be generated')
param logAnalyticsWorkspaceName string = ''
@description('Id of the user or app to assign application roles')
param principalId string = ''

// Chat completion model
@description('Format of the chat model to deploy')
@allowed(['Microsoft', 'OpenAI'])
param agentModelFormat string = 'OpenAI'
@description('Name of agent to deploy')
param agentName string = 'agent-template-assistant'
@description('(Deprecated) ID of agent to deploy')
param aiAgentID string = ''
@description('ID of the existing agent')
param azureExistingAgentId string = ''
@description('Name of the chat model to deploy')
param agentModelName string = 'gpt-4o-mini'
@description('Name of the model deployment')
param agentDeploymentName string = 'gpt-4o-mini'

@description('Version of the chat model to deploy')
// See version availability in this table:
// https://learn.microsoft.com/azure/ai-services/openai/concepts/models#global-standard-model-availability
param agentModelVersion string = '2024-07-18'

@description('Sku of the chat deployment')
param agentDeploymentSku string = 'GlobalStandard'

@description('Capacity of the chat deployment')
// You can increase this, but capacity is limited per model/region, so you will get errors if you go over
// https://learn.microsoft.com/en-us/azure/ai-services/openai/quotas-limits
param agentDeploymentCapacity int = 30

// Embedding model
@description('Format of the embedding model to deploy')
@allowed(['Microsoft', 'OpenAI'])
param embedModelFormat string = 'OpenAI'

@description('Name of the embedding model to deploy')
param embedModelName string = 'text-embedding-3-small'
@description('Name of the embedding model deployment')
param embeddingDeploymentName string = 'text-embedding-3-small'
@description('Embedding model dimensionality')
param embeddingDeploymentDimensions string = '100'

@description('Version of the embedding model to deploy')
// See version availability in this table:
// https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings-models
param embedModelVersion string = '1'

@description('Sku of the embeddings model deployment')
param embedDeploymentSku string = 'Standard'

@description('Capacity of the embedding deployment')
// You can increase this, but capacity is limited per model/region, so you will get errors if you go over
// https://learn.microsoft.com/azure/ai-services/openai/quotas-limits
param embedDeploymentCapacity int = 30

@description('Additional model deployments to create')
param additionalModelDeployments array = []

param useApplicationInsights bool = true
@description('Do we want to use the Azure AI Search')
param useSearchService bool = false

@description('Do we want to use the Azure Monitor tracing')
param enableAzureMonitorTracing bool = false

@description('Do we want to use the Azure Monitor tracing for GenAI content recording')
param azureTracingGenAIContentRecordingEnabled bool = false

param templateValidationMode bool = false

@description('Random seed to be used during generation of new resources suffixes.')
param seed string = newGuid()

var runnerPrincipalType = templateValidationMode? 'ServicePrincipal' : 'User'

var abbrs = loadJsonContent('./abbreviations.json')

var resourceToken = templateValidationMode? toLower(uniqueString(subscription().id, environmentName, location, seed)) :  toLower(uniqueString(subscription().id, environmentName, location))

var tags = { 'azd-env-name': environmentName }

var tempAgentID = !empty(aiAgentID) ? aiAgentID : ''
var agentID = !empty(azureExistingAgentId) ? azureExistingAgentId : tempAgentID

var aiChatModel = [
  {
    name: agentDeploymentName
    model: {
      format: agentModelFormat
      name: agentModelName
      version: agentModelVersion
    }
    sku: {
      name: agentDeploymentSku
      capacity: agentDeploymentCapacity
    }
  }
]
var aiEmbeddingModel = [ 
  {
    name: embeddingDeploymentName
    model: {
      format: embedModelFormat
      name: embedModelName
      version: embedModelVersion
    }
    sku: {
      name: embedDeploymentSku
      capacity: embedDeploymentCapacity
    }
  }
]

var aiDeployments = concat(
  aiChatModel,
  useSearchService ? aiEmbeddingModel : [],
  additionalModelDeployments
)

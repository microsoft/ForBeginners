$SubscriptionId = ([System.Environment]::GetEnvironmentVariable('AZURE_SUBSCRIPTION_ID', "Process"))
$Location = ([System.Environment]::GetEnvironmentVariable('AZURE_LOCATION', "Process"))

$Errors = 0

if (-not $SubscriptionId) {
    Write-Error "❌ ERROR: Missing AZURE_SUBSCRIPTION_ID"
    $Errors++
}

if (-not $Location) {
    Write-Error "❌ ERROR: Missing AZURE_LOCATION"
    $Errors++
}

if ($Errors -gt 0) {
    exit 1
}

# --- Set Resource Names Based on LAB_INSTANCE_ID ---
$LAB_INSTANCE_ID = [System.Environment]::GetEnvironmentVariable('LAB_INSTANCE_ID', "Process")

if (-not [string]::IsNullOrEmpty($LAB_INSTANCE_ID)) {
    Write-Host ""
    Write-Host "📋 Lab Instance ID detected: $LAB_INSTANCE_ID" -ForegroundColor Green
    Write-Host "🔧 Setting unique resource names for lab environment..." -ForegroundColor Cyan
    
    # Sanitize LAB_INSTANCE_ID (remove special characters, convert to lowercase)
    $LAB_INSTANCE_ID = $LAB_INSTANCE_ID.ToLower() -replace '[^a-z0-9]', ''
    
    # Set resource names with LAB_INSTANCE_ID suffix
    # Note: Azure resource names have specific character limits and naming rules
    
    # AI Services (Azure OpenAI) - max 64 chars, alphanumerics and hyphens
    azd env set AZURE_AISERVICES_NAME "aoai-$LAB_INSTANCE_ID"
    
    # AI Hub - max 260 chars
    azd env set AZURE_AIHUB_NAME "hub-$LAB_INSTANCE_ID"
    
    # AI Project - max 260 chars
    azd env set AZURE_AIPROJECT_NAME "project-$LAB_INSTANCE_ID"
    
    # Search Service - 2-60 chars, lowercase letters, digits, and hyphens
    azd env set AZURE_SEARCH_SERVICE_NAME "search-$LAB_INSTANCE_ID"
    
    # Application Insights - max 260 chars
    azd env set AZURE_APPLICATION_INSIGHTS_NAME "appi-$LAB_INSTANCE_ID"
    
    # Container Registry - 5-50 chars, alphanumerics only (no hyphens)
    $REGISTRY_NAME = "acr$LAB_INSTANCE_ID"
    azd env set AZURE_CONTAINER_REGISTRY_NAME $REGISTRY_NAME
    
    # Key Vault - 3-24 chars, alphanumerics and hyphens
    $KV_NAME = "kv-$LAB_INSTANCE_ID"
    # Truncate if too long (Key Vault has a 24 char limit)
    if ($KV_NAME.Length -gt 24) {
        $KV_NAME = $KV_NAME.Substring(0, 24)
    }
    azd env set AZURE_KEYVAULT_NAME $KV_NAME
    
    # Storage Account - 3-24 chars, lowercase letters and numbers only (no hyphens)
    $STORAGE_NAME = "st$LAB_INSTANCE_ID"
    # Truncate if too long
    if ($STORAGE_NAME.Length -gt 24) {
        $STORAGE_NAME = $STORAGE_NAME.Substring(0, 24)
    }
    azd env set AZURE_STORAGE_ACCOUNT_NAME $STORAGE_NAME
    
    # Log Analytics Workspace - max 260 chars
    azd env set AZURE_LOG_ANALYTICS_WORKSPACE_NAME "log-$LAB_INSTANCE_ID"
    
    # Resource Group - max 90 chars
    azd env set AZURE_RESOURCE_GROUP "rg-$LAB_INSTANCE_ID"
    
    Write-Host "✅ Resource names configured with Lab Instance ID: $LAB_INSTANCE_ID" -ForegroundColor Green
    Write-Host ""
}


$defaultEnvVars = @{
    AZURE_AI_EMBED_DEPLOYMENT_NAME = 'text-embedding-3-small'
    AZURE_AI_EMBED_MODEL_NAME = 'text-embedding-3-small'
    AZURE_AI_EMBED_MODEL_FORMAT = 'OpenAI'
    AZURE_AI_EMBED_MODEL_VERSION = '1'
    AZURE_AI_EMBED_DEPLOYMENT_SKU = 'Standard'
    AZURE_AI_EMBED_DEPLOYMENT_CAPACITY = '50'
    AZURE_AI_AGENT_DEPLOYMENT_NAME = 'gpt-4o-mini'
    AZURE_AI_AGENT_MODEL_NAME = 'gpt-4o-mini'
    AZURE_AI_AGENT_MODEL_VERSION = '2024-07-18'
    AZURE_AI_AGENT_MODEL_FORMAT = 'OpenAI'
    AZURE_AI_AGENT_DEPLOYMENT_SKU = 'GlobalStandard'
    AZURE_AI_AGENT_DEPLOYMENT_CAPACITY = '80'
}

$envVars = @{}

foreach ($key in $defaultEnvVars.Keys) {
    $val = [System.Environment]::GetEnvironmentVariable($key, "Process")
    $envVars[$key] = $val
    if (-not $val) {
        $envVars[$key] = $defaultEnvVars[$key]
    }
    azd env set $key $envVars[$key]
}

# --- If we do not use existing AI Project, we don't deploy models, so skip validation ---
$resourceId = [System.Environment]::GetEnvironmentVariable('AZURE_EXISTING_AIPROJECT_RESOURCE_ID', "Process")
if (-not [string]::IsNullOrEmpty($resourceId)) {
    Write-Host "✅ AZURE_EXISTING_AIPROJECT_RESOURCE_ID is set, skipping model deployment validation."
    exit 0
}

$chatDeployment = @{
    name = $envVars.AZURE_AI_AGENT_DEPLOYMENT_NAME
    model = @{
        name = $envVars.AZURE_AI_AGENT_MODEL_NAME
        version = $envVars.AZURE_AI_AGENT_MODEL_VERSION
        format = $envVars.AZURE_AI_AGENT_MODEL_FORMAT
    }
    sku = @{
        name = $envVars.AZURE_AI_AGENT_DEPLOYMENT_SKU
        capacity = $envVars.AZURE_AI_AGENT_DEPLOYMENT_CAPACITY
    } 
    capacity_env_var_name = 'AZURE_AI_AGENT_DEPLOYMENT_CAPACITY'
}



$aiModelDeployments = @($chatDeployment)

$useSearchService = ([System.Environment]::GetEnvironmentVariable('USE_AZURE_AI_SEARCH_SERVICE', "Process"))

if ($useSearchService -eq 'true') {
    $embedDeployment = @{
        name = $envVars.AZURE_AI_EMBED_DEPLOYMENT_NAME
        model = @{
            name = $envVars.AZURE_AI_EMBED_MODEL_NAME
            version = $envVars.AZURE_AI_EMBED_MODEL_VERSION
            format = $envVars.AZURE_AI_EMBED_MODEL_FORMAT
        }
        sku = @{
            name = $envVars.AZURE_AI_EMBED_DEPLOYMENT_SKU
            capacity = $envVars.AZURE_AI_EMBED_DEPLOYMENT_CAPACITY
            min_capacity = 30
        }
        capacity_env_var_name = 'AZURE_AI_EMBED_DEPLOYMENT_CAPACITY'
    }

    $aiModelDeployments += $embedDeployment
}


az account set --subscription $SubscriptionId
Write-Host "🎯 Active Subscription: $(az account show --query '[name, id]' --output tsv)"

$QuotaAvailable = $true

try {
    Write-Host "🔍 Validating model deployments against quotas..."
} catch {
    Write-Error "❌ ERROR: Failed to validate model deployments. Ensure you have the necessary permissions."
    exit 1
}

foreach ($deployment in $aiModelDeployments) {
    $name = $deployment.name
    $model = $deployment.model.name
    $type = $deployment.sku.name
    $format = $deployment.model.format
    $capacity = $deployment.sku.capacity
    $capacity_env_var_name = $deployment.capacity_env_var_name
    Write-Host "🔍 Validating model deployment: $name ..."
    & .\scripts\resolve_model_quota.ps1 -Location $Location -Model $model -Format $format -Capacity $capacity -CapacityEnvVarName $capacity_env_var_name -DeploymentType $type

    # Check if the script failed
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ ERROR: Quota validation failed for model deployment: $name"
        $QuotaAvailable = $false
    }
}


if (-not $QuotaAvailable) {
    exit 1
} else {
    Write-Host "✅ All model deployments passed quota validation successfully."
    exit 0
}
#!/bin/bash

set -e

# --- Check Required Environment Variables ---
SubscriptionId="${AZURE_SUBSCRIPTION_ID}"
Location="${AZURE_LOCATION}"

Errors=0

if [ -z "$SubscriptionId" ]; then
    echo "❌ ERROR: Missing AZURE_SUBSCRIPTION_ID" >&2
    Errors=$((Errors + 1))
fi

if [ -z "$Location" ]; then
    echo "❌ ERROR: Missing AZURE_LOCATION" >&2
    Errors=$((Errors + 1))
fi

if [ "$Errors" -gt 0 ]; then
    exit 1
fi

# --- Set Resource Names Based on LAB_INSTANCE_ID ---
LAB_INSTANCE_ID="${LAB_INSTANCE_ID}"

if [ -n "$LAB_INSTANCE_ID" ]; then
    echo ""
    echo "📋 Lab Instance ID detected: $LAB_INSTANCE_ID"
    echo "🔧 Setting unique resource names for lab environment..."
    
    # Sanitize LAB_INSTANCE_ID (remove special characters, convert to lowercase)
    LAB_INSTANCE_ID=$(echo "$LAB_INSTANCE_ID" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
    
    # Set resource names with LAB_INSTANCE_ID suffix
    # Note: Azure resource names have specific character limits and naming rules
    
    # AI Services (Azure OpenAI) - max 64 chars, alphanumerics and hyphens
    azd env set AZURE_AISERVICES_NAME "aoai-${LAB_INSTANCE_ID}"
    
    # AI Hub - max 260 chars
    azd env set AZURE_AIHUB_NAME "hub-${LAB_INSTANCE_ID}"
    
    # AI Project - max 260 chars
    azd env set AZURE_AIPROJECT_NAME "project-${LAB_INSTANCE_ID}"
    
    # Search Service - 2-60 chars, lowercase letters, digits, and hyphens
    azd env set AZURE_SEARCH_SERVICE_NAME "search-${LAB_INSTANCE_ID}"
    
    # Application Insights - max 260 chars
    azd env set AZURE_APPLICATION_INSIGHTS_NAME "appi-${LAB_INSTANCE_ID}"
    
    # Container Registry - 5-50 chars, alphanumerics only (no hyphens)
    REGISTRY_NAME="acr${LAB_INSTANCE_ID}"
    azd env set AZURE_CONTAINER_REGISTRY_NAME "$REGISTRY_NAME"
    
    # Key Vault - 3-24 chars, alphanumerics and hyphens
    KV_NAME="kv-${LAB_INSTANCE_ID}"
    # Truncate if too long (Key Vault has a 24 char limit)
    if [ ${#KV_NAME} -gt 24 ]; then
        KV_NAME="${KV_NAME:0:24}"
    fi
    azd env set AZURE_KEYVAULT_NAME "$KV_NAME"
    
    # Storage Account - 3-24 chars, lowercase letters and numbers only (no hyphens)
    STORAGE_NAME="st${LAB_INSTANCE_ID}"
    # Truncate if too long
    if [ ${#STORAGE_NAME} -gt 24 ]; then
        STORAGE_NAME="${STORAGE_NAME:0:24}"
    fi
    azd env set AZURE_STORAGE_ACCOUNT_NAME "$STORAGE_NAME"
    
    # Log Analytics Workspace - max 260 chars
    azd env set AZURE_LOG_ANALYTICS_WORKSPACE_NAME "log-${LAB_INSTANCE_ID}"
    
    # Resource Group - max 90 chars
    azd env set AZURE_RESOURCE_GROUP "rg-${LAB_INSTANCE_ID}"
    
    echo "✅ Resource names configured with Lab Instance ID: $LAB_INSTANCE_ID"
    echo ""
fi

# --- Default Values ---
declare -A defaultEnvVars=(
    [AZURE_AI_EMBED_DEPLOYMENT_NAME]="text-embedding-3-small"
    [AZURE_AI_EMBED_MODEL_NAME]="text-embedding-3-small"
    [AZURE_AI_EMBED_MODEL_FORMAT]="OpenAI"
    [AZURE_AI_EMBED_MODEL_VERSION]="1"
    [AZURE_AI_EMBED_DEPLOYMENT_SKU]="Standard"
    [AZURE_AI_EMBED_DEPLOYMENT_CAPACITY]="50"
    [AZURE_AI_AGENT_DEPLOYMENT_NAME]="gpt-4o-mini"
    [AZURE_AI_AGENT_MODEL_NAME]="gpt-4o-mini"
    [AZURE_AI_AGENT_MODEL_VERSION]="2024-07-18"
    [AZURE_AI_AGENT_MODEL_FORMAT]="OpenAI"
    [AZURE_AI_AGENT_DEPLOYMENT_SKU]="GlobalStandard"
    [AZURE_AI_AGENT_DEPLOYMENT_CAPACITY]="80"
)

# --- Set Env Vars and azd env ---
declare -A envVars
for key in "${!defaultEnvVars[@]}"; do
    val="${!key}"
    if [ -z "$val" ]; then
        val="${defaultEnvVars[$key]}"
    fi
    envVars[$key]="$val"
    azd env set "$key" "$val"
done

# --- If we do not use existing AI Project, we don't deploy models, so skip validation ---
resourceId="${AZURE_EXISTING_AIPROJECT_RESOURCE_ID}"
if [ -n "$resourceId" ]; then
    echo "✅ AZURE_EXISTING_AIPROJECT_RESOURCE_ID is set, skipping model deployment validation."
    exit 0
fi

# --- Build Chat Deployment ---
chatDeployment_name="${envVars[AZURE_AI_AGENT_DEPLOYMENT_NAME]}"
chatDeployment_model_name="${envVars[AZURE_AI_AGENT_MODEL_NAME]}"
chatDeployment_model_version="${envVars[AZURE_AI_AGENT_MODEL_VERSION]}"
chatDeployment_model_format="${envVars[AZURE_AI_AGENT_MODEL_FORMAT]}"
chatDeployment_sku_name="${envVars[AZURE_AI_AGENT_DEPLOYMENT_SKU]}"
chatDeployment_capacity="${envVars[AZURE_AI_AGENT_DEPLOYMENT_CAPACITY]}"
chatDeployment_capacity_env="AZURE_AI_AGENT_DEPLOYMENT_CAPACITY"

aiModelDeployments=(
    "$chatDeployment_name|$chatDeployment_model_name|$chatDeployment_model_version|$chatDeployment_model_format|$chatDeployment_sku_name|$chatDeployment_capacity|$chatDeployment_capacity_env"
)

# --- Optional Embed Deployment ---
if [ "$USE_AZURE_AI_SEARCH_SERVICE" == "true" ]; then
    embedDeployment_name="${envVars[AZURE_AI_EMBED_DEPLOYMENT_NAME]}"
    embedDeployment_model_name="${envVars[AZURE_AI_EMBED_MODEL_NAME]}"
    embedDeployment_model_version="${envVars[AZURE_AI_EMBED_MODEL_VERSION]}"
    embedDeployment_model_format="${envVars[AZURE_AI_EMBED_MODEL_FORMAT]}"
    embedDeployment_sku_name="${envVars[AZURE_AI_EMBED_DEPLOYMENT_SKU]}"
    embedDeployment_capacity="${envVars[AZURE_AI_EMBED_DEPLOYMENT_CAPACITY]}"
    embedDeployment_capacity_env="AZURE_AI_EMBED_DEPLOYMENT_CAPACITY"

    aiModelDeployments+=(
        "$embedDeployment_name|$embedDeployment_model_name|$embedDeployment_model_version|$embedDeployment_model_format|$embedDeployment_sku_name|$embedDeployment_capacity|$embedDeployment_capacity_env"
    )
fi

# --- Set Subscription ---
az account set --subscription "$SubscriptionId"
echo "🎯 Active Subscription: $(az account show --query '[name, id]' --output tsv)"

QuotaAvailable=true

# --- Validate Quota ---
for entry in "${aiModelDeployments[@]}"; do
    IFS="|" read -r name model model_version format type capacity capacity_env_var_name <<< "$entry"
    echo "🔍 Validating model deployment: $name ..."
    ./scripts/resolve_model_quota.sh \
        -Location "$Location" \
        -Model "$model" \
        -Format "$format" \
        -Capacity "$capacity" \
        -CapacityEnvVarName "$capacity_env_var_name" \
        -DeploymentType "$type"

    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Quota validation failed for model deployment: $name" >&2
        QuotaAvailable=false
    fi
done

# --- Final Check ---
if [ "$QuotaAvailable" != "true" ]; then
    exit 1
else
    echo "✅ All model deployments passed quota validation successfully."
    exit 0
fi
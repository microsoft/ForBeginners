#!/bin/bash

azd env set AZURE_AI_AGENT_DEPLOYMENT_CAPACITY 100
azd env set ENABLE_AZURE_MONITOR_TRACING true
azd env set AZURE_TRACING_GEN_AI_CONTENT_RECORDING_ENABLED true
azd env set USE_AZURE_AI_SEARCH_SERVICE true
azd env set USE_APPLICATION_INSIGHTS true
azd env set AZURE_AIPROJECT_NAME nitya-fbazd-aiproj
azd env set AZURE_AISERVICES_NAME nitya-fbazd-aisvcs

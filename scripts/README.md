# AZD Template Setup

This README describes how to recreate the custom AZD template used here in a new repository. 

The end result is a `.azd-setup` folder created at the root of the repository with all your infrastructure setup and depedenceies. The scripts make it easier for you to setup the template, customize it, and tear it down later - from the commandline. 

_All scripts are currently for bash - and tested with the default development container configuration in this repository_.

---


## 1. Infrastructure Setup

This project uses the [get-started-with-ai-agents](https://github.com/Azure-Samples/get-started-with-ai-agents) template to provision infrastructure for this project.

For simplicity, all steps are coded in `scripts/` that you can just run at command line to get things done.


### 1.1. Authenticate with Azure

Run this command from root of repo:

```bash
./scripts/1-setup-auth
```

### 1.2. Setup Template

Run this command from the root of repo:

```bash
./scripts/2-setup-azd
```

This script will:
1. Create the `.azd-setup` directory
2. Initialize the AI agents template from Azure Samples
3. Configure environment variables for the lab
4. **Install Python dependencies** from the template (requirements-dev.txt and editable src package)

#### **Python Dependencies**: 
The script automatically installs Python dependencies after the `.azd-setup` directory is created:
- `pip install -r .azd-setup/requirements-dev.txt` (if file exists)
- `pip install -e .azd-setup/src` (if directory exists)

These dependencies are installed conditionally only after the template is set up, which is why they're commented out in the main `requirements.txt` file.

#### **Recommendation**: 
Once the `.azure/AI-AGENTS-AZD/.env` is created, specify `AZURE_LOCATION="swedencentral"` proactively to have it pick up that location. This may not always show as an option if run using default `azd up`

### **Additional Models**
The azd template can be extended to support additional model deployments beyond the default GPT-4o-mini and text-embedding-3-small models. This section explains how to add custom model deployments using a Bicep parameter array approach.

Use the provided script to automatically apply these changes:

```bash
./scripts/0-additional-models
```

#### **Execution**: 

Once the setup is complete, change to the template directory:

```bash
cd .azd-setup
```

Then deploy the application and infrastructure in one command:

```bash
azd provision
```

You may be prompted to log into azd as shown:

```bash
WARNING: You must be logged into Azure perform this action
? Would you like to log in now? (Y/n) 
```

Accept the default "Y" response. This will trigger the device-code based auth flow shown below. You exact code will vary.

```bash
? Would you like to log in now? Yes

Start by copying the next code: F8X72PR73
Then press enter and continue to log in from your browser...
```

Complete the workflow using the Azure account you had logged into for the previous authentication step. Then select the active subscription to use for the deployment (from the provided list). If you had only 1 subscription, it will be selected as a default.

Let the process complete. You should see continuous updates in the console. On completion, you will see a success message like this:

```bash
SUCCESS: Your up workflow to provision and deploy to Azure completed in 12 minutes 31 seconds.
```


### 1.3. Do More Customization

> 🚨 TODO: This section needs to be tested!! 🚨

First, add any additional models required for the project with 2 steps:

1. Update `scripts/0-additional-models.json` to specify models
1. Run `scripts/0-additional-models` to update azd template with these details
1. Run `azd provision` to update the infrastructure provisioning

_Note:_ 

1. Doing "azd up" will also deploy the app again. If you didn't change the app source code, then azd provision is the best command to minimize overheads.
1. Some "customizations" may need to be done in the first install (i.e., during setup-azd step) and will not be enforced in subsequent reprovisionins. Read the base template documentation to understand what those constraints are.


### 1.4. Teardown Template

Once you are done with testing or learning, it is a good idea to tear down the template to reduce costs. There are 2 options:

**Option 1: Delete Infrastructure**

Run this command from the `.azd-setup/` folder from which you did the `azd up` previously. This will delete the resource group and release model quota.

```
azd down --purge
```

**Option 2: Delete Infrastructure & Template**

Use this option only if you want to delete the default template in this repository and rebuild a new one using scripts. This is useful for maintainers (pull latest versions of base template) or learners (to understand how scripts work). 

_It is not recommended if you are currently doing a workshop with this repo and need to use the provided custom template version. In that case, use Option 1_.

To use this teardown-everything option, run this command:

```bash
./scripts/3-teardown-azd
```

---

## 2. Add Model Deployments

The azd template can be extended to support additional model deployments beyond the default GPT-4o-mini and text-embedding-3-small models. This section explains how to add custom model deployments using a Bicep parameter array approach.

### 2.1. Bicep Parameter Array Approach

The recommended approach uses a flexible array parameter in the main Bicep template to support additional model deployments:

#### **Step 1: Add Parameter to main.bicep**
Add this parameter to `infra/main.bicep`:

```bicep
@description('Additional model deployments to create')
param additionalModelDeployments array = []
```

#### **Step 2: Update Model Deployment Logic**
Modify the `aiDeployments` variable in `main.bicep`:

```bicep
var aiDeployments = concat(
  aiChatModel,
  useSearchService ? aiEmbeddingModel : [],
  additionalModelDeployments  // Add this line
)
```

#### **Step 3: Update Parameters File**
Add entry to `infra/main.parameters.json`:

```json
"additionalModelDeployments": {
  "value": "${ADDITIONAL_MODEL_DEPLOYMENTS=[]}"
}
```

#### **Step 4: Configure Additional Models**
Create a JSON configuration file with model details:

```json
[
  {
    "name": "gpt-4",
    "model": {
      "format": "OpenAI",
      "name": "gpt-4", 
      "version": "2024-05-13"
    },
    "sku": {
      "name": "GlobalStandard",
      "capacity": 10
    }
  }
]
```

### 2.2. Automated Script Approach

Use the provided script to automatically apply these changes:

```bash
./scripts/0-additional-models
```

This script will:
- Read model configurations from `scripts/0-additional-models.json`
- Automatically modify the required Bicep and parameter files
- Set up environment variables for deployment
- Prepare the infrastructure for additional model deployments

**Note**: After running the script, use `azd provision` to deploy the additional models.

---


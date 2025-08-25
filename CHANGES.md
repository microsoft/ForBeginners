# CHANGES.md

## 2025-08-25

- Removed all Azure Container Apps dependencies from the infrastructure Bicep files (`infra/main.bicep`).
    - Commented out the `containerApps` and `api` module blocks.
    - Commented out all outputs related to container apps and API modules.
    - Added comments in the code to explain why these changes were made.
- These changes ensure that only infrastructure is provisioned, with no Azure Container Apps or related API resources created.
- No changes were made to the actual module files (e.g., `core/host/container-apps.bicep`), but they are now unused.
- This update was made in response to a user request to provision infrastructure only, with no application/service deployment.

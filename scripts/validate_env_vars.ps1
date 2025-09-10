# Define environment variables and their regex patterns
$envValidationRules = @{
    "AZURE_EXISTING_AIPROJECT_RESOURCE_ID" = '^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft\.CognitiveServices/accounts/[^/]+/projects/[^/]+$'
}

$hasError = $false

foreach ($envVar in $envValidationRules.Keys) {
    $pattern = $envValidationRules[$envVar]
    $value = [Environment]::GetEnvironmentVariable($envVar)

    if ($value) {
        if ($value -notmatch $pattern) {
            Write-Host "❌ Invalid value for '$envVar'. Expected pattern: $pattern"
            $hasError = $true
        }
    }
}

if ($hasError) {
    exit 1
}

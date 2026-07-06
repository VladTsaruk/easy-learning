$ErrorActionPreference = "Stop"

. "$PSScriptRoot\cicd\services.ps1"

$changeJson = & "$PSScriptRoot\detect_changes.ps1" `
    -Before $env:BEFORE_SHA `
    -After $env:CURRENT_SHA

$changes = $changeJson | ConvertFrom-Json
$services = @($changes.services)

if ($services.Count -eq 0) {
    Write-Host "Nothing to deploy."
    exit 0
}

Write-Host "Services to deploy: $($services -join ', ')"
Write-Host "Reasons: $($changes.reasons -join ', ')"

$config = Get-CiCdConfig

foreach ($dependency in $config.DependencyServices) {
    $containerId = docker compose ps -q $dependency

    if ([string]::IsNullOrWhiteSpace($containerId)) {
        Write-Host "Starting dependency service '$dependency'..."
        docker compose up -d $dependency
    }
    else {
        Write-Host "Dependency service '$dependency' is already running. Leaving it untouched."
    }
}

foreach ($serviceName in $services) {
    & "$PSScriptRoot\deploy_service.ps1" -ServiceName $serviceName
}

& "$PSScriptRoot\health_check.ps1"

docker image prune -f

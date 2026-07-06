$ErrorActionPreference = "Stop"

. "$PSScriptRoot\cicd\services.ps1"

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

foreach ($service in Get-CiCdAutoDeployServices) {
    & "$PSScriptRoot\deploy_service.ps1" -ServiceName $service.Name
}

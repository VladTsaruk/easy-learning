param(
    [Parameter(Mandatory = $true)]
    [string]$ServiceName
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\cicd\services.ps1"

$service = Get-CiCdService -Name $ServiceName
$composeService = $service.ComposeService
$arguments = @("compose", "up", "-d", "--no-deps")

if ($service.Build) {
    $arguments += "--build"
}

$arguments += $composeService

Write-Host "Deploying service '$ServiceName'..."
docker @arguments

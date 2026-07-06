param(
    [Parameter(Mandatory = $true)]
    [string]$Before,

    [Parameter(Mandatory = $true)]
    [string]$After
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\cicd\services.ps1"

function Test-ZeroSha {
    param([string]$Sha)
    return $Sha -match "^0+$"
}

function Get-ChangedFiles {
    param(
        [string]$BeforeSha,
        [string]$AfterSha
    )

    if ((Test-ZeroSha -Sha $BeforeSha) -or [string]::IsNullOrWhiteSpace($BeforeSha)) {
        Write-Host "Before SHA is empty or zero. Treating this as a first deploy."
        return $null
    }

    $files = @(git diff --name-only $BeforeSha $AfterSha 2>$null)

    if ($LASTEXITCODE -eq 0) {
        return $files
    }

    Write-Host "Could not diff '$BeforeSha..$AfterSha'. Falling back to changed files in the current commit."
    return @(git diff-tree --no-commit-id --name-only -r $AfterSha)
}

$config = Get-CiCdConfig
$changedFiles = Get-ChangedFiles -BeforeSha $Before -AfterSha $After
$deployAllApps = $null -eq $changedFiles
$servicesToDeploy = New-Object System.Collections.Generic.HashSet[string]
$reasons = New-Object System.Collections.Generic.List[string]

if ($deployAllApps) {
    foreach ($serviceName in $config.AppDeployOnGlobalChange) {
        [void]$servicesToDeploy.Add($serviceName)
    }

    [void]$reasons.Add("initial-deploy")
}
else {
    foreach ($file in $changedFiles) {
        if (Test-CiCdPathMatch -Path $file -Patterns $config.GlobalChangePaths) {
            foreach ($serviceName in $config.AppDeployOnGlobalChange) {
                [void]$servicesToDeploy.Add($serviceName)
            }

            [void]$reasons.Add("global:$file")
            continue
        }

        foreach ($service in Get-CiCdAutoDeployServices) {
            if (Test-CiCdPathMatch -Path $file -Patterns $service.Paths) {
                [void]$servicesToDeploy.Add($service.Name)
                [void]$reasons.Add("$($service.Name):$file")
            }
        }
    }
}

$orderedServices = Get-CiCdAutoDeployServices |
    Where-Object { $servicesToDeploy.Contains($_.Name) } |
    Select-Object -ExpandProperty Name

$result = [ordered]@{
    before = $Before
    after = $After
    changedFiles = @($changedFiles)
    services = @($orderedServices)
    reasons = @($reasons | Select-Object -Unique)
}

$result | ConvertTo-Json -Depth 5 -Compress

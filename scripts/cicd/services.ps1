$script:CiCdConfig = [pscustomobject]@{
    DependencyServices = @("postgres")
    AppDeployOnGlobalChange = @("backend", "frontend", "nginx")
    GlobalChangePaths = @(
        "docker-compose.yml",
        ".github/workflows/*",
        "scripts/*",
        ".env*"
    )
    Services = @(
        [pscustomobject]@{
            Name = "postgres"
            ComposeService = "postgres"
            Paths = @()
            Build = $false
            AutoDeploy = $false
            DeployOrder = 10
            HealthUrls = @()
        },
        [pscustomobject]@{
            Name = "backend"
            ComposeService = "backend"
            Paths = @("backend/*")
            Build = $true
            AutoDeploy = $true
            DeployOrder = 20
            HealthUrls = @("http://localhost/api/health")
        },
        [pscustomobject]@{
            Name = "frontend"
            ComposeService = "frontend"
            Paths = @("frontend/*")
            Build = $true
            AutoDeploy = $true
            DeployOrder = 30
            HealthUrls = @("http://localhost/")
        },
        [pscustomobject]@{
            Name = "nginx"
            ComposeService = "nginx"
            Paths = @("nginx/*")
            Build = $false
            AutoDeploy = $true
            DeployOrder = 40
            HealthUrls = @("http://localhost/")
        }
    )
}

function Get-CiCdConfig {
    return $script:CiCdConfig
}

function Get-CiCdService {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $service = $script:CiCdConfig.Services | Where-Object { $_.Name -eq $Name } | Select-Object -First 1

    if (-not $service) {
        throw "Unknown service '$Name'."
    }

    return $service
}

function Get-CiCdAutoDeployServices {
    return $script:CiCdConfig.Services |
        Where-Object { $_.AutoDeploy } |
        Sort-Object DeployOrder
}

function Test-CiCdPathMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$Patterns
    )

    $normalizedPath = $Path -replace "\\", "/"

    foreach ($pattern in $Patterns) {
        if ($normalizedPath -like $pattern) {
            return $true
        }
    }

    return $false
}

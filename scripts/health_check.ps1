$ErrorActionPreference = "Stop"

. "$PSScriptRoot\cicd\services.ps1"

$maxAttempts = 12
$delaySeconds = 5
$urls = Get-CiCdAutoDeployServices |
    ForEach-Object { $_.HealthUrls } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Select-Object -Unique

foreach ($url in $urls) {
    $passed = $false

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        try {
            Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 10 | Out-Null
            $passed = $true
            break
        }
        catch {
            if ($attempt -eq $maxAttempts) {
                throw "Health check failed for '$url'. Last error: $($_.Exception.Message)"
            }

            Start-Sleep -Seconds $delaySeconds
        }
    }

    if ($passed) {
        Write-Host "Health check passed for '$url'."
    }
}


$uac = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $uac) {
    Write-Host "You must run this script as administrator." -ForegroundColor Yellow
    exit
}
Clear-Host
$host.ui.RawUI.WindowTitle = "RBW Services Checker"
Write-Host ""
Write-Host @"
██████╗  █████╗ ███╗   ██╗██╗  ██╗███████╗██████╗     ██████╗ ███████╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗
██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝
██████╔╝███████║██╔██╗ ██║█████╔╝ █████╗  ██║  ██║    ██████╔╝█████╗  ██║  ██║██║ █╗ ██║███████║██████╔╝███████╗
██╔══██╗██╔══██║██║╚██╗██║██╔═██╗ ██╔══╝  ██║  ██║    ██╔══██╗██╔══╝  ██║  ██║██║███╗██║██╔══██║██╔══██╗╚════██║
██║  ██║██║  ██║██║ ╚████║██║  ██╗███████╗██████╔╝    ██████╔╝███████╗██████╔╝╚███╔███╔╝██║  ██║██║  ██║███████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═════╝     ╚═════╝ ╚══════╝╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
                                                                                                                
"@ -Foregroundcolor blue
Write-Host "                                     Service Checker - made by QuickPots" -Foregroundcolor blue
Start-Sleep -Seconds 2
Write-Host ""
Write-Host "[ SERVICES STATUS ]" -ForegroundColor Blue
Write-Host ""
$services = @(
    "SysMain",
    "PcaSvc",
    "DPS",
    "BAM",
    "EventLog",
    "WSearch",
    "DusmSvc"
)

$TableServices = foreach ($service in $services) {
    $status = Get-Service -Name $service -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Service = $service
        Status  = if ($status -and $status.Status -eq "Running") {
            "Running"
        } else {
            "Stopped"
        }
    }
}


$cdpusersvclookup = Get-Service |
    Where-Object { $_.Name -match '^CDPUserSvc_.+' }

foreach ($service in $cdpusersvclookup) {
    $TableServices += [PSCustomObject]@{
        Service = $service.Name
        Status  = if ($service.Status -eq "Running") {
            "Running"
        } else {
            "Stopped"
        }
    }
}


foreach ($service in $TableServices) {
    $colour = if ($service.Status -eq "Running") { "Green" } else { "Red" }

    Write-Host ("{0,-30} {1}" -f $service.Service, $service.Status) `
        -ForegroundColor $colour
}


Write-Host ""
Write-Host "[ SETTINGS ]" -ForegroundColor Blue
Write-Host ""

$settings = @(
    @{
        Name = "CMD"
        Path = "HKCU:\Software\Policies\Microsoft\Windows\System"
        Key = "DisableCMD"
        Warning = "Disabled"
        Safe = "Available"
    },
    @{
        Name = "PowerShell Scriptblock Logging"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
        Key = "EnableScriptBlockLogging"
        Warning = "Disabled"
        Safe = "Enabled"
    },
    @{
        Name = "Activities Cache"
        Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        Key = "EnableActivityFeed"
        Warning = "Disabled"
        Safe = "Enabled"
    },
    @{
        Name = "Prefetch"
        Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        Key = "EnablePrefetcher"
        Warning = "Disabled"
        Safe = "Enabled"
    }
@{
    Name = "Jump Lists"
    Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Key = "Start_TrackDocs"
    Warning = "Disabled"
    Safe = "Enabled"
}
)

foreach ($s in $settings) {

    $status = Get-ItemProperty `
        -Path $s.Path `
        -Name $s.Key `
        -ErrorAction SilentlyContinue

    Write-Host "$($s.Name): " -NoNewLine

    if ($status -and $status.$($s.Key) -eq 0) {
        Write-Host "$($s.Warning)" -ForegroundColor Red
    }
    else {
        Write-Host "$($s.Safe)" -ForegroundColor Green
    }
}$appCompatPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"

Write-Host "PCA Logging: " -NoNewLine

if (Test-Path $appCompatPath) {
    Write-Host "Disabled" -ForegroundColor Red
}
else {
    Write-Host "Enabled" -ForegroundColor Green
}

Write-Host ""
Write-Host "Press enter to exit..." -ForegroundColor Yellow
Read-Host

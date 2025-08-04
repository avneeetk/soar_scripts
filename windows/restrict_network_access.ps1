<#
    SOAR Action Script - Restrict Network Access (Windows)
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$TargetIP = "*",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Outbound", "Inbound")]
    [string]$Direction = "Outbound",

    [Parameter(Mandatory = $false)]
    [string]$RuleName = "SOAR_Restrict_Network"
)

function Write-Log {
    param ([string]$Level, [string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# === Check Admin Permissions ===
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $adminCheck) {
    Write-Log "ERROR" "Script must be run as Administrator."
    exit 1
} else {
    Write-Log "INFO" "Administrator privileges confirmed."
}


# === Validate IP Format (basic check) ===
if ($TargetIP -ne "*" -and -not ($TargetIP -match '^(?:\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$')) {
    Write-Log "ERROR" "Invalid IP format. Use a valid IPv4 or '*'."
    exit 1
}

# === Check if Firewall Tool Exists ===
if (-not (Get-Command "New-NetFirewallRule" -ErrorAction SilentlyContinue)) {
    Write-Log "ERROR" "New-NetFirewallRule not available. Is this Windows 10+?"
    exit 1
}

# === Apply Firewall Block ===
try {
    New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction $Direction `
        -Action Block `
        -RemoteAddress $TargetIP `
        -Enabled True `
        -Protocol Any `
        -Profile Any | Out-Null

    Write-Log "INFO" "Successfully blocked network access ($Direction) to $TargetIP."
    exit 0
} catch {
    Write-Log "ERROR" "Failed to block network access. $_"
    exit 2
}
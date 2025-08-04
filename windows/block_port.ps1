<#
SOAR Action Script - Block Network Port
Blocks a specified network port (TCP/UDP) using Windows Firewall.
#>

param(
    [Parameter(Mandatory = $true)]
    [int]$PortNumber,

    [Parameter(Mandatory = $false)]
    [ValidateSet("TCP", "UDP")]
    [string]$Protocol = "TCP",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction = "Inbound",

    [Parameter(Mandatory = $false)]
    [string]$RuleName
)

# Default rule name if not provided
if (-not $RuleName) {
    $RuleName = "SOAR_Block_Port_$PortNumber"
}

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

# === Validate Port Number ===
if ($PortNumber -lt 1 -or $PortNumber -gt 65535) {
    Write-Log "ERROR" "Invalid port number. Must be between 1 and 65535."
    exit 1
}

# === Check for Firewall Command ===
if (-not (Get-Command "New-NetFirewallRule" -ErrorAction SilentlyContinue)) {
    Write-Log "ERROR" "Windows Firewall module not available."
    exit 1
}

# === Create Firewall Rule ===
try {
    New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Inbound `
        -Action Block `
        -Enabled True `
        -Protocol $Protocol `
        -LocalPort $PortNumber `
        -Profile Any | Out-Null

    Write-Log "INFO" "Successfully blocked port $PortNumber ($Protocol, Inbound)."
    exit 0
}
catch {
    Write-Log "ERROR" "Failed to create firewall rule. Error: $_"
    exit 1
}

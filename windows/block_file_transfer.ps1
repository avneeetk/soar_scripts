<#
SOAR Action Script - Block File Transfer Methods
#>


param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("FTP", "SMB")]
    [string]$Method,

    [Parameter(Mandatory = $false)]
    [string]$RuleName = "SOAR_Block_FileTransfer_$Method"
)


function Write-log{
    param([string]$Level, [string]$Message)
    $timestamp=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp $Level $Message"
}

# === Check Admin Permissions ===
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $adminCheck) {
    Write-Log "ERROR" "Script must be run as Administrator."
    exit 1
} else {
    Write-Log "INFO" "Administrator privileges confirmed."
}


#===Tool Availabilty check===
if(-not(Get-Command "net" -ErrorAction SilentlyContinue)){
    Write-Log "ERROR" "'net user' command not found. Script requires Windows CMD tools."
    exit 1
}

# === Determine Port to Block Based on Method ===
switch ($Method) {
    "FTP" { $Port = 21; $Protocol = "TCP" }
    "SMB" { $Port = 445; $Protocol = "TCP" }
    default {
        Write-Log "ERROR" "Unsupported file transfer method."
        exit 1
    }
}

## === Create Firewall Rule ===
try {
    New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Outbound `
        -Action Block `
        -Enabled True `
        -Protocol $Protocol `
        -LocalPort $Port `
        -Profile Any | Out-Null

    Write-Log "INFO" "Successfully blocked $Method file transfer (port $Port)."
    exit 0
}
catch {
    Write-Log "ERROR" "Failed to create firewall rule. $_"
    exit 2
}

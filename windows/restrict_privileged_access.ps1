<#
    SOAR Action Script - Restrict Privileged Access (Windows)
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Username
)

function Write-Log {
    param (
        [string]$Level,
        [string]$Message
    )
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

# === Check if User Exists ===
try {
    $user = Get-LocalUser -Name $Username -ErrorAction Stop
    Write-Log "INFO" "User '$Username' exists."
} catch {
    Write-Log "ERROR" "User '$Username' does not exist."
    exit 1
}

# === Check If User is in Administrators Group ===
$adminGroup = "Administrators"
$members = Get-LocalGroupMember -Group $adminGroup | Where-Object { $_.Name -like "*$Username" }

if (-not $members) {
    Write-Log "INFO" "User '$Username' is not in the Administrators group. Nothing to do."
    exit 0
}

# === Remove User from Admin Group ===
try {
    Remove-LocalGroupMember -Group $adminGroup -Member $Username -ErrorAction Stop
    Write-Log "INFO" "Successfully removed '$Username' from the Administrators group."
    exit 0
} catch {
    Write-Log "ERROR" "Failed to remove user from Administrators group. $_"
    exit 2
}

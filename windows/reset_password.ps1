<#
SOAR Action Script - Reset Local User Password
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$NewPassword
)

function Write-Log{
    param([string]$Level, [string]$Message)
    $timestamp=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp][$Level] $Message"
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

#===Validating Input===
if($Username -match"[^\w\d]"){
    Write-Log "ERROR" "Username contains invalid characters."
    exit 1
}

if($NewPassword.length -lt 8){
    Write-Log "ERROR" "Password is too short. Minimum length: 8 characters."
    exit 1
}

#===Check if user exists===
try{
    $userCheck= net user $Username 2>&1
    if($userCheck -match "The user name could not be found"){
    Write-Log "ERROR" "User $Username does not exist."
    exit 1
 }
}catch{
    Write-Log "ERROR" "Failed to check user. Error:$_"
    exit 1
}

#===RESET===
try{
    net user $Username $NewPassword | Out-Null
    if($LASTEXITCODE -eq 0){
        Write-Log "INFO" "Password for user '$Username' was successfully reset."
        exit 0 
    }else{
       Write-Log "ERROR" "Password reset failed with exit code $LASTEXITCODE" 
       exit 2
    }
}catch{
    Write-Log "ERROR" "Unexpected error occurred: $_"
    exit 3
}




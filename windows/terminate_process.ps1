<#
SOAR Action Script - Terminate Process
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProcessName,

    [Parameter(Mandatory=$false)]
    [int]$ProcessId
)


function Write-Log{
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

#===Input Validation===
if(-not $ProcessName -and -not $ProcessId){
    Write-Log -Level "Error" -Message "ProcessName or PID must be provided."
    exit 1
}

#===Terminate by PID===
if($ProcessId){
    try{
        $proc = Get-Process -Id $ProcessId -ErrorAction Stop
        Stop-Process -Id $ProcessId -Force -ErrorAction Stop
        Write-Log "INFO" "Successfully terminated process with PID $ProcessId ($($proc.ProcessName))."
        exit 0
    }catch{
        Write-Log "ERROR" "Failed to terminate PID $ProcessId. $_"
        exit 2
    }
}

#===Terminate By Process Name===
if($ProcessName){
    try{
        $procs = Get-Process -Name $ProcessName -ErrorAction Stop
        foreach($proc in $procs){
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            Write-Log "INFO" "Successfully terminated process with PID $($proc.Id)"
        }
        exit 0 
    }catch{
        Write-Log "ERROR" "Failed to terminate process with name $ProcessName. $_"
    }
}
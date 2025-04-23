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

# Function used to download files from a source URL to a destination directory
function DownloadFile($source, $destination)
{
  Write-Host "Downloading $source to $destination"
  if ($source -ne "") {
    Invoke-WebRequest $source -OutFile $destination
  } else {
    throw "Download failed. No URL specified."
  }
}

# Function used to copy files from a source S3 bucket to a destination directory
function CopyFromS3($source, $destination)
{
  Write-Host "Copying $source to $destination"
  if ($source -ne "") {
    $source = $source.Split("/", 4)
    Copy-S3Object -BucketName $source[2] -Key $source[3] -LocalFile $destination
  } else {
    throw "Copy failed. No URL specified."
  }
}

# Specify the installer filename
$installer = "eyez-agentmanager-default.msi"

# Specify the root URL
$url = "https://eyez-dist.private.zscaler.com/windows"
# $url = "https://eyez-dist.zpabeta.net/windows"
# $url = "s3://<bucket>/<directory>""

# Log all output to a local file
Start-Transcript -Path "$PSScriptRoot\install.log"

# Log user running the script
Write-Host "This script was executed by:"
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Force TLS 1.2 for this session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Test and log SSL connection to help debug packet inspection issues that will break agent mTLS
$sslCheckUrls = "eyez-dist.private.zscaler.com","eyez-dist.zpabeta.net"
foreach ($sslCheckUrl in $sslCheckUrls) {
  try {
    Write-Host "`nRunning SSL certificate check against $sslCheckUrl"
    CheckSSL $sslCheckUrl
  } catch {
    Write-Host "SSL check error to $sslCheckUrl"
    Write-Host $_
  }
}

# Get files
DownloadFile "$url/$installer" "$PSScriptRoot\$installer"
# CopyFromS3 "s3://<bucket>/<folder>/<filename>" "$PSScriptRoot\$installer"

# Run the installer
$Arguments = @(
  "PROVISIONKEY_FILE=`"$PSScriptRoot\provision_key`""
  "/i"
  $installer
  "/qn"
  "/l*v msiexec.log"
)
Write-Host "`nInstalling the agent"
Start-Process "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow

Write-Host "`nComplete"
Stop-Transcript

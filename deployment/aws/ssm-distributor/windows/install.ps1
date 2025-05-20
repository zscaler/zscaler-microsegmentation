# Function used to download files from a source URL to a destination directory
function DownloadFile($source, $destination)
{
  Write-Host "`nDownloading $source to $destination"
  if ($source -ne "") {
    Invoke-WebRequest $source -OutFile $destination
  } else {
    throw "`nDownload failed. No URL specified."
  }
}

# Function used to copy files from a source S3 bucket to a destination directory
function CopyFromS3($source, $destination)
{
  Write-Host "`nCopying $source to $destination"
  if ($source -ne "") {
    $source = $source.Split("/", 4)
    Copy-S3Object -BucketName $source[2] -Key $source[3] -LocalFile $destination
  } else {
    throw "`nCopy failed. No URL specified."
  }
}

# Specify the installer filename
$installer = "eyez-agentmanager-default.msi"

# Specify the root URL. Uncomment and update the preferred cloud or S3 bucket target.
$url = "https://eyez-dist.private.zscaler.com/windows"  # Production
# $url = "https://eyez-dist.zpabeta.net/windows"  # Beta
# $url = "s3://<bucket>/<directory>"  # Local S3 bucket

# Log all output to a local file
Start-Transcript -Path "$PSScriptRoot\install.log"

# Log user running the script
Write-Host "This script was executed by:"
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Force TLS 1.2 for this session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get files
if ($url -like "https://*") {
  DownloadFile "$url/$installer" "$PSScriptRoot\$installer"
} elseif ($url -like "s3://*") {
  CopyFromS3 "$url/$installer" "$PSScriptRoot\$installer"
} else {
  throw "Invalid URL: $url"
}

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

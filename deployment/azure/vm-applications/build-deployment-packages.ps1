$filename = "zscaler-microsegmentation-agent-windows.zip"
Write-Host "Building $filename"
Compress-Archive -Path windows\install.ps1,windows\uninstall.ps1,provision_key,version -DestinationPath $filename -Force -Verbose
$shavalue = Get-FileHash -Path $filename -Algorithm SHA256 | Select-Object -ExpandProperty Hash 
Write-Host "SHA256 value: $shavalue`n"

$filename = "zscaler-microsegmentation-agent-linux.zip"
Write-Host "Building $filename"
Compress-Archive -Path linux\install.sh,linux\uninstall.sh,provision_key,version -DestinationPath $filename -Force -Verbose
$shavalue = Get-FileHash -Path $filename -Algorithm SHA256 | Select-Object -ExpandProperty Hash 
Write-Host "SHA256 value: $shavalue`n"

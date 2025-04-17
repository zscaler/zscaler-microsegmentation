filename="zscaler-microsegmentation-agent-windows.zip"
echo "Building $filename"
zip -j $filename windows/install.ps1 windows/uninstall.ps1 provision_key version
shavalue=$(sha256sum $filename --quiet)
echo "SHA256 value: $shavalue\n"

filename="zscaler-microsegmentation-agent-linux.zip"
echo "Building $filename"
zip -j $filename linux/install.sh linux/uninstall.sh provision_key version
shavalue=$(sha256sum $filename --quiet)
echo "SHA256 value: $shavalue\n"

filename="zscaler-microsegmentation-agent-windows.zip"
echo "Building $filename"
zip -j $filename windows/install.ps1 windows/uninstall.ps1 provision_key
shavalue=$(sha256sum $filename --quiet)
echo "SHA256 value: $shavalue\n"

filename="zscaler-microsegmentation-agent-linux-rpm.zip"
echo "Building $filename"
zip -j $filename linux/rpm/install.sh linux/rpm/uninstall.sh provision_key
shavalue=$(sha256sum $filename --quiet)
echo "SHA256 value: $shavalue\n"

filename="zscaler-microsegmentation-agent-linux-deb.zip"
echo "Building $filename"
zip -j $filename linux/deb/install.sh linux/deb/uninstall.sh provision_key
shavalue=$(sha256sum $filename --quiet)
echo "SHA256 value: $shavalue\n"

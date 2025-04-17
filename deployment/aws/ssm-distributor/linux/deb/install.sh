#!/bin/sh

# Specify the download URL
URL="https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.amd64.deb"  # Production
# URL="https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.amd64.deb"  # Beta

# Specify the root directory
DIR="/opt/zscaler"

mkdir -p $DIR/var
mv -f provision_key $DIR/var

if command -v wget 2>&1 >/dev/null
then
    wget -N --debug --secure-protocol=TLSv1_2 --tries=2 --retry-connrefused --retry-on-host-error --directory-prefix="$DIR/installation" $URL
elif command -v curl 2>&1 >/dev/null
then
    curl -v --tlsv1.2 --retry 2 --retry-all-errors --remote-name --create-dirs --output-dir "$DIR/installation" $URL
else
    echo "Failed to download installer"
    exit 1
fi

apt install -y $DIR/installation/eyez-agentmanager-default-1.amd64.deb

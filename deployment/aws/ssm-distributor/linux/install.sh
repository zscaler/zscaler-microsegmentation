#!/bin/sh

download_installer()
{
    if command -v wget 2>&1 >/dev/null
    then
        wget -N --debug --secure-protocol=TLSv1_2 --tries=4 --retry-connrefused --retry-on-host-error --directory-prefix="$1/installation" $2
    elif command -v curl 2>&1 >/dev/null
    then
        curl -v --tlsv1.2 --retry 4 --retry-all-errors --remote-name --create-dirs --output-dir "$1/installation" $2
    else
        echo "Failed to download installer"
        exit 1
    fi
}

# Specify the root directory
DIR="/opt/zscaler"

mkdir -p $DIR/var
mv -f provision_key $DIR/var

# Download installer and run
if command -v yum 2>&1 >/dev/null
then
    # Specify the download URL
    URL="https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.el7.x86_64.rpm"  # Production
    # URL="https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.el7.x86_64.rpm"  # Beta
    download_installer $DIR $URL
    yum install --disablerepo=* -y $DIR/installation/eyez-agentmanager-default-1.el7.x86_64.rpm
elif command -v apt 2>&1 >/dev/null
then
    # Specify the download URL
    URL="https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.amd64.deb"  # Production
    # URL="https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.amd64.deb"  # Beta
    download_installer $DIR $URL
    apt install -y $DIR/installation/eyez-agentmanager-default-1.amd64.deb
else
    echo "Failed to run installer"
    exit 1
fi

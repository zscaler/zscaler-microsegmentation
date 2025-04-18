#!/bin/sh

# Specify the download URL
URL="https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.el7.x86_64.rpm"  # Production
# URL="https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.el7.x86_64.rpm"  # Beta

# Specify the root directory
DIR="/opt/zscaler"

mkdir -p $DIR/var
mv -f provision_key $DIR/var

# Check if wget is installed
if command -v wget 2>&1 >/dev/null
then
    # Try wget with all relevant command options. This may fail with older versions of wget.
    wget -N --debug --secure-protocol=TLSv1_2 --tries=2 --retry-connrefused --retry-on-host-error --directory-prefix="$DIR/installation" $URL
    if [ $? -ne 0 ]
    then
        # Exit code was nonzero. Attempt wget with fewer options.
        echo "Failed to download the installer using default wget options. Attempting fall-back."
        wget -N --debug --directory-prefix="$DIR/installation" $URL
        if [ $? -ne 0 ]
        then
            echo "Failed all attempts to download installer using wget" >&2
            exit 1
        fi
    fi
# Check if curl is installed
elif command -v curl 2>&1 >/dev/null
then
    # Try curl with all relevant command options. This may fail with older versions of curl.
    curl -v --tlsv1.2 --retry 2 --retry-all-errors --remote-name --create-dirs --output-dir "$DIR/installation" $URL
    if [ $? -ne 0 ]
    then
        # Exit code was nonzero. Attempt curl with fewer options.
        echo "Failed to download the installer using default curl options. Attempting fall-back."
        curl -v --remote-name --create-dirs --output-dir "$DIR/installation" $URL
        if [ $? -ne 0 ]
        then
            echo "Failed to download installer using curl" >&2
            exit 1
        fi
    fi
else
    echo "Failed all attempts to download installer: curl and wget not available"
    exit 1
fi

yum install --disablerepo=* -y $DIR/installation/eyez-agentmanager-default-1.el7.x86_64.rpm

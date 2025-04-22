#!/bin/sh

# Specify the installer filename
FILENAME="eyez-agentmanager-default-1.amd64.deb"

# Specify the download URL
URL="https://eyez-dist.private.zscaler.com/linux/$FILENAME"  # Production
# URL="https://eyez-dist.zpabeta.net/linux/$FILENAME"  # Beta

# Specify the root directory
DIR="/opt/zscaler"

mkdir -p $DIR/var
mv -f provision_key $DIR/var

# Check if wget is installed
if command -v wget 2>&1 >/dev/null
then
    # Try wget with all relevant command options. This may fail with older versions of wget.
    wget -N --secure-protocol=TLSv1_2 --tries=3 --retry-connrefused --retry-on-host-error --directory-prefix="$DIR/installation" $URL
    if [ $? -ne 0 ]
    then
        # Exit code was nonzero. Attempt wget with fewer options.
        echo "Failed to download the installer using default wget options. Attempting fall-back."
        wget -N --debug --tries=3 --directory-prefix="$DIR/installation" $URL
        if [ $? -ne 0 ]
        then
            echo "Failed all attempts to download installer using wget fall-back options" >&2
            exit 1
        fi
    fi
# Check if curl is installed
elif command -v curl 2>&1 >/dev/null
then
    # Try curl with all relevant command options. This may fail with older versions of curl.
    curl --tlsv1.2 --retry 3 --retry-all-errors --remote-name --create-dirs --output-dir "$DIR/installation" $URL
    if [ $? -ne 0 ]
    then
        # Exit code was nonzero. Attempt curl with fewer options.
        echo "Failed to download the installer using default curl options. Attempting fall-back."
        curl -v --retry 3 -o "$DIR/installation/$FILENAME" $URL
        if [ $? -ne 0 ]
        then
            echo "Failed to download installer using curl fall-back options" >&2
            exit 1
        fi
    fi
else
    echo "Failed all attempts to download installer: curl and wget not available"
    exit 1
fi

apt install -y $DIR/installation/$FILENAME

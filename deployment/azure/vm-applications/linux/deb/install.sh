#!/bin/sh

download_file()
{
    # Check if wget is installed
    if command -v wget 2>&1 >/dev/null
    then
        # Try wget with all relevant command options. This may fail with older versions of wget.
        wget -N --secure-protocol=TLSv1_2 --tries=3 --retry-connrefused --retry-on-host-error --directory-prefix=$2 $1
        if [ $? -ne 0 ]
        then
            # Exit code was nonzero. Attempt wget with fewer options.
            echo "Failed to download $1 using default wget options. Attempting fall-back."
            wget -N --debug --tries=3 --directory-prefix=$2 $1
            if [ $? -ne 0 ]
            then
                echo "Failed all attempts to download $1 using wget fall-back options" >&2
                exit 1
            fi
        fi
    # Check if curl is installed
    elif command -v curl 2>&1 >/dev/null
    then
        # Try curl with all relevant command options. This may fail with older versions of curl.
        curl --tlsv1.2 --retry 3 --retry-all-errors --remote-name --create-dirs --output-dir $2 $1
        if [ $? -ne 0 ]
        then
            # Exit code was nonzero. Attempt curl with fewer options.
            echo "Failed to download $1 using default curl options. Attempting fall-back."
            curl -v --retry 3 -o $2 $1
            if [ $? -ne 0 ]
            then
                echo "Failed to download $1 using curl fall-back options" >&2
                exit 1
            fi
        fi
    else
        echo "Failed all attempts to download $1"
        exit 1
    fi
}

# Specify the installer filename
INSTALLER="eyez-agentmanager-default-1.amd64.deb"

# Specify the root URL
URL="https://eyez-dist.private.zscaler.com/linux"  # Production
# URL="https://eyez-dist.zpabeta.net/linux"  # Beta

# Specify the root directory
DIR="/opt/zscaler"

# Create directories and move the provision_key
mkdir -p $DIR/var
mv -f $DIR/installation/provision_key $DIR/var

# Download files
download_file "$URL/$INSTALLER" "$DIR/installation"

# Run the installer
apt-get install -y $DIR/installation/$INSTALLER

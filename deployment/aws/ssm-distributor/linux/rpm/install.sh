#!/bin/sh

download_file()
{
    echo "Downloading $1 to $2"
    # Check if wget is installed
    if command -v wget 2>&1 >/dev/null
    then
        # Try wget with all relevant command options. This may fail with older versions of wget.
        echo "Using wget"
        wget -N --secure-protocol=TLSv1_2 --tries=3 --retry-connrefused --retry-on-host-error --directory-prefix=$2 $1
        if [ $? -ne 0 ]
        then
            # Exit code was nonzero. Attempt wget with fewer options.
            echo "Failed to download using default wget options. Attempting fall-back."
            wget -N --tries=3 --directory-prefix=$2 $1
            if [ $? -ne 0 ]
            then
                echo "Failed all attempts to download using wget fall-back options" >&2
                exit 1
            fi
        fi
    # Check if curl is installed
    elif command -v curl 2>&1 >/dev/null
    then
        echo "Using curl"
        # Try curl with all relevant command options. This may fail with older versions of curl.
        curl --tlsv1.2 --retry 3 --retry-all-errors --remote-name --create-dirs --output-dir $2 $1
        if [ $? -ne 0 ]
        then
            # Exit code was nonzero. Attempt curl with fewer options.
            echo "Failed to download using default curl options. Attempting fall-back."
            FILENAME=$(basename $1)
            curl --retry 3 -o "$2/$FILENAME" $1
            if [ $? -ne 0 ]
            then
                echo "Failed to download using curl fall-back options" >&2
                exit 1
            fi
        fi
    else
        echo "Failed all attempts to download $1"
        exit 1
    fi
    echo -e "Download complete\n"
}

copy_from_s3()
{
    echo "Copying $1 to $2"
    aws s3 cp $1 $2
}

# Specify the installer filename
INSTALLER="eyez-agentmanager-default-1.el7.x86_64.rpm"

# Specify the GPG filename
GPG="gpg"

# Specify the root URL
URL="https://eyez-dist.private.zscaler.com/linux"  # Production
# URL="https://eyez-dist.zpabeta.net/linux"  # Beta
# URL="s3://<bucket>/<directory>"  # Local S3 bucket

# Specify the root directory
DIR="/opt/zscaler/zms"

echo -e "Starting install\n"

# Create directories
echo "Creating directories"
mkdir -p $DIR/installation
mkdir -p $DIR/var
echo -e "Done\n"

# Move the provision_key
echo "Moving the provision_key"
mv -f provision_key $DIR/var
echo -e "Done\n"

# Get files
if [ "$(echo $URL | cut -c 1-6)" = "https:" ]
then
    download_file "$URL/$INSTALLER" "$DIR/installation"
    download_file "$URL/$GPG" "$DIR/installation"
elif [ "$(echo $URL | cut -c 1-3)" = "s3:" ]
then
    copy_from_s3 "$URL/$INSTALLER" "$DIR/installation"
    copy_from_s3 "$URL/$GPG" "$DIR/installation"
else
    echo "Invalid URL: $URL"
    exit 1
fi

# Import the GPG key
echo "Importing the GPG key"
rpm --import $DIR/installation/$GPG
if [ $? -ne 0 ]
then
    echo "Failed to import the GPG key" >&2
    exit 1
fi
echo -e "Done\n"

# Run the installer
echo "Installing the rpm package"
yum install --disablerepo=* -y $DIR/installation/$INSTALLER
if [ $? -ne 0 ]
then
    echo "Failed to install the RPM" >&2
    exit 1
fi

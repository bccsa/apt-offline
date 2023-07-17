#!/bin/bash

# ================================
# Offline debian package repository builder
#
# (C) BCC South Africa
# ================================

packagelist=$1
buildDir=$2

# Get the script running directory
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create / clear the build directory
rm -rf "$buildDir"
mkdir -p "$buildDir"

# Copy package list to build directory
cp -f $packagelist $buildDir/packages.txt

# Download packages
cd "$buildDir"
sudo apt-get update
if test -s "$packagelist"
then
    while IFS= read -r package
    do
        if [ "$package" != "" ]
        then
            apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w" | sort -u)
        fi
    done < "$packagelist"
fi

# Build package index
dpkg-scanpackages . > Packages

cd "$scriptDir"

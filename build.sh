#!/bin/bash

# ================================
# Offline debian package repository builder
#
# (C) BCC South Africa
# ================================

# references: https://stackoverflow.com/questions/22008193/how-to-list-download-the-recursive-dependencies-of-a-debian-package

packagelist=$1
buildDir=$2
dir=$(dirname $packagelist)

apt-get -y update

# Get the script running directory
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create / clear the build directory
rm -rf "$buildDir"
mkdir -p "$buildDir"

output=""

# Download packages
# sudo apt-get update
if test -s "$packagelist"
then
    downloadList=""

    while IFS=',' read -r package path
    do
        if [ "$package" != "" ]
        then
            # Add package to output file
            output="$output
            $package"

            p=$(echo "$path" | grep "^\w")
            path="$dir/$p"
            
            if [ "$path" != "" ]
            then
                # Copy .deb package to build directory
                cp $path $buildDir

                # Scan for dependencies
                scanoutput=$(dpkg-scanpackages $path | grep Depends: | sed -e 's/Depends://g' | perl -pe 's/\((.*?)\)| //g' | perl -pe 's/\|/,/g')

                # Split comma-separated list
                IFS=','
                for pkg in $scanoutput
                do
                    downloadList="$downloadList
                    $pkg"
                done
            else
                # Install from default apt repository (as per /etc/apt/sources.list)
                list=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w")

                downloadList="$downloadList
                $list"

                #apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w" | sort -u)
            fi
        fi
    done < "$packagelist"

    # format download list
    downloadList="$downloadList
    "
    downloadList=$(echo "$downloadList" | awk '{gsub(/<\/?loc>|[[:space:]]/,"");print}' | sort -u | tr -s '\n' ' ' | xargs)

    # format and save output package list
    echo "$output" | awk '{gsub(/<\/?loc>|[[:space:]]/,"");print}' | sort -u > "$buildDir/packages.txt"

    # Download packages & dependencies
    cd "$buildDir"
    # eval "apt-get download $downloadList"
    IFS=' '
    for debPkg in $downloadList
    do
        apt-get download "$debPkg"
    done

    # Build package index
    dpkg-scanpackages . > Packages
fi

cd "$scriptDir"

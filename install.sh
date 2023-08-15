#!/bin/bash

# ================================
# Offline debian package installer / updater (apt-get / .deb files)
#
# (C) BCC South Africa
# ================================

repository=$1
sourceref="deb [trusted=yes] file:$repository ./"

# Cleanup packages (helps recover from interrupted apt-get installs)
dpkg --configure -a > /dev/null

# Make a backup copy of the default apt sources list. Once a backup is made, new backups are not made to prevent accidental modification of the original file.
if test -e "/var/tmp/sources.list.bak"
then 
    echo "apt sources backup already exists"
else
    cp -f "/etc/apt/sources.list" "/var/tmp/sources.list.bak"
fi

# Replace the default apt sources repository with the offline sources repository
su -c "echo '$sourceref' > /etc/apt/sources.list"

# Update apt to use newly selected sources list
apt-get -y update > /dev/null

# Attempt to fix previously broken installs
apt-get --fix-broken -y install > /dev/null

# install packages from package list
if test -s "$repository/packages.txt"
then
    while IFS= read -r package
    do
        if [ "$package" != "" ]
        then
            # Install quietly
            # Force overwrite: https://askubuntu.com/questions/176121/dpkg-error-trying-to-overwrite-file-which-is-also-in
            apt-get -y -o Dpkg::Options::="--force-overwrite" install $package -qq > /dev/null
        fi
    done < "$repository/packages.txt"
fi

# Restore the default repository
cp -f "/var/tmp/sources.list.bak" "/etc/apt/sources.list"

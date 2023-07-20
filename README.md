# apt-offline
Scripts to build an offline apt repository for Debian (and related) OS's, and to install from the repository. This may be useful for distributing (a subset of) updates/packages to offline devices.

---

## Building an offline apt repository
Use the ```build.sh``` script to download the packages (including dependencies) listed in the file passed as the first argument. The second argument should be the directory where the repository should be built.

Example:
```shell
./build.sh path/to/yourPackageList.txt path/to/build/directory
```

*Note: The last character in the package list text file should be a newline character (Enter).*

---

## Manually including .deb package files
.deb files can be included manually by adding the path to the file in the package list file (remember to separate the package name and file path with a comma).

Example
```
yourDebPackage,path/to/yourDebPackage_1.2.3-1_armhf.deb
anotherPackage
yetAnotherPackage

```

A package list is created in the build directory as ```packages.txt```.

**Do not run with sudo / as root**

*Important! The repository should be built using the target hardware and operating system (e.g. Raspberry Pi OS armhf running on a Raspberry Pi 3/4/400).*

---

## Including packages from non-default repositories
Non-default repositories may be added to the build environment's ```/etc/apt``` sources, which will enable the ```build.sh``` script to include packages from these non-default repositories. It is not needed to add the non-default repositories to the target devices as the package files will be included in the offline repository.

---

## Installing from the offline apt repository
Installing using ```install.sh``` is temporarily replacing the ```/etc/apt/sources.list``` file with a file referencing the offline repository. The ```install.sh``` script will install/update all the packages listed in the repository directory's ```packages.txt``` file, and restore the original ```/etc/apt/sources.list``` file.

```install.sh``` should be run with root priveleges.

Example:
```shell
sudo ./install.sh /absolute/path/to/repository/directory
```

*Note: The install script makes a backup of the ```/etc/apt/sources.list``` file to ```/var/tmp/sources.list.bak```. This is only done on first run, after which the initial backup is used for subsequent runs. Should the sources.list file need to be update on the target device, the backup file can be deleted to prevent the install script from reverting the sources.list file back to the original backup on next run.*

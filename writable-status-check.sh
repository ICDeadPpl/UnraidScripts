#!/bin/bash

# This script for Unraid checks that the disks are writable
# and notifies the user if the check fails.

#These functions return exit codes: 0 = found, 1 = not found

isMounted    () { findmnt -rno SOURCE,TARGET "$1" >/dev/null;} #path or device
isDevMounted () { findmnt -rno SOURCE        "$1" >/dev/null;} #device only
isPathMounted() { findmnt -rno        TARGET "$1" >/dev/null;} #path   only

#where: -r = --raw, -n = --noheadings, -o = --output

# Check if "cache" is mounted.
if isPathMounted "/mnt/cache"; then
# Cache disk writable test.
    if [ -w  "/mnt/cache/apps" ]; then
        echo "Cache disk write successful."
    else
        echo "Cache disk write unsuccessful."
        /usr/local/emhttp/webGui/scripts/notify -e "unRAID Status" -s "Cache disk unwritable" -d "The cache disk has become unwritable." -i "alert"
    fi
fi

# Check if "boot" is mounted.
if isPathMounted "/boot"; then
    # Boot disk writable test.
    if [ -w  "/boot" ]; then
        echo "Boot disk write successful."
    else
        echo "Boot disk write unsuccessful."
        /usr/local/emhttp/webGui/scripts/notify -e "unRAID Status" -s "Boot disk unwritable" -d "The Boot disk has become unwritable." -i "alert"
    fi
fi

disks=$(ls /dev/md* | sed "sX/dev/mdXX");
for disknum in $disks; do
    # Check if disk is mounted.
    if isPathMounted "/mnt/disk$disknum"; then
        # Disk writable test.
        if [ -w  "/mnt/disk$disknum" ]; then
            echo "Disk $disknum write successful."
        else
            echo "Disk $disknum write unsuccessful."
            /usr/local/emhttp/webGui/scripts/notify -e "unRAID Status" -s "Disk $disknum unwritable" -d "Disk $disknum has become unwritable." -i "alert"
        fi
    fi
done

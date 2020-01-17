#!/bin/bash

# Author: Jan Karjalainen <jan@biffstek.se>
# Github repository: https://github.com/ICDeadPpl/UnraidScripts
# This script makes backups of all the folders in Unraid's Docker appdata folder.
# All folders are backed up in separate tar.gz files in the dated destination directory.
# Backup folders older than BACKUP_DAYS are deleted.
# It also backs up the USB drive and the libvirt.img file.

# Do not edit these two lines.
source /boot/config/docker.cfg
source /boot/config/domain.cfg

# Edit these lines to your own liking.
BACKUP_DEST_APP="/mnt/user/Community_Applications_Appdata_Backup" # Appdata backup destination.
BACKUP_DEST_USB="/mnt/user/Community_Applications_USB_Backup" # Flash drive destination.
BACKUP_DEST_VM="/mnt/user/Community_Applications_VM_Backup" # libvirt.img destination.
BACKUP_DAYS=14 # Delete backups older than this amount of days.
SKIP_DIRECTORY=temp,plex # Skip these appdata directories. No spaces in directory names!

cd "$DOCKER_APP_CONFIG_PATH"
echo "Stopping Docker service."
/etc/rc.d/rc.docker stop

# Check that backup destination is mounted & writable.
if [ -w  "$BACKUP_DEST_APP" ]; then
	mkdir -p "$BACKUP_DEST_APP/$(date +%Y-%m-%d)"
	ls | while read d
	    do
            # Test for skipped directories.
            for i in ${SKIP_DIRECTORY//,/ }
            do
                if [ "$d" == "$i" ]; then
                    echo Skipping directory "$i".
                    continue 2
                fi
            done
            # Backup directory into tar.gz file.
            echo Backing up $d directory.
            tar --zstd -cf "$BACKUP_DEST_APP/$(date +%Y-%m-%d)/$d-$(date +%Y-%m-%d).tar.gz" "$d"
        done
    echo "Deleting backups older than $BACKUP_DAYS days."
    find "$BACKUP_DEST_APP"/* -type d -ctime +"$BACKUP_DAYS" | xargs rm -rf
fi

echo "Start Docker service."
/etc/rc.d/rc.docker start

echo "Backing up USB drive."
rsync -a /boot/ "$BACKUP_DEST_USB/"

echo "Backing up libvirt.img file."
/usr/bin/rsync -a "$IMAGE_FILE" "$BACKUP_DEST_VM/"

echo "All backup jobs done."

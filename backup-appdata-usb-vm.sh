#!/bin/bash

# This script makes backups of all the folders in Unraid's Docker appdata folder.
# All folders are backed up in separate tar.gz files in the dated destination directory.
# It also backs up the USB drive and the libvirt.img file.

source /boot/config/docker.cfg
source /boot/config/domain.cfg
BACKUP_DEST_APP="/mnt/user/CommunityApplicationsAppdataBackup"
BACKUP_DEST_USB="/mnt/user/Community_Applications_USB_Backup"
BACKUP_DEST_VM="/mnt/user/Community_Applications_VM_XML_Backup"

if [ -w  "$DOCKER_APP_CONFIG_PATH" ]; then
    cd "$DOCKER_APP_CONFIG_PATH"
    echo "Stopping Docker service."
    /etc/rc.d/rc.docker stop
    if [ -w  "$BACKUP_DEST_APP" ]; then
        mkdir -p "$BACKUP_DEST_APP/$(date +%Y-%m-%d)"
        ls | while read d
         do
		    # Add directories you want to exclude on the next line.
            if [ "$d" == 'temp' ] || [ "$d" == 'plex' ]; then
                continue
            fi
            echo Backing up $d directory.
            tar czf "$BACKUP_DEST_APP/$(date +%Y-%m-%d)/$d-$(date +%Y-%m-%d).tar.gz" "$d"
         done
    echo "Deleteing backups older than 14 days."
    find "$BACKUP_DEST_APP"/* -type d -ctime +10 -exec rm -rf {} \;
    fi
    echo "Start Docker service."
    /etc/rc.d/rc.docker start
fi

echo "Backing up USB drive."
rsync -a /boot/ "$BACKUP_DEST_USB/"

echo "Backing up libvirt.img file."
/usr/bin/rsync -a "$IMAGE_FILE" "$BACKUP_DEST_VM/"

echo "All backup jobs done."

#!/bin/bash

# Author: Jan Karjalainen <jan@biffstek.se>
# Github repository: https://github.com/ICDeadPpl/UnraidScripts
# This script makes backups of all the folders in Unraid's Docker appdata folder.
# All folders are backed up in separate tar.gz files in the dated destination directory.
# You can choose to delete older appdata and Docket template backups ($DELETE_BACKUPS is on by default), keeping $BACKUPS_TO_KEEP (default=3) backups.
# It also backs up Docker templates, the USB drive and the libvirt.img file.

# Start timer for elapsed time counter
SECONDS=0

# Do not edit these two lines.
source /boot/config/docker.cfg
source /boot/config/domain.cfg

# Edit these lines to your own liking.
BACKUP_DEST_APP="/mnt/user/Community_Applications_Appdata_Backup" # Appdata backup destination. Backups will be in datestamped folders.
BACKUP_DEST_USB="/mnt/user/Community_Applications_USB_Backup" # Flash drive destination.
BACKUP_DEST_VM="/mnt/user/Community_Applications_VM_Backup" # libvirt.img destination. Old "libvirt.img" file will be overwritten.
BACKUP_DEST_DOCKER_TEMPLATES="/mnt/user/Community_Applications_Docker_Backup" # Docker templates backup location.
DOCKER_TEMPLATES_DIR="/boot/config/plugins/dockerMan" # Docker templates directory location.
SKIP_DIRECTORY=temp,plex # Skip these appdata directories. No spaces in directory names!
COMPRESSION=gzip # gzip or zstd
DELETE_BACKUPS=yes # Delete old backups. Set to "no" if you want to keep all backups.
BACKUPS_TO_KEEP=3 # Number of backups to keep. The oldest ones are deleted.

# Check that backup destinations are mounted & writable.
if [ ! -w  "$BACKUP_DEST_APP" ]; then
	echo "WARNING: Backup destination \"${BACKUP_DEST_APP}\" doesn't exist!"
	echo "Backup script stopped."
	exit
elif [ ! -w  "$BACKUP_DEST_USB" ]; then
	echo "WARNING: Backup destination \"${BACKUP_DEST_USB}\" doesn't exist!"
	echo "Backup script stopped."
	exit
elif [ ! -w  "$BACKUP_DEST_VM" ]; then
	echo "WARNING: Backup destination \"${BACKUP_DEST_VM}\" doesn't exist!"
	echo "Backup script stopped."
	exit	
elif [ ! -w  "$BACKUP_DEST_DOCKER_TEMPLATES" ]; then
	echo "WARNING: Backup destination \"${BACKUP_DEST_DOCKER_TEMPLATES}\" doesn't exist!"
	echo "Backup script stopped."
	exit
else
    # Check if parity check is running and pause it if the plugin Parity Check Tuning is installed.
	if [ -f "/usr/local/bin/parity.check" ]; then
            if parity.check status | grep 'Parity Check' > /dev/null; then
                echo "Parity check active. Pausing now."
                parity.check pause
	    fi
    fi
    
	cd "$DOCKER_APP_CONFIG_PATH"
	echo "Stopping Docker service."
	/etc/rc.d/rc.docker stop
	mkdir -p "$BACKUP_DEST_APP/$(date +%Y-%m-%d)"
	ls | while read d
	    do
            # Test for skipped directories.
            for i in ${SKIP_DIRECTORY//,/ }
            do
                if [ "$d" == "$i" ]; then
                    echo "Skipping directory \"${i}\"."
                    continue 2
                fi
            done
            
            if [ "$COMPRESSION" == "gzip" ] # Backup directory into tar.gz file.
            then
                echo "Backing up directory \"${d}\"."
                tar czf "$BACKUP_DEST_APP/$(date +%Y-%m-%d)/$d-$(date +%Y-%m-%d).tar.gz" "$d"
            elif [ "$COMPRESSION" == "zstd" ] # Backup directory into tar.zst file.
            then
                echo "Backing up directory \"${d}\"."
                tar --zstd -cf "$BACKUP_DEST_APP/$(date +%Y-%m-%d)/$d-$(date +%Y-%m-%d).tar.zst" "$d"
            fi
        done
     
    mkdir -p "$BACKUP_DEST_DOCKER_TEMPLATES/$(date +%Y-%m-%d)"
    if [ "$COMPRESSION" == "gzip" ] # Backup directory into tar.gz file.
        then
            echo "Backing up directory \"${DOCKER_TEMPLATES_DIR}\"."
            tar czf "$BACKUP_DEST_DOCKER_TEMPLATES/$(date +%Y-%m-%d)/Docker-templates-$(date +%Y-%m-%d).tar.gz" "$DOCKER_TEMPLATES_DIR"
        elif [ "$COMPRESSION" == "zstd" ] # Backup directory into tar.zst file.
        then
            echo "Backing up directory \"${DOCKER_TEMPLATES_DIR}\"."
            tar --zstd -cf "$BACKUP_DEST_DOCKER_TEMPLATES/$(date +%Y-%m-%d)/Docker-templates-$(date +%Y-%m-%d).tar.zst" "$DOCKER_TEMPLATES_DIR"
    fi
    
    if [ "$DELETE_BACKUPS" == "yes" ]
        then
            echo "Deleting older backups, keeping the $BACKUPS_TO_KEEP latest."
            if cd "$BACKUP_DEST_APP"; then
                find * -maxdepth 0 -type d -printf "%T@ %p\n" | sort -nr | awk 'NR > '$BACKUPS_TO_KEEP' {print $2}' | xargs rm -rf
            fi
            if cd "$BACKUP_DEST_DOCKER_TEMPLATES"; then
                find * -maxdepth 0 -type d -printf "%T@ %p\n" | sort -nr | awk 'NR > '$BACKUPS_TO_KEEP' {print $2}' | xargs rm -rf
            fi
    fi

	echo "Start Docker service."
	/etc/rc.d/rc.docker start

	echo "Backing up USB drive."
	rsync -a /boot/ "$BACKUP_DEST_USB/"

	echo "Backing up libvirt.img file."
	/usr/bin/rsync -a "$IMAGE_FILE" "$BACKUP_DEST_VM/"
    
    # Check if parity check is paused and restart it if the plugin Parity Check Tuning is installed.
	if [ -f "/usr/local/bin/parity.check" ]; then
        if parity.check status | grep 'PAUSED' > /dev/null; then
            echo "Parity check paused. Resuming now."
            parity.check resume
        fi
    fi

	echo "All backup jobs done."
fi

# Show time elapsed.
echo "Time elapsed: $((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"

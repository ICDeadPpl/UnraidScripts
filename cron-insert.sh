#!/bin/bash

# Uncomment and edit the echo lines between 
# "#---Begin script managed section---"# 
# and 
# "#---End script managed section---" 
# for your own needs.

# Make working copy of crontab file
crontab -l > /root/tempcron

# Check if custom cron jobs exist in current crontab
if grep -Fxq "#---Begin script managed section---" /root/tempcron
then
	# Delete existing custom cron jobs
	sed -i '/#---Begin script managed section---/,/#---End script managed section--->/d' /root/tempcron
fi

# Beginning of custom cron jobs section. DO NOT COMMENT OUT/DELETE THE FOLLOWING 2 LINES.
echo "" >> /root/tempcron
echo "#---Begin script managed section---" >> /root/tempcron

#echo '' >> /root/tempcron
#echo '# Backup USB, appdata and libvrit.img:' >> /root/tempcron
#echo '35 2 * * 1,4 bash /boot/scripts/UnraidScripts/backup-appdata-usb-vm.sh > /dev/null 2>&1' >> /root/tempcron

#echo '' >> /root/tempcron
#echo '# Update clamav definitions on NzbGet container:' >> /root/tempcron
#echo '50 */2 * * * docker exec -t nzbget /usr/bin/freshclam > /dev/null 2>&1' >> /root/tempcron

#echo #' >> /root/tempcron
#echo '# MariadDB: Backup all databases.' >> /root/tempcron
#echo '30 1 */2 * * docker exec -t mariadb /config/mariadb-backup-all.sh > /dev/null 2>&1' >> /root/tempcron

#echo '' >> /root/tempcron
#echo '# Nextcloud: scan for new files.' >> /root/tempcron
#echo '30 1 * * 3 docker exec -t nextcloud /config/scan-files.sh > /dev/null 2>&1' >> /root/tempcron

echo '' >> /root/tempcron
# End of custom cron jobs section. DO NOT COMMENT OUT/DELETE THE FOLLOWING 2 LINES.
echo "#---End script managed section---"  >> /root/tempcron
echo "" >> /root/tempcron

# Write changes to crontab
crontab /root/tempcron
# Remove working copy
rm -f /root/tempcron
# Trigger crontab update
/usr/local/sbin/update_cron
exit

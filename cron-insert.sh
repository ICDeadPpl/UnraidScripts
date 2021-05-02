#!/bin/bash

# Make working copy of crontab file
crontab -l > /root/edcron

# Check if custom cron jobs exist in current crontab
if grep -Fxq "#---Begin script managed section---" /root/edcron
then
	# Delete existing custom cron jobs
	sed -i '/#---Begin script managed section---/,/#---End script managed section--->/d' /root/edcron
fi

# Add custom cron jobs
echo "" >> /root/edcron
echo '#---Begin script managed section---' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Backup USB, appdata and libvrit.img:' >> /root/edcron
#echo '35 2 * * 1,4 bash /boot/scripts/UnraidScripts/backup-appdata-usb-vm.sh > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Delete bad subtitles:' >> /root/edcron
echo '0 * * * * find /mnt/user/data/video/movies -name "*.srt.random*" -type f -delete > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Delete movie folders with no video files:' >> /root/edcron
echo '40 1 * * * bash /boot/scripts/root/bin/delsmallvideodirs.sh > /dev/null 2>&1'  >> /root/edcron

echo '' >> /root/edcron
echo '# Delete TV series folders with no video files:' >> /root/edcron
echo '50 1 * * * bash /boot/scripts/root/bin/del-empty-tv-series-dirs.sh > /dev/null 2>&1'  >> /root/edcron

echo '' >> /root/edcron
echo '# Get latest IPTV TV-channels:' >> /root/edcron
echo '50 2 * * * bash /boot/scripts/root/bin/tv-channels-update.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Get latest IPTV EPG xml file:' >> /root/edcron
#echo '55 2 * * * bash /boot/scripts/root/bin/xmltv-update.sh > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Update clamav definitions on NzbGet container:' >> /root/edcron
echo '50 */2 * * * docker exec -t nzbget /usr/bin/freshclam > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Update NzbGet + subliminal plugin in NzbGet container:' >> /root/edcron
echo '55 1 * * * docker exec -t nzbget /config/update-nzbtomedia-subliminal.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Remove downloaded movies from Radarr movie list:' >> /root/edcron
#echo '55 3 * * * bash /boot/scripts/root/bin/radarr-edit-movie-list.sh > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Download daily Dilbert comic strip from idg.se:' >> /root/edcron
echo '50 5 * * * bash /boot/scripts/root/bin/dilbert-dl.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Download subtitles for movies:' >> /root/edcron
#echo '33 */2 * * * bash /boot/scripts/root/bin/get-movie-subs.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Download subtitles for tv-series:' >> /root/edcron
#echo '44 */2 * * * bash /boot/scripts/root/bin/get-tv-subs.sh > /dev/null 2>&1' >> /root/edcron

#echo #' >> /root/edcron
#echo '# MariadDB: Backup all databases.' >> /root/edcron
#echo '30 1 */2 * * docker exec -t mariadb /config/mariadb-backup-all.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Nextcloud: scan for new files.' >> /root/edcron
#echo '30 1 * * 3 docker exec -t nextcloud /config/scan-files.sh > /dev/null 2>&1' >> /root/edcron

#echo '' >> /root/edcron
#echo '# Backup files from /root to /boot/scripts/root/.' >> /root/edcron
#echo "30 1 * * * rsync -av --exclude '.cache' --exclude '.local' /root /boot/scripts/root/ > /dev/null 2>&1" >> /root/edcron

#echo '' >> /root/edcron
#echo '# Delete downloaded TV episodes older than 7 days from download directory.' >> /root/edcron
#echo '30 1 * * * find /mnt/user/data/downloads/tv/* -mtime +7 -exec rm -rf {} \; > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# Nextcloud cron.' >> /root/edcron
echo '*/5 * * * * docker exec -u abc nextcloud php -f /config/www/nextcloud/cron.php > /dev/null 2>&1' >> /root/edcron

echo '' >> /root/edcron
echo '# NginxProxyManager certbot renew.' >> /root/edcron
echo '1 1 1 * * docker exec -t NginxProxyManager certbot renew > /dev/null 2>&1' >> /root/edcron


echo '' >> /root/edcron
echo "#---End script managed section---"  >> /root/edcron
echo "" >> /root/edcron

# Write changes to crontab
crontab /root/edcron
# Remove working copy
rm -f /root/edcron
# Trigger crontab update
/usr/local/sbin/update_cron
exit

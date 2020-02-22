#!/bin/bash

# Author: Jan Karjalainen <jan@biffstek.se>
# Github repository: https://github.com/ICDeadPpl/UnraidScripts
# This script downloads a static build of ffmpeg and installs it.
# Call this script from your 'go' script on rout Unraid.

cd /tmp
wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz
tar xf ffmpeg-git-amd64-static.tar.xz
rm ffmpeg-git-amd64-static.tar.xz
cd ffmpeg*
cp ffmpeg /usr/local/bin/
cp ffprobe /usr/local/bin/
chmod 777 /usr/local/bin/ffmpeg
chmod 777 /usr/local/bin/ffprobe
cd ..
rm -rf ffmpeg*

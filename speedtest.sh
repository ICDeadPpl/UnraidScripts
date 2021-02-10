#!/bin/bash

# This script is for binhex's VPN Dockers based on Arch Linux, 
# to be run from inside the container.
# It checks the connection speed with speedtest-cli.
# If it's not  installed, it installs it with the pacman package manager.

if [ -f "/usr/sbin/speedtest-cli" ]; then
    speedtest-cli
else
    pacman -S --noconfirm speedtest-cli
    speedtest-cli
fi



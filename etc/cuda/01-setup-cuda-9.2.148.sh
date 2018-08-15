#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    echo " sudo $0"
    exit 1
fi

if [[ "$(lsb_release -si)" != "Ubuntu" ]]; then
    echo 'Unsupported distribution.'
    exit 1
fi

apt-get purge -y nvidia*
apt-get purge -y xserver-xorg-video-nouveau

BLACKLIST_PATH=/etc/modprobe.d/blacklist.conf
GRUB_PATH=/etc/default/grub
DATETIME=`date +%Y%m%d_%H%M%S`

## Backup original script
cp "$BLACKLIST_PATH" "$BLACKLIST_PATH.$DATETIME.backup"
cp "$GRUB_PATH" "$GRUB_PATH.$DATETIME.backup"

echo "Update $BLACKLIST_PATH"
echo "blacklist vga16fb"  >> $BLACKLIST_PATH
echo "blacklist nouveau"  >> $BLACKLIST_PATH
echo "blacklist rivafb"   >> $BLACKLIST_PATH
echo "blacklist nvidiafb" >> $BLACKLIST_PATH
echo "blacklist rivatv"   >> $BLACKLIST_PATH

echo "Update $GRUB_PATH"
sed -i.temp 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"$/GRUB_CMDLINE_LINUX_DEFAULT="\1 nomodeset"/g' $GRUB_PATH

update-grub

echo "Run reboot."


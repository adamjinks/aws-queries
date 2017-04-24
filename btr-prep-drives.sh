#!/bin/bash

####################################################
#
# Prepare drives for migration to HVM
#
#
# SOURCE volume must be mounted /dev/sdf
# TARGET volume must be mounted /dev/sdg
#

# create backup directory
mkdir -v /mnt/backup

printf "\n\nMounting source volume from /dev/sdf\n"
mkdir -vp /mnt/source
mount -v /dev/xvdf /mnt/source

printf "\n\nMounting target volume from /dev/sdg1\n"
mkdir -vp /mnt/target
mount -v /dev/xvdg1 /mnt/target

printf "Backing up kernel modules.\n"
mkdir -vp /mnt/backup/modules/
cp -va /lib/modules/* /mnt/backup/modules/

printf "Backing up target /etc\n"
cp -va /mnt/target/etc /mnt/backup

printf "Preparing target volume. Deleting all but /boot\n"
cd /mnt/target
ls | grep -v boot | xargs rm -vRf

printf "Preparing source volume. Deleting /boot\n\n"
cd /mnt
rm -vRf /mnt/source/boot

printf "Copying data from source to target.\n"
rsync -aAXHPv /mnt/source/ /mnt/target

printf "Moving /etc backup to target /root.\n\n"
mv -v /mnt/backup/etc/ /mnt/target/root/etc-backup

printf "\n\nMoving kernel modules to target /lib/modules.\n"
mv -v /mnt/backup/modules/* /mnt/target/lib/modules

mv -v /mnt/target/etc/fstab /mnt/target/etc/fstab.source
cp -av /mnt/target/root/etc-backup/fstab /mnt/target/etc/fstab
chmod 600 /mnt/target/etc/fstab

printf "Operations complete. \nYOU MUST EDIT:\n"
printf "    /mnt/target/etc/fstab\n"
printf "    /mnt/target/boot/grub/grub.conf\n\n"


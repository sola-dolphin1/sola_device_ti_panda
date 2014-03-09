#!/bin/sh
if [ $# -lt 2 ]; then
   echo "example usage: $0 /dev/sdc \$ANDROID_ROOT"
   exit 1
fi

DRIVE=$1
ANDROID_ROOT_DIR=$2

sudo umount ${DRIVE}*

sudo dd if=/dev/zero of=$DRIVE bs=1 count=1024
sudo sync
sudo parted $DRIVE mklabel gpt
sudo parted $DRIVE mkpart boot fat32 1MB 9MB
sudo parted $DRIVE mkpart system ext4 9MB 521MB
sudo parted $DRIVE mkpart cache ext4 521MB 1033MB
sudo parted $DRIVE mkpart userdata ext4 1033MB 2033MB
sudo parted $DRIVE mkpart media fat32 2033MB 3033MB
sudo sync

sudo mkfs.ext4 ${DRIVE}2 -L system
sudo mkfs.ext4 ${DRIVE}3 -L cache
sudo mkfs.ext4 ${DRIVE}4 -L userdata
sudo mkfs.vfat -F 32 ${DRIVE}5 -n media
sudo sync

sudo dd if=${ANDROID_ROOT_DIR}/device/ti/panda/xloader.bin of=$DRIVE bs=131072 seek=1
sudo sync
sudo dd if=${ANDROID_ROOT_DIR}/device/ti/panda/bootloader.bin of=$DRIVE bs=262144 seek=1
sudo sync
sudo dd if=${ANDROID_ROOT_DIR}/out/target/product/panda/boot.img of=${DRIVE}1
sudo sync
${ANDROID_ROOT_DIR}/out/host/linux-x86/bin/simg2img ${ANDROID_ROOT_DIR}/out/target/product/panda/system.img ${ANDROID_ROOT_DIR}/out/target/product/panda/system.ext4.img
sudo dd if=${ANDROID_ROOT_DIR}/out/target/product/panda/system.ext4.img of=${DRIVE}2
sudo sync
sudo e2label ${DRIVE}2 system
sudo sync


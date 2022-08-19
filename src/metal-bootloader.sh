#!/bin/bash

BOOTINFO=/etc/metal/boot-info.yaml

BOOTLOADERID=$(grep -oP '^bootloader_id: \K.*' $BOOTINFO)
if [ -z "$BOOTLOADERID" ]; then
    echo "bootloader_id not found in $BOOTINFO"
fi

BOOTNUM=$(efibootmgr | grep -oP "^Boot\K(\d+)(?=.*$BOOTLOADERID)")
if [ -z "$BOOTNUM" ]; then
    echo "bootnum for $BOOTLOADERID not found"
fi

if ! efibootmgr | grep -q "^BootCurrent: $BOOTNUM" ; then
    echo "Setting bootloader to $BOOTNUM ($BOOTLOADERID)"
    efibootmgr -n "$BOOTNUM"
fi

if ! efibootmgr | grep -q "^BootOrder: $BOOTNUM,"; then
    BOOTORDER=$(efibootmgr | grep -oP "^BootOrder: \K(.*)")
    echo "Setting bootloader to $BOOTNUM,$BOOTORDER"
    efibootmgr -D -o "$BOOTNUM,$BOOTORDER"
fi

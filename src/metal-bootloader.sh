#!/usr/bin/bash

BOOTINFO=/etc/metal/boot-info.yaml
BOOTLOADERID=$(grep -oP '^bootloader_id: \K.*' /tmp/boot-info.yaml)
BOOTNUM=$(grep -oP "^Boot\K(\d+)(?=.*$BOOTLOADERID)" $BOOTINFO)

if ! grep -q "^BootCurrent: $BOOTNUM" $BOOTINFO; then
    echo "Setting bootloader to $BOOTNUM ($BOOTLOADERID)"
    efibootmgr -n "$BOOTNUM"
    exit
fi

if ! grep -q "^BootOrder: $BOOTNUM," $BOOTINFO; then
    BOOTORDER=$(grep -oP "^BootOrder: \K(.*)" $BOOTINFO)
    echo "Setting bootloader to $BOOTNUM,$BOOTORDER"
    efibootmgr -o "$BOOTNUM,$BOOTORDER"
fi

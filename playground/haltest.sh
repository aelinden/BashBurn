#!/bin/bash

# hal-find-by-property  --key storage.drive_type --string cdrom

# Small program for listing all devices in the system matching a certain hal property.
# Below, removable block devices are listed. For BashBurn the hal query above might be
# useful.

#for line in $(hal-find-by-property  --key access_control.type --string removable-block); do
for line in $(hal-find-by-property --key storage.drive_type --string cdrom); do
 name=$(hal-get-property --udi $line --key storage.model)
 bdevice=$(hal-get-property --udi $line --key block.device)
 echo "$name : $bdevice"
done

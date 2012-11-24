#!/bin/bash

# Small script for listing devices in a system using udevadm.
# Below, removable block devices are listed.

for file in $(ls -x /dev/disk/by-uuid/*); do
 if [[ $(udevadm info --query=all --name="$file" | grep SUBSYSTEM= | cut -d '=' -f 2) -eq "block" ]]; then
   name=$(udevadm info --query=all --name="$file" | grep ID_MODEL= | cut -d '=' -f 2)
   bdevice=$(udevadm info --query=all --name="$file" | grep DEVNAME= | cut -d '=' -f 2)
   echo "$name : $bdevice"
 fi
done


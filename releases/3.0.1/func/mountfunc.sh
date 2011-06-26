mount_device()
{
    typeset bbdevice
    echo "$(grep '\(cdrom\|dvd\|cdrw\|cdwriter\)' /etc/fstab)"
    #grep cdrom /etc/fstab | sort && grep dvd /etc/fstab | sort
    echo; echo $bb_mnt_ch1_1
    echo $bb_mnt_ch1_2
    echo $bb_mnt_ch1_3
    echo $bb_mnt_ch1_4
    echo -n "|> "
    read -e bbdevice
    if [[ -z "${bbdevice}" ]]
    then
	message "$bb_mnt_ch1_5"
    else
	echo "$bb_mnt_ch1_6${bbdevice}..."
	if mount ${bbdevice} &> /dev/null	# FIXME:
	then
	    message "${bbdevice}$bb_mnt_ch1_7"
	else
	    message "$bb_mnt_ch1_8\n$bb_mnt_ch1_9\n$bb_mnt_ch1_10"
	fi
    fi
}

umount_device()
{
    typeset bbdevice
    if (( $(grep -c '\(cdrom\|dvd\|cdrw\|cdwriter\)' /etc/mtab) == 0 ))
    then
	echo $bb_mnt_ch2_1
    else
	echo "$(grep '\(cdrom\|dvd\|cdrw\|cdwriter\)' /etc/mtab)"
	echo -e "\n$bb_mnt_ch2_2"
	echo -n "|> "
	read -e bbdevice
	if umount ${bbdevice} &> /dev/null
	then
	    echo "${bbdevice}$bb_mnt_ch2_3"
	else
	    echo $bb_mnt_ch2_4
	    echo $bb_mnt_ch2_5
	fi
    fi
    wait_for_enter
}

eject_device()
{
    typeset bbdevice
    echo "$(grep '\(cdrom\|dvd\|cdrw\|cdwriter\)' /etc/fstab)"
    #grep cdrom /etc/fstab | sort && grep dvd /etc/fstab | sort
    echo $bb_mnt_ch3_1
    echo $bb_mnt_ch3_1b
    echo -n "|> "
    read -e bbdevice
    if [[ -z "$bbdevice" ]]
    then
	echo $bb_mnt_ch3_1c
    elif ${BB_EJECT} ${bbdevice} &> /dev/null
    then
	echo "${bbdevice}$bb_mnt_ch3_2"
    else
	echo $bb_mnt_ch3_3
	echo $bb_mnt_ch3_4
    fi
    wait_for_enter
}


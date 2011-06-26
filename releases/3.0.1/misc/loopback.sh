
# Directory names
typeset -r bb_lb_dir=/tmp/bb-loopback
typeset -r bb_im_copy_dir="/tmp/imagecopy"

#
# This file has functions for mounting an image file in a loopback
# device and edit its contents. After editing, a new image file
# is created containing the edited material.
#

# Remove temporary directories
loopback_cleanup()
{
    sudo umount "$bb_lb_dir"
    rm -rf "$bb_im_copy_dir"/*
}

loopback()
{
    typeset -r mntcmd="mount -t iso9660 -o loop $1 $bb_lb_dir"
    typeset answer
    # Bad filename?
    if [[ ! -r "$1" ]]
    then
	echo " \"$1\" $bb_lb_noread"
	return 100	# FIXME: HOLD ON THAR BULLWINKLE
    fi

     # Create necessary directories if possible
    if [[ ! -e "$bb_lb_dir" ]]
    then
	echo "$bb_lb_no_lb_dir"
	mkdir -p "$bb_lb_dir" || { echo "$bb_lb_dir_cf"; return 2; }
	echo "$bb_lb_dir_c"
    fi


    if [[ ! -e "$bb_im_copy_dir" ]]
    then
	echo "$bb_lb_no_im_dir"
	mkdir -p "$bb_im_copy_dir" || { echo "$bb_lb_dir_cf"; return 3; }
	echo "$bb_lb_dir_c"
    fi

    if [[ ! -e "${BBBURNDIR}" ]]
    then
	echo "$bb_lb_no_temp_dir"
	mkdir -p ${BBBURNDIR} || { echo "$bb_lb_dir_cf"; return 4; }
	echo "$bb_lb_dir_c"
    fi

    # Mount the CD image in a loopback device
    if [[ "$USER" != root ]]
    then
	echo "$bb_lb_sudo1"
	echo "$bb_lb_sudo2"
	echo "$bb_lb_sudo3"
	echo "$bb_lb_sudo4"
	echo "$bb_lb_sudo5"
	echo "$bb_lb_sudo6"
	sudo $mntcmd || { echo "$bb_lb_mount_fail"; return 5; }
	echo "$bb_lb_mount"
    else
	$mntcmd || { echo "$bb_lb_mount_fail"; 	return 6; }
    fi
    echo "$bb_lb_mount"

    # Copy contents from the mounted image to another directory and set
    # new permissions so its contents can be manipulated.
    echo "$bb_lb_cp_cont"
    cp -R "$bb_lb_dir"/* "$bb_im_copy_dir"
    chmod -R +w "$bb_im_copy_dir"

    # Change to new directory and start a shell session there
    cd "$bb_im_copy_dir"
    echo "$bb_lb_in_file"
    ${SHELL:-/bin/bash}

    # When user exits shell session, change to temporary file directory and
    # create new image file out of what user manipulated (If anything was).
    echo "$bb_lb_change1"
    echo "$bb_lb_change2"
    #echo -n "|> "
    #read answer
    read -e -p "|>" answer
    if [[ "$answer" == y ]]
    then
	# We want to make sure no data is deleted by mistake
	if [[ "$(ls -A ${BBBURNDIR})" ]];
	then
	    echo "$bb_lb_change3 \"${BBBURNDIR}\","
	    echo "$bb_lb_change4"
	    echo -n "$bb_lb_change5"
	    read -p "|>" answer
	    if [[ "$answer" == y ]]
	    then
		cd "${BBBURNDIR}"
		rm -rf "${BBBURNDIR}"/*
		echo "$bb_lb_change6"
		${BB_ISOCMD} -r -f -v -J -hide-joliet-trans-tbl \
			-o BashBurn.iso ${bb_im_copy_dir} \
		&& echo "$bb_lb_change7 \"${BBBURNDIR}\""
	    else
		echo "$bb_lb_change8"
		cleanup
	    fi
	fi 
    else
	echo "$bb_lb_change9"
    fi

    # Finally clean up our mess
    loopback_cleanup
    return 0
}

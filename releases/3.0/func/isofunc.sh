# This file contains functionality for ISO-file handling

# Check whether ISO files exist
check_for_iso()
{
    cd ${BBBURNDIR}
    (( $(find ${BBBURNDIR} -iname '*.iso' | wc -l) == 0 ))
}

create_iso_from_cd()
{
    # Does an ISO file exist?
    if check_for_iso
    then
	echo "$bb_im_ch3_2${BBCDROM}"
	if ${BB_READCD} ${BB_READ_OPTS} -o ${BBBURNDIR}/BashBurn.iso ${BBCDMNT}
	then
	    echo $bb_im_ch2_5
	else
	    echo -e "$bb_im_ch2_6\n$bb_im_ch2_7"
	fi
    else
	echo -e "$bb_im_ch2_1${BBBURNDIR}.$bb_im_ch2_2\n$bb_im_ch2_3"
    fi
    wait_for_enter
}

mount_in_loopback()
{
    typeset bb_image_path
    echo "$bb_im_ch5_1\n$bb_im_ch5_2"
    read -e -p '|> ' bb_image_path
    if [[ -z "$bb_image_path" ]]
    then
	echo "$bb_im_ch5_3"
    else
	loopback "$bb_image_path"
    fi
    wait_for_enter
}

create_iso_from_dir()
{
    if is_dir_empty ${BBBURNDIR}
    then
	echo "$bb_im_error_files $BBBURNDIR"
    else
	# Does an ISO file exist?
	if check_for_iso
	then
	    # Creating ISO from files
	    echo -e "\n$bb_im_ch2_4"
	    #### i want a question regarding the BBLABEL ####
	    [[ "$BBLABEL" == "<ask-me>" ]] && read -e -p "$bb_im_ch2_4b" BBLABEL
	    if ${BB_ISOCMD} -r -f -v -J \
		    -hide-joliet-trans-tbl -A "$BBDESCRIPTION" \
		    -p "$BBAUTHOR" -V "$BBLABEL" \
		    -o ${BBBURNDIR}/BashBurn.iso ${BBBURNDIR}
	    then
		echo $bb_im_ch2_5
	    else    #Some error occured
		echo -e "$bb_im_ch2_6\n$bb_im_ch2_7"
	    fi
	else
	    echo -e "$bb_im_ch2_1${BBBURNDIR}.$bb_im_ch2_2\n$bb_im_ch2_3"
	fi
    fi
    wait_for_enter
}

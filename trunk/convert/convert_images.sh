convert_images()
{
    typeset yesno
    typeset -i filecount=0
    typeset filetype="$1"
    shopt -s nocaseglob

    if ! check_for "$filetype"
    then
	message "$bb_conv_img_copied3a ${BBBURNDIR} $bb_conv_img_copied3b"
    else
	if [[ "$filetype" == '*.nrg' ]] 
	then
	    typeset bbnrgfile
	    while read bbnrgfile
	    do
		echo
		if ${BB_NRG2ISO} "${bbnrgfile}" "${bbnrgfile}.iso"
		then
		    echo "${bbnrgfile}: $bb_conv_img1"
		    ((filecount++))
		else
		    echo "${bbnrgfile}: $bb_conv_img2"
		fi
		echo
	    done < <(find ${BBBURNDIR} -iname '*.nrg')
	    sleep 2s
        #elif [[ "$filetype" == '*.weirdformat' ]]
        #then
	     # Add converting other formats here in the future
	     # ${BB_IMAGE_CONVERT} *.weirdformat
	     #message "$bb_conv_ogg"
	fi
    fi
    shopt -u nocaseglob
}

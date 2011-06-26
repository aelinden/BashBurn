# A function to check if overburn is enabled
check_overburn()
{
    if [[ "${BBOVERBURN}" = yes ]]
    then	# Is overburn enabled?
	BBOBURN=-overburn		# yes it was
    else
	echo $bb_no_ob			# No it wasn't
	BBOBURN=
    fi
}

# A function to see if files in temp dir should be deleted after burning is done
check_tempdel()
{
    typeset str="$bb_burning_tmp_1 ${BBBURNDIR}"

    if [[ "${BBDELTEMPBURN}" = yes ]]
    then
	rm -rf "${BBBURNDIR}"/*
	str="$str $bb_burning_tmp_1b"
    else
	str="$str $bb_burning_tmp_2"
    fi
    echo "$str"
}

set_session_type()
{
    typeset session_answer
    # Return 0 for yes
    # Return 1 for no
    # Return 2 for else
    cat <<EOF
$bb_burning_dvd_1
$bb_burning_dvd_2
$bb_burning_dvd_3
$bb_burning_dvd_4

EOF
    read -e -p "$bb_burning_dvd_5" session_answer
    case "$session_answer" in
    yes)
	return 0
	;;
    no)
	return 1
	;;
    *)
	return 2
	;;
    esac
}

################################ AUDIO #################################

_burning()
{
    typeset audio
    # HACK option processing. FIXME:
    if [[ "$1" == -a ]]
    then 
	audio=-audio
	shift
    fi

    # HACK to get driveroptions to work. FIXME
    # FIXME: Also, if you modify the variable then it will only work once.
    # The second time through, you'll change the value to
    # driveropts=driveropts=$BBDRIVEROPT
    BBDRIVEROPT=${BBDRIVEROPT:+driveropts="$BBDRIVEROPT"}

    # Check if CD is already written to
    if check_cd_status
    then
	ask_for_blanking && doit=1
    else
	doit=1
    fi
    if (( doit ))
    then
	if ${BB_CDBURNCMD} dev=${BBCDWRITER} speed=${BBSPEED} \
		${BBDTAO} ${BBDRIVEROPT} \
		$audio ${BBPADDING} -eject -v ${BBOBURN} "$@"
	then		#Burn audio cd
	    echo -e "\n$bb_burning_finish_1"
	    check_tempdel
	else
	    echo "$bb_burning_finish_2"
	    return 1
	fi
    fi
    return 0
}

# a function to burn audio cds.
# it looks for wav-files in the BBBURNDIR (/tmp/burn/)..
audio_burning()
{
    if ! check_for_wavs
    then
	echo -e "\n$bb_burning_audio_2 ${BBBURNDIR}"
    else
	shopt -s nocaseglob
        echo -e "*.wav being used..."
	if [[ "${BBNORMALIZE}" = yes ]]
	then
	    cd "${BBBURNDIR}"
	    ${BB_NORMCMD} -m *.wav
	else
	    echo $bb_burning_audio_3
	fi
	check_overburn		# Overburn enabled?
	_burning *.wav
	shopt -u nocaseglob
    fi
    wait_for_enter
}

################################# ISO ###################################

# to burn a .iso-file in the BURNDIR.
iso_burning()
{
    typeset imagetype
    if ! is_dir_empty ${BBBURNDIR}
    then
	check_overburn
	# Check for type of image, iso or img supported
	if [[ -n $(find ${BBBURNDIR} -iname '*.iso') ]]
	then
	    imagetype=iso
	elif [[ -n $(find ${BBBURNDIR} -iname '*.img') ]]
	then
	    imagetype=img
	else
	    message \
	"$bb_burning_error ${BBBURNDIR} *.iso or *.img file[s] not found?"
	    datadefine
	    return 0
	fi
	# Check if CD is already written to
	if ! _burning ${BBBURNDIR}/*.$imagetype
	then
	    echo "$bb_burning_finish_3 ${BBBURNDIR} ?"
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
    fi
}

################# DVD Image #########################################

# DVD support. Not as well tested as CD-burning, but should work just fine.

dvd_image_burn()
{
    typeset imagetype
    if ! is_dir_empty ${BBBURNDIR}
    then
	check_overburn
	# Check for type of image, iso or img supported
	if [[ -n $(find ${BBBURNDIR} -iname '*iso') ]]
	then
	    imagetype=iso
	elif [[ -n $(find ${BBBURNDIR} -iname '*img') ]]
	then
	    imagetype=img
	else
	    message \
	"$bb_burning_error ${BBBURNDIR}  *.iso or *.img file[s] not found?"
	    datadefine
	    return 0
	fi
	# check_cd_status	# FIXME: Why check? if CD is already written to
	
	# FIXME: This is wrong.
	if ${BB_DVDBURNCMD} -dvd-compat \
	    -Z ${BBCDWRITER}=${BBBURNDIR}/$(ls ${BBBURNDIR} | grep -i $imagetype)
	then
	    echo -e "\n$bb_burning_finish_1"
	    check_tempdel
	else
	    echo $bb_burning_finish_2
	    echo "$bb_burning_finish_3 ${BBBURNDIR} ?"
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
    fi
    wait_for_enter
}

################################### DATA ##################################

# This is a function to burn all files in /tmp/burn/ as a data-CD.
# It checks whether folder is empty, and if not creates an ISO from its
# contents and burns it. It does NOT check if the folder contains an ISO
# anymore. If it does, it creates an ISO containing an ISO and burns it.
# This is due to lots of people wanting this functionality. 

data_burning()
{
    if ! is_dir_empty ${BBBURNDIR}
    then
	#### i want a question regarding the BBLABEL ####
	[[ "$BBLABEL" == '<ask-me>' ]] && read -e -p "$bb_burning_data_label" \
						BBLABEL
	if ${BB_ISOCMD} -r -f -v -J -joliet-long \
		-A "$BBDESCRIPTION" -p "$BBAUTHOR" -V "$BBLABEL" \
		-o ${BBBURNDIR}/BashBurn.iso ${BBBURNDIR}
	then
	    iso_burning			# call function - declared above
	else
	    echo $bb_burning_data_2
	    echo $bb_burning_data_3
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
    fi
    wait_for_enter
}

################################### DVD Data #############################

# Preliminary DVD support. Not very well tested, use at your own risk.
# (However I do believe it should work as planned.)
# Better support will come in time.

dvd_data_burning()
{
    typeset -i status
    typeset bb_dvdsession

    if ! is_dir_empty ${BBBURNDIR}
    then
   	[[ "$BBLABEL" == '<ask-me>' ]] && read -e -p "$bb_burning_data_label" \
						BBLABEL
	set_session_type
	status=$?
	case $status in
	0)
	    bb_dvdsession=-Z
	    ;;
	1)
	    bb_dvdsession=-M
	    ;;
	*)
	    return
	    ;;
	esac
	# FIXME: This is commented out because it doesn't do anything.
	# check_cd_status		# Check if CD is already written to
	if ${BB_DVDBURNCMD} $bb_dvdsession ${BBCDWRITER} -r -f \
		-v -J -joliet-long -A "$BBDESCRIPTION" -p "$BBAUTHOR" \
		-V "$BBLABEL" ${BBBURNDIR}
	then
	    echo $bb_burning_finish_1
	else
	    echo $bb_burning_finish_2
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
    fi
    wait_for_enter
}

################################## DVD blank ##############################

set_blanking_dvd()
{
    typeset blanking_answer
    cat <<EOF
$bb_dvd_blank1
$bb_dvd_blank2
$bb_dvd_blank3
$bb_dvd_blank4
$bb_dvd_blank5

EOF
    read -e -p '(yes/no):' blanking_answer
    case "$blanking_answer" in
    yes)
	return 0
	;;
    no)
	return 1
	;;
    *)
	return 2
	;;
    esac
}

dvd_blanking()
{
    typeset -i status
    typeset blank
    set_blanking_dvd
    status=$?
    case $status in
    0)
	blank=-blank
	;;
    1)
	blank=-blank=full
	;;
    2)
	return
	;;
    esac
    if ${BB_DVDBLANK} $blank} ${BBCDWRITER}
    then
	echo $bb_cdrw_blank2
    else
	echo $bb_cdrw_blank5
    fi
    wait_for_enter
}
	    
################################## PIPELINE ##############################

# A function to do direct audio burning without creating wavs. This is
# butt ugly and might be removed or rewritten at one point. 

pipeline_burning()
{
    typeset -i counter=0
    typeset -i doit=0
    typeset fifolst=
    typeset commandlst=
    typeset fifo
    typeset file
    typeset pfile
    shopt -s nocaseglob

    if ! check_for_mp3s
    then
   	message "\n$bb_burning_audio_2 ${BBBURNDIR}"
    else
 	#fifo counter set to 0
	while read file
	do
	    if [[ ${file} =~ .MP3 ]]
	    then
		counter=counter+1
		fifo="${BBFIFODIR}/FIFO$$-${counter}"
		fifolst="${fifolst} ${fifo}"
		commandlst="${commandlst} -audio ${fifo}"
		mknod ${fifo} p; #equivalent to mkfifo $fifo
		${BB_MP3DEC} -qs "${file}" > ${fifo} &
		pfile=${file##*/}
		echo "${counter-MP3} ${pfile:0:35} flushed into ${fifo} (pipe)."
	    elif [[ ${file} =~ .WAV ]]
	    then
		counter=counter+1
		fifo="${BBFIFODIR}/FILE$$-${counter}.wav"
		fifolst="${fifolst} ${fifo}"
		ln -s "${file}" ${fifo}
		commandlst="${commandlst} -audio ${fifo}"
		pfile=${file##*/}
		echo "${counter-WAV} ${pfile:0:35}."
	    fi
	done < <(find ${BBBURNDIR} -iname \*.mp3 -o -iname \*.wav)
	
	(( counter == 0 )) && message "$bb_burning_fifo_1 ${BBBURNDIR}"
	echo "$bb_burning_fifo_2 ${counter} $bb_burning_fifo_2b"
	# Check if CD is already written to
	if check_cd_status
	then
	    ask_for_blanking && doit=1
	else
	    doit=1
	fi
	if (( doit ))
	then
	    ${BB_CDBURNCMD} dev=${BBCDWRITER} speed=${BBSPEED} \
		    ${BBDTAO} ${BBOPT_DRIVER:+"driver=$BBOPT_DRIVER"} \
		    fs=16m -swab -audio ${BBPADDING} -eject -v ${BBOBURN} \
		    ${commandlst}
	    echo $bb_burning_fifo_3
	    [[ -z "$fifolst" ]] || rm ${fifolst}
	    check_tempdel
	fi
    fi
    shopt -u nocaseglob
}
    
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
burning ()
{
    case "$1" in
    "--audio")
	audio_burning
	;;
    "--data")
	data_burning
	;;
    "--dvddata")
	dvd_data_burning
	;;
    "--dvdblank")
	dvd_blanking
	;;
    "--dvdimage")
	dvd_image_burn
	;;
    "--iso")
	iso_burning
	;;
    "--pipeline")
        pipeline_burning
	;;
    esac
}


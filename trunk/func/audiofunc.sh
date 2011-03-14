# This file contains the functionality for audio CD burning

# This function lets you swap cds if you only have one device.
# (CDwriter and CDreader is same device.)

# Slightly rewritten for cdparanoia instead of cdda2wav
insert_new_CD()
{
    typeset temp
    while true
    do
	read -e -p "$bb_am_enter_2" temp
	[[ -z "$temp" ]] && break
    done
}

convert_if_exist()
{
    typeset filetype="$1"

    cd ${BBBURNDIR}
    if check_for "$filetype"
    then
	echo -e "$filetype being used..."
	convert_audio "$filetype"
    else
	echo -e "No $filetype audio files found"
    fi
}

# A function that adjusts the volume of wav
# audio files to a standard volume level.
normalization()
{
    if [[ "$BBNORMALIZE" = yes ]]
    then
	cd ${BBBURNDIR}
	for i in *.wav
	do
	    echo -e \
		"\n${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_norm_1$i...${BBCOLOROFF}"
	    ${BB_NORMCMD} -v -m "$i"
	done
    fi
}

# Function that validates the input of "y" or "n".
conf_yes_no()
{
    typeset answer
    while [[ "${answer}" != y && "${answer}" != n ]]
    do 
	read -e -n 1 -p "$bb_am_conf_2" answer
    done
    [[ "$answer" == y ]]
}

# Function that controls errors.
conf_error()
{
    typeset -i stderror=$1
    # If there is any error return to main menu.
    if (( stderror != 0 ))
    then
	message "${BBTABLECOLOR}$bb_am_err_1${BBCOLOROFF}"
	return 1
    fi
    return 0
}

# Simple function that validates confirmation of song names.
confirmation()
{
    typeset -i answer=0
    echo
    [[ -f "${BBBURNDIR}/song_name.txt" ]] || return 1
    echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_am_conf_1${BBCOLOROFF}"
    cat -n ${BBBURNDIR}/song_name.txt
    echo -e "${BBSUBCOLOR}"
    conf_yes_no || answer=1
    echo -e "${BBCOLOROFF}"	  
    (( answer == 1 )) && rm -f ${BBBURNDIR}/song_name.txt ${BBBURNDIR}/tracks.txt
    return 0
}

# Function for interactive naming of files.
named()
{
    typeset track
    typeset song_name
    typeset number_track
    typeset -r funky_chars=$'[()?\277*\/&]'
    typeset funky_gone
    # Delete old lists of songs rip.
    rm -f ${BBBURNDIR}/*.txt	  
    # Show some info
    message "${BBSUBCOLOR}$bb_am_named_1${BBCOLOROFF}"
    ${BB_CDAUDIORIP} -d ${BBCDROM} -vQ
    # If there is any error return to main menu.
    conf_error $? || return
    track=1
    cat <<'EOF'
You will now be asked for track numbers and track names.
Track names will default if not supplied.
EOF
    echo -e "\n${BBMAINCOLOR}$bb_am_named_4\n${BBMAINCOLOR}$bb_am_named_5"
    while [[ -n "${track}" ]]
    do
	printf "\n%b$bb_am_named_2 %b$bb_am_named_3%b|>%b " \
	"${BBMAINCOLOR}" "${BBMAINCOLOR}" "${BBTABLECOLOR}" "${BBCOLOROFF}"
	read -e track
	[[ -z "$track" ]] && continue
        # Only permit integer numbers standing the format
	# in the numbers of back prompt.
	# FIXME: This does not gurantee that track is an integer value
	number_track=$(printf '%02d' ${track})
	# This line puts track numbers of the input standard
	# into tracks.txt.	
	echo "${number_track}" >> ${BBBURNDIR}/tracks.txt
	printf "$bb_am_named_6${number_track} %b|>%b " \
		${BBTABLECOLOR} ${BBCOLOROFF}
	read -e song_name

	# If the song_name variable = space blank then, change  
	# fill that with the number of the track to ripped.
	if [[ -z "${song_name}" ]]
	then 
	    song_name="${number_track}.-Track"
	else
	    # If the song_name variable contained some signs and
	    # characters specials, 
	    # that difficulty the naming in bash shell, to be equal to nothing.
	    # Read sed man page to see how it work.
	    # Change by Casper
	    # Steveo here: 
	    # This used to be                    's/[()?¿*\/&]//g'
	    # When I analysed it, I saw that the funny upside down questionmark
	    # was an octal 277. So I changed it to native proper
	    # quoted bash notation, i.e., $'stuff' and switched in 277.
	    # They are equivalent, but the reason for switching is because 
	    # what gets displayed to the person looking at the src code 
	    # depends on the type of terminal emulator that is used.
	    funky_gone="${song_name//$funky_chars}"
	    song_name="$funky_gone"
	fi

	# Delete temporary file and add song name to a text file
	echo ${song_name} >> ${BBBURNDIR}/song_name.txt
    done
}

# Function rip the tracks or songs selects.
rip()
{
    proc_file()
    {
	typeset var=$1
	typeset fni=$2
	typeset fno=$3
	typeset -i first=1

	while read line
	do
	    if (( first ))
	    then
		eval "$var=\"${line}.wav\""
		first=0
	    else
		echo "$line"
	    fi
	done < $fni > $fno
    }

    typeset line
    typeset track=0	
    typeset song_name
    confirmation || return 1
    cd ${BBBURNDIR}
    while [[ -n "${track}" ]]
    do
  	# Read the track to rip of the files in temp directory.
	read track < ${BBBURNDIR}/tracks.txt
	if [[ -n "${track}" ]]
	then
	    echo -e \
	"${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_rip_1${track}...${BBCOLOROFF}"
	    # Begin Rip.	
	    ${BB_CDAUDIORIP} -d ${BBCDROM} ${track} ${track}.wav
	    proc_file track tracks.txt temp_tracks.txt
	    proc_file song_name song_name.txt temp_song.txt
	    # Rename the tracks that have been ripped, by the name 
	    # get back by users in prompt.
	    mv "${track}" "${song_name}"

	    # Remove the song that has been ripped. 
	    mv ${BBBURNDIR}/temp_song.txt ${BBBURNDIR}/song_name.txt
	    mv ${BBBURNDIR}/temp_tracks.txt ${BBBURNDIR}/tracks.txt
	fi
    done
    # Remove temp files.
    rm -f ${BBBURNDIR}/tracks.txt ${BBBURNDIR}/song_name.txt ${BBBURNDIR}/*.inf
    eject ${BBCDROM}
    message "${BBSUBCOLOR}$bb_am_rip_2${BBCOLOROFF}"
    return 0
}

# Function Encode Filter Command.
encode_filter()
{
    typeset format=$1
    if [[ -n "$ENCODEFILTER" ]]
    then
	echo -e \
    "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_encfilt(${ENCODEFILTER})${BBCOLOROFF}"
	eval ${ENCODEFILTER} ${BBBURNDIR}/*.${format}
    fi			
}

# CD copying
copy_audio_cd()
{
    # Copy an audio cd.
    cd ${BBBURNDIR}
    # if ${BB_CDAUDIORIP} -D ${BBCDROM} -v all -B -Owav; then
    if ${BB_CDAUDIORIP} -d ${BBCDROM} -B
    then
	eject ${BBCDROM}
	echo $bb_am_rip_2
	# Normalize WAV's.
	normalization 
	# Check number of devices
	(( BBNUMDEV == 1 )) && insert_new_CD
	# burnlist= should be set using caseglob and nullglob
	if ${BB_CDBURNCMD} -v dev=${BBCDWRITER} \
		speed=${BBSPEED} ${BBDRIVEROPT:+"driveropts=$BBDRIVEROPT"} \
		${BBDTAO} ${BBPADDING} \
		-useinfo ${BBBURNDIR}/*.[Ww][Aa][Vv]
	then
	    message "$bb_am_ch3_1"
	else
	    message "$bb_am_ch3_2"
	fi
    else
	message "$bb_am_ch3_3${BBCDROM}"
    fi
}

# Copy an audio cd to HD
copy_cd_to_hd()
{
    cd ${BBBURNDIR}
    # ${BB_CDAUDIORIP} -D ${BBCDROM} -v all -B -Owav
    ${BB_CDAUDIORIP} -d ${BBCDROM} -B
    eject ${BBCDROM}
	  
    # Normalize WAV's.
    normalization
	  
    message "$bb_am_ch4_1${BBBURNDIR}.$bb_am_ch4_2
$bb_am_ch4_3"
}

create_xxx_from_wavs()
{
    # Very sneaky stuff going on here. cmd is passed in but it refers to file.
    # file is a variable in the loop in here.
    typeset cmd="$1"
    typeset fmt=$2
    typeset file
    typeset cmd_was_executed=0

    cd ${BBBURNDIR}
    while read file
    do
	eval $cmd
	cmd_was_executed=1
    done < <(find . -iname "*.wav")

    if (( cmd_was_executed ))
    then
	# Encode Filter Command. 
	encode_filter $fmt
    else
	message "\n$bb_am_ch6_3${BBBURNDIR}"
    fi
}

# Create Mp3s from Wavs in BURNDIR (Is this comment _REALLY_ necessary?)
create_mp3s_from_wavs()
{
    create_xxx_from_wavs \
	    '${BB_MP3ENC} --preset cd "${file}" "${file%%wav}mp3"' \
	    mp3
}

#Create Oggs from Wavs in BURNDIR
create_oggs_from_wavs()
{
    create_xxx_from_wavs \
	    '${BB_OGGENC} -b ${BBBITRATE} "${file}"' \
	    ogg
}

# Create flacs from Wavs in BURNDIR
create_flacs_from_wavs()
{
    create_xxx_from_wavs \
	    '${BB_FLACCMD} -b ${BBBITRATE} "${file}"' \
	    flac
}

create_xx_from_cd()
{
    typeset cmd="$1"
    typeset resultstr="$2"
    typeset file
    typeset cmd_was_executed=0
    # First, name and rip the tracks
    # Give name to the tracks.
    named
    # Rip the tracks in wav audio file.
    rip || return
    # Normalize WAV's.
    normalization
    # Now create the Mp3s

    while read file
    do
	eval $cmd
	cmd_was_executed=1
    done < <(find . -iname "*.wav")

    if (( cmd_was_executed ))
    then
	# Encode Filter Command. 
	encode_filter mp3
    else
	message "\n$bb_am_ch6_3${BBBURNDIR}"
    fi
	
    message "${resultstr}${BBURNDIR}"
    shopt -s nocaseglob
    rm ${BBBURNDIR}/*.wav
    shopt -u nocaseglob
}


# Create Mp3s from an audio cd.
create_mp3s_from_cd()
{
    create_xx_from_cd \
	    '${BB_MP3ENC} --preset cd "${file}" "${file%%.wav}.mp3"' \
	    "$bb_am_ch9_2${BBBURNDIR}"
}

# Create Oggs from an audio cd.
create_oggs_from_cd()
{
    create_xx_from_cd \
	    '${BB_OGGENC} -b ${BBBITRATE} "${file}"' \
	    "$bb_am_ch10_2${BBBURNDIR}"
}

# Create flacs from cd
create_flacs_from_cd()
{
    create_xx_from_cd \
	    '${BB_FLACCMD} "${file}"' \
	    "$bb_am_ch11_1${BBBURNDIR}"
}

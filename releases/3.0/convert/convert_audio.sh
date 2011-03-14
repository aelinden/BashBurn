convert_audio()
{
    typeset filetype="$1"
    shopt -s nocaseglob
    if [[ "$filetype" == '*.flac' ]]
    then
	${BB_FLACCMD} -d *.flac
	message "$bb_conv_flac_1"
    elif [[ "$filetype" == '*.mp3' ]]
    then
	typeset bbmpthree
	while read bbmpthree
	do
	    echo
	    if ${BB_MP3DEC} -r 44100 -w "${bbmpthree%%.mp3}.wav" "${bbmpthree}"
	    then
		echo "${bbmpthree}: $bb_conv_mp3_1 (${bbmpthree%%.mp3}.wav) $bb_conv_mp3_2"
	    else
		echo "${bbmpthree}: $bb_conv_mp3_3"
	    fi
	    echo
	done < <(find ${BBBURNDIR} -iname '*.mp3')
	sleep 2s
    elif [[ "$filetype" == '*.ogg' ]]
    then
	${BB_OGGDEC} *.ogg
	message "$bb_conv_ogg"
    fi
    shopt -u nocaseglob
}

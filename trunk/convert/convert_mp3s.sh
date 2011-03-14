convert_mp3s()
{
    typeset bbmpthree
    cd ${BBBURNDIR}
    while read bbmpthree
    do
	echo
	if ${BB_MP3DEC} -r 44100 -w "${BBMPTHREE%%.mp3}.wav" "${BBMPTHREE}"
	then
	    echo "${bbmpthree}: $bb_conv_mp3_1 (${bbmpthree%%.mp3}.wav) $bb_conv_mp3_2"
	else
	    echo "${bbmpthree}: $bb_conv_mp3_3"
	fi
	echo
    done < <(find ${BBBURNDIR} -iname '*.mp3')
    sleep 2s
}

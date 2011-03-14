burn_bincue()
{
    typeset bbspeed
    # cdrdao does not like speed being set to -1
    (( "${BBSPEED}" -eq -1 )) && bbspeed=8 || bbspeed=$BBSPEED

    shopt -s nocaseglob
    if ${BB_CDIMAGECMD} write --device \"${BBCDWRITER}\" \
	    --driver generic-mmc --speed \"${bbspeed}\" \
	    -v 2 --eject \
	    "${BBBURNDIR}"/$(ls \"${BBBURNDIR}\" | grep cue)
    then
	echo $bb_bincue_burn_1
    else
	echo $bb_bincue_burn_2
    fi
    shopt -u nocaseglob
    wait_for_enter
}

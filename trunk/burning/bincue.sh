bincue()
{
    typeset yesno
    typeset -i doit=0

    #echo "$bb_bincue_copy_1 ${BBBURNDIR} $bb_bincue_copy_1b"
    #read -e -n 1 -p "$bb_bincue_copy_2" yesno
    #if [[ "${yesno}" == n ]]

    # Replaced above code with two simple checks
    # If bin and cue file does not exist, return to menu
    if ! check_for *.bin && ! check_for *.cue
    then
	message "$bb_bincue_copy_3 ${BBBURNDIR} $bb_bincue_copy_3b"
    else
	# Check if CD is already written to
	if check_cd_status
	then 
	    ask_for_blanking && doit=1
	else
	    doit=1
	fi
	(( doit )) && burn_bincue		# Burn bin/cue if possible
    fi
}


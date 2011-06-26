# This file contains the functionality for multisession burning

burn_function()
{
    typeset multi=$1
    # Burn the created ISO-file
    shopt -s nocaseglob
    # FIXME: This is evil. We should not be using globbing here.
    # This should be a specified list.
    ${BB_CDBURNCMD} $multi dev="$BBCDWRITER" speed="$BBSPEED" \
	    ${BBPADDING} ${BBDRIVEROPT:+"driveropts=$BBDRIVEROPT"} \
	    -eject -v "$BBBURNDIR"/*.iso
    shopt -u nocaseglob
    echo $bb_multi_burn_5
}

burn_multi()
{
    # Call this with the -m option if this is a multisession
    # Required arg 1 is to be assigned to bb_get_prev_session.
    # Legal values are 0 or 1.
    # FIXEM: Add more arg checking.
    typeset -i seen_m=0
    typeset opt
    typeset OPTIND
    typeset -i bbget_prev_session
    typeset isocmd

    typeset multi=
    typeset bbmsinfodata

    while getopts :m opt "$@"
    do
	case ${opt} in
	m)
	    (( seen_m == 1 )) && usage || seen_m=1
	    ;;
	
	h | *)
	    # usage		# FIXME:
	    echo 'Improper option to burn_multi' 1>&2
	    return 1
	    ;;
	esac
    done
    shift $(( OPTIND - 1 ))
    bbget_prev_session=$1
    (( seen_m )) && multi=-multi

    #Does an ISO-file exist?
    if [[ -n "$(find ${BBBURNDIR} -iname '*.iso')" ]]
    then
         # Yes it did
	cat <<EOF
$bb_multi_burn_1
$bb_multi_burn_2
$bb_multi_burn_3
$bb_multi_burn_4
EOF
	burn_function $multi
    else
	# An ISO did not exist, we attempt to create one
	echo $bb_multi_burn_6
	if (( bbget_prev_session == 0 ))
	then
	    # First session, no need to get -msinfo data
	    message "\n$bb_multi_burn_13"
	    isocmd="$BB_ISOCMD"
	else
	    bbmsinfodata=$($BB_CDBURNCMD dev=$BBCDWRITER -msinfo)
	    # echo "bbmsinfodata: $bbmsinfodata"
	    isocmd="$BB_ISOCMD -C \"$bbmsinfodata\" -M $BBCDWRITER"
	fi
	  
	echo -e "\n$bb_multi_burn_14"
	#### i want a question regarding the BBLABEL ####
	[[ "$BBLABEL" == "<ask-me>" ]] && read -ep "$bb_multi_burn_14b" BBLABEL
	# Create the ISO
	if $isocmd -r -f -v -J -hide-joliet-trans-tbl \
		-A "$BBDESCRIPTION" -p "$BBAUTHOR" -V "$BBLABEL" \
		-o "$BBBURNDIR"/BashBurn.iso "$BBBURNDIR"
	then 
	    echo $bb_multi_burn_15
	    burn_function $multi
	else
            # Something went wrong. CD isn't burnt.
	    echo $bb_multi_burn_16
	    echo "$bb_multi_burn_17 ${BBBURNDIR}"
	    echo $bb_multi_burn_18
	fi
    fi
    wait_for_enter
}


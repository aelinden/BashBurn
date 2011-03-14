typeset -i bb_not_found_apps	# Must be at least file global scope.
i_check_path()
{
    typeset program
    typeset tmpfn=$1
    shift
    # Function that check the paths of applications 
    # used for BashBurn.
    for program in "$@"
    do
	if which ${program} > $tmpfn 2>&1
	then
	    echo -e \
"\t${program} ${BBSUBCOLOR} $bb_cp_1 ${BBCOLOROFF} $bb_cp_2 $(< $tmpfn)"
	else
	    echo -e \
"\t${program} ${BBTABLECOLOR} $bb_cp_3 ${BBCOLOROFF} $bb_cp_4"
	    bb_not_found_apps=1 # Flag an app is missing
	fi
    done
}

check_path()
{
    # Some variables
    typeset -a BBBURNING
    typeset -a BBRIPPERS
    typeset -a BBXCODERS
    typeset -a BBMISC
    typeset tempfn=/tmp/bb_check_path.$$

    BBBURNING=( \
	    ${BB_CDIMAGECMD} \
	    ${BB_CDBURNCMD} \
	    ${BB_ISOCMD} \
	    ${BB_DVDBURNCMD} \
	    )
    BBRIPPERS=( ${BB_CDAUDIORIP} ${BB_READCD} )
    BBXCODERS=( ${BB_MP3ENC} ${BB_OGGENC} ${BB_OGGDEC} ${BB_FLACCMD} )
    BBMISC=( ${BB_EJECT} ${BB_NORMCMD} ${BB_MP3DEC} sudo ${BB_NRG2ISO} )

    bb_not_found_apps=0
    pretty_top
    dashed_line
    echo -e "${BBTABLECOLOR}${BBSUBCOLOR}$bb_cp_5"
    top_info_line
    echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_cp_6${BBCOLOROFF}"
    i_check_path $tempfn "${BBBURNING[@]}"
    echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_cp_7${BBCOLOROFF}"
    i_check_path $tempfn "${BBRIPPERS[@]}"
    echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_cp_8${BBCOLOROFF}"
    i_check_path $tempfn "${BBXCODERS[@]}"
    echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_cp_9${BBCOLOROFF}"
    i_check_path $tempfn "${BBMISC[@]}"
    echo

    # Only output this if some apps were not found.
    # We don't want to scare people unless necessary :-)
    if (( bb_not_found_apps )) 
    then
	top_info_line
	echo -e "${BBHEADCOLOR}$bb_cp_10\n$bb_cp_11${BBCOLOROFF}"
        dashed_line
    fi
	message

    rm $tempfn
}

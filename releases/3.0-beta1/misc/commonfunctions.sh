# This file contains common functions used in
# several files.

# Pretty header
pretty_top()
{
    clear
    echo -e "${BBTABLECOLOR}${BBDECOLINE}
${BBTABLECOLOR}|${BBHEADCOLOR} ${BBVERSION} ${BBTABLECOLOR}|
${BBTABLECOLOR}${BBDECOLINE}
${BBTABLECOLOR}|${BBCOLOROFF}"
}

# Top and bottom dashed lines for Information
top_info_line()
{
    echo -e "${BBTABLECOLOR}${BBDECOLINE}${BBSUBCOLOR} \
INFORMATION ${BBTABLECOLOR}${BBDECOLINE}${BBCOLOROFF}"
}

dashed_line()
{
    echo -e "${BBTABLECOLOR}${BBDECOLINE}\
-------------${BBDECOLINE}${BBCOLOROFF}"
}

# Check if directory is empty
is_dir_empty()
{
    # Use -A to count dot files but not . and ..
    # Returns success (0) if empty
    (( $(ls -1A $1 | wc -l) == 0 ))
}

# Wait for a keypress
wait_for_enter()
{
    typeset response
    read -n 1 -p "$bb_hit_any_key_to_continue : " response
    errmsg
}

message()
{
    # Print a message to stderr and wait for the user
    # to respond with a keypress.
    typeset msg="$@"

    errmsg "$msg"
    wait_for_enter
}


# Function to check whether CD is blank or not
check_cd_status()
{
    # Returns 0 if USED, otherwise (BLANK) return 1 
    dd if=${BBCDWRITER} of=/dev/null bs=1 count=1 > /dev/null 2>&1
}

# Function to blank CD
blank_cd()
{
    typeset -i ret=0
    typeset str
    typeset cmd="${BB_CDBURNCMD} -v dev=${BBCDWRITER} \
	blank=${BBBLANKING} speed=${BBSPEED}"
    echo $bb_cdrw_blank1
    if $cmd
    then
	message "$bb_cdrw_blank2"
    else
	# Forced blanking
	echo $bb_cdrw_blank3
	if $cmd -force
	then
	    str="$bb_cdrw_blank4"
	else
	    str="$bb_cdrw_blank5"
	    ret=1
	fi
	message "$str"
    fi
    return $ret
}

ask_for_blanking()
{
    # Only call this if the cd is used.
    typeset -i blank_failed=0
    typeset choice
    echo $bb_cf_text1
    echo $bb_cf_text2
    echo $bb_cf_text3
    read -e -p "(yes/no/abort) |> " choice
    if [[ ${choice} == yes ]]
    then
	blank_cd || { message "$bb_cf_text6"; return 1; }
    elif [[ "${choice}" == abort ]]
    then
	message "$bb_cf_text4"
	return 1
    fi
    message "$bb_cf_text5"
    return 0
}


# Checks for whatever type of file is supplied
# FIXME: This is a little exercise in elbow kissing...
check_for()
{
    typeset filetype="$1"
    typeset line

    while read line
    do
	return 0
    done < <(find ${BBBURNDIR} -iname "$filetype" )
    return 1
}

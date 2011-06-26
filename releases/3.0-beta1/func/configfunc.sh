# Contains all configuration functions

get_yn()
{
    typeset instructions="$1"
    typeset ans
    typeset prompt
    echo -e "${instructions}"
    dashed_line
    while true
    do
	prompt=$(printf "%b|> %b" ${BBINPUTCOLOR} ${BBCOLOROFF})
	read -e -p "$prompt" ans 
	case "$ans" in
	n | no | No | NO ) # Nick - needs adding lang specific (Nien etc.)
	    return 0
	    ;;
	y | yes | Y | Yes | YES ) # Nick - needs adding lang specific (Ja etc.)
	    return 1
	    ;;
	*)
	    echo -e "${bb_conf_err}${BBHEADCOLOR}y${BBCOLOROFF}/${BBTABLECOLOR}n${BBCOLOROFF}" 	    
	    ;; # Lang options?
	esac
    done
    # NOTREACHED
}

# Confirmation routine on leaving configuration.
get_confirm()
{
    (( ${!BB_CONFIG_VAR} == 0 )) && return 1
    get_yn \
"${bb_conf_xit_2}\n ${bb_conf_err}'${BBTABLECOLOR}n${BBCOLOROFF}' (${bb_conf_menu_back}) \
 ${BBTABLECOLOR}|${BBCOLOROFF} '${BBHEADCOLOR}y${BBCOLOROFF}' (${bb_conf_xit_1})"
}

# Are you REALLY sure routine for reset to defaults.
get_really_sure()
{
    get_yn \
"${bb_conf_menu_default}?\n ${bb_conf_err} '${BBTABLECOLOR}n${BBCOLOROFF}' (${bb_conf_menu_back}) \
 ${BBTABLECOLOR}|${BBCOLOROFF} '${BBHEADCOLOR}y${BBCOLOROFF}' (${bb_conf_menu_default})"
}

# Confirm new settings.
get_new_settings()
{
    get_yn \
"${bb_conf_menu_apply}?\n ${bb_conf_err} '${BBTABLECOLOR}n${BBCOLOROFF}' (${bb_conf_menu_back}) \
 ${BBTABLECOLOR}|${BBCOLOROFF} '${BBHEADCOLOR}y${BBCOLOROFF}' (${bb_conf_menu_apply})"
}

# This function takes two or three arguments. The option to change ($1),
# a text to print out ($2) and a non-obligatory command to run ($3).
# The changed value is stored in the variable what CFG_CHANGES points to.
change_option()
{
    typeset -r old_IFS="$IFS"
    typeset IFS="$old_IFS"
    typeset var=$1
    typeset prompt="$2"
    typeset cmd="$3"
    typeset -i strict_enum=$4
    typeset input
    typeset -i chsize=0
    typeset -i ii
    typeset -i found=0
    typeset item
    typeset ivar
    typeset -r tempfile=$(mktemp -t bbch_opt.XXXXXX)
    typeset -r temphist=$(mktemp -t bbch_opthist.XXXXXX)
    typeset -a line
    typeset -i hist_mode=0

    pretty_top
    # Don't run the command if it was not supplied. This includes 
    # the header and footer stuff.
    top_info_line 
    echo -e "\n${prompt}"
    # If they gave us a command to run then by all means run it.
    top_info_line
    echo -e "\n"
    if [[ -n "$cmd" ]]
    then
	history -w
	if eval $cmd > $tempfile 2>&1
	then
	    # load the read buffer up and cat the file out.
	    cat $tempfile
	    cp $tempfile $temphist
	    history -cr $temphist
	    hist_mod=1
	    echo -e "\n"
	    dashed_line
	fi
    fi
    echo
    prompt=$(printf "%b$bb_conf_menu_entry |> %b" $BBINPUTCOLOR $BBCOLOROFF)
    read -e -p "$prompt" input
    # Now restore the history.
    (( hist_mod )) && history -cr
    # Let's look at what we just read and see if it's the same value as
    # what we started with. If so then just discard it.
    [[ "$input" == "${!var}" ]] && { rm -f $temphist $tempfile; return; }

    # If the input is NULL then just return, but if the input is a pair of 
    # double quotes then he really wants to set it to the null string.
    [[ -z "$input" ]] && { rm -f $temphist $tempfile; return; }
    [[ "$input" == "\"\"" ]] && input=

    # Check strict_enum to see if the user can just make up a value.
    if (( strict_enum ))
    then
	found=0
	while read line
	do
	    if [[ "$line" == $input ]]
	    then
		found=1
		break
	    fi
	done < $tempfile
	if (( ! found ))
	then
	    message 'Value entered may only be from the set supported.'
	    rm -f $temphist $tempfile
	    return
	fi
    fi
    rm -f $temphist $tempfile
    # The size of the array is the size of what CFG_CHANGES points to.
    chsize=$(eval "echo \${#${CFG_CHANGES}[@]}")
    # Loop over all changes made so far.
    # Why? Because someone might have modified the same var twice.
    found=0
    for (( ii=0; ii < chsize; ii++ ))
    do
	# This sucks because we can indirect through scalar
	# variables but not through arrays. :-(
	item=$(eval "echo \${${CFG_CHANGES}[ii]}")
	IFS='|'
	set -- $item
	IFS="$old_IFS"
	ivar=$1
	if [[ $var == "$ivar" ]]
	then
	    # If it matches then we can just change the entry
	    # that already exists.
	    eval "$CFG_CHANGES[ii]=\"${var}|${input}\""
	    found=1
	    break
	fi
    done
    # Otherwise, we add a new entry.
    (( found )) || eval "$CFG_CHANGES[chsize]=\"${var}|${input}\""
    eval ${BB_CONFIG_VAR}=1
}

# Welcome to bbmenu.sh. This file defines two functions: bbmenu and bbconfmenu.
# bbmenu is used to define a common menu system for bashburn. 
# bbconfmenu is used to define both the regular Configure and
# the Advanced Configure menu. They are fundamentally different because bbmenu 
# creates menus that are composed of an item and a function that gets executed 
# if it is selected.
# bbconfmenu displays menus that show a configuration parameter and
# a current value. If an item is selected then a third param explains what
# config param is. A fourth parameter is allowed to be
# executed which can help the user to understand what values are best selected.
#
# One of the arguments to these functions has to be the name of a menu 
# which must be a global-scope array.
# In the case of bbmenu the menu definition array must be a 2-tuple of the name
# to be displayed for the menu item, and the function to be invoked if the item
# is selected.
# ALL ITEMS ARE SEPERATED BY AMPERSAND.
# In the case of bbconfmenu, the array elements are a 4-tuple, composed of:
# * The name of the menuitem
# * The name of the configuration parameter to be affected.
# * The prompt to be displayed if the user selects a parameter to be modified.
# * An optional string to be eval'd.
#
# A complexity that is part of these menus is that the language that 
# gets displays is subject to change if the user tries to reconfigure BBLANG.
# This impacts not only the configure menu that the change occurs from, but
# also the main menu that the configure menu is called from. So the goal is
# that the Configure menu has to display things in the newly selected language
# and its caller has to change the language that it was running in after 
# the Configure menu has returned.

print_hdr()
{
    # print a uniform header.
    typeset title="$1"
    clear
    # <table>
    echo -e "${BBTABLECOLOR}${BBDECOLINE}
${BBTABLECOLOR}|${BBHEADCOLOR} ${BBVERSION} ${BBTABLECOLOR}|
${BBTABLECOLOR}${BBDECOLINE}
${BBTABLECOLOR}|
${BBTABLECOLOR}|-(${BBSUBCOLOR}$title${BBTABLECOLOR})"
}

bbmenu()
{
    # This is the common memu used by bb. 
    # THERE BE DRAGONS HERE. Test well if you modify it.
    # BE CAREFUL with your quoting. If you think you're right then test 
    # it and check the bash man page again.
    typeset old_IFS="$IFS"	# Save IFS. Which one are we saving?
				# Wrong answer! We're saving the global copy.
    typeset IFS="$IFS"		# NOW we're creating a local copy and 
				# initializing it with the global value.
    typeset titlename="$1"	# Pull off the title from the arglist.
    typeset menuname="$2"
    shift
    typeset -a item		# Convenience variables after parse.
    typeset -a action
    typeset -i ii=0		# Loop index
    typeset jj
    typeset -i size		# Nr of menu items
    typeset -a descriptors	# We need to save the arglist because set will 
				# override them.
    typeset -r protofmt='%b|%b %2d) %s%b'
    typeset nl		# Might be a newline or it might not...
			# The last %b is either "\n" or ""
    typeset chselection	# Set by read
    typeset selection	# User's real choice.
    typeset prompt
    typeset -i nogood=0

    set_descriptors()
    {
	size=$(eval "echo \"\${#$menuname[@]}\"" )
	for (( ii=0; ii<size; ii++ ))
	do
	    descriptors[ii]=$(eval "echo \"\${$menuname[ii]}\"" )
	done
        # Parse descriptors apart and save all the fields for handy use later.
        # FIXME: Hose all this crap out and make a proper constructor.
	for (( ii=0; ii<size; ii++ ))
	do
	    IFS=@
	    set -- ${descriptors[ii]}
	    IFS="$old_IFS"
	    item[ii]="$1"
	    action[ii]="$2"
	done
    }
    set_descriptors

    # Stuff the items and the actions for later use.
    ii=0
    for jj in "${descriptors[@]}"
    do
	IFS=@	# Parse the descriptors apart with new delimiter.
	set -- ${descriptors[ii]}	# NOTE: desc[ii] is NOT quoted.
	item[ii]="$1"
	action[ii]="$2"
	IFS="$old_IFS"
	ii=ii+1
	shift
    done
    # Start of menu loop
    while true
    do
	print_hdr "${!titlename}"
	for (( ii=0; ii < size; ii++ ))
	do
	    # Print out the last line without a newline.
	    (( ii >= size )) && nl= || nl="\n"
	    printf "$protofmt" ${BBTABLECOLOR} ${BBMAINCOLOR} \
		    $ii "${item[ii]}" "$nl"
	done
	# Why are we doing this instead of using the prompt functionality 
	# of read? Because read won't display escape sequences.
	# It only know how many characters it printed, not how many 
	# were printable.
	prompt=$(printf "%b|
	%b$bb_menu_input[0-$((size-1))] |>%b " \
		${BBTABLECOLOR} ${BBINPUTCOLOR} ${BBMAINCOLOR})
	read -e -p "$prompt" chselection	# Get the user's choice.
	# look up which action is associated with the choice.
	# if just enter is pressed, ignore it...
	# (there must be a better way to do this).
	nogood=0
	if [[ -n "$chselection" ]]
	then
	    # Assign chselection to selection. But selection is an integer
	    # variable and chselection is not. If chselection is not numeric
	    # then the value of selection will be zero.
	    # SO, to see if the luser boned us, we assign and see if selection
	    # if 0 and chselection is not.
	    # Then after that we do the standard test to see if the number
	    # is in bounds.
	    # Remove non-DIGITS from real selection
	    selection="${chselection//[^0-9]/}"
	    if [[ "$selection" != "$chselection" ]]
	    then
		nogood=1
		echo 'Error: Input must be numeric'
	    elif (( selection >= 0 && selection < size )) 
	    then
		eval ${action[selection]}	# Do it baby.
	    else
		# Bitch if the input was out of bounds.
		echo 'Error: Input must be in range'
		nogood=1
	    fi
	    if (( nogood == 1 ))
	    then
		echo -e "$bb_exit_error[0-$(( size - 1 ))]"  
		read -n 1 -p "press any key to continue : " selection
	    fi
	fi
    done
} # bbmenu

bbconfmenu()
{
    # If you thought the previous code was tricky then don't even look at this.
    # It'll make your brain explode.
    typeset old_IFS="$IFS"	# Save IFS. Which one are we saving?
				# Wrong answer! We're saving the global copy.
    typeset IFS="$IFS"		# NOW we're creating a local copy and 
				# initializing it with the global value.
    # 1st 4 args are the actions to be taken for the four actions at the end.
    # (whatever they are ;-)
    typeset menuname="${1}"	# Name of the array that's passed in.
    typeset toptext1name=$2
    typeset toptext2name=$3
    typeset size1action="$4"
    typeset size2action="$5"
    typeset size3action="$6"
    typeset size4action="$7"
    typeset toptext1
    typeset toptext2
    shift 7
    typeset -a descriptors	# All the rest of the menu conf values.
    typeset -i size		# The number of entries in descriptors
    typeset -i size1		# size + 1
    typeset -i size2
    typeset -i size3
    typeset -a var		# List of all of the config variables.
    typeset lvar		# Basically it's var[i] with indirection
				# It's to solve a bash limitation with arrays.
    typeset lval		# Same trick in a different context.
    typeset -a text		# Array of variable descriptions.
    typeset -i jj=0		# Used to index into indirect of CFG_CHANGES
    typeset -i ii=0		# General array index
    typeset star		# Set to either an asterick or null to 
				# indicate that a value is modified.
    typeset dispval		# If star is set that dispval will be displayed
				# instead of the actual value of the 
				# config parameter.
    typeset changed_var		# Name of the changed variable.
    typeset newval		# New value to be applied to changed variable.
    typeset action		# read var for user's choice.
    typeset -i act		# interger version of action.
    typeset -a change_prompt	# List of prompts on what the user 
				# is selecting to change.
    typeset -a info_cmd		# command to be executed (optional) for changing.
    typeset -ai strict_enum	# Define if the user is allowed to specify 
				# from a list of made up values.
    typeset -i cfgsize=0	# Size of the number of outstanding changes.
    typeset prompt		# readline prompt string in living color.
    typeset -a menu_extras	# Last *4* (ooops) entries.
				# I don't get why it can't be inited at decl. :-(
    typeset -a menu_extras_names

    # Now here's somthing you don't see everyday Bullwinkle.
    # What's that Rocky?
    # A function defined in a shell script that's nested!
    # You're right Rocky. But that'll never work. How can set_descriptors see
    # the variable menuname?
    # That's why it *does* work. Because it's nested.
    set_descriptors()
    {
	size=$(eval "echo \"\${#$menuname[@]}\"" )
	for (( ii=0; ii<size; ii++ ))
	do
	    descriptors[ii]=$(eval "echo \"\${$menuname[ii]}\"" )
	done
        # Parse descriptors apart and save all the fields for handy use later.
        # FIXME: Hose all this crap out and make a proper constructor.
	for (( ii=0; ii<size; ii++ ))
	do
	    IFS=@
	    set -- ${descriptors[ii]}
	    IFS="$old_IFS"
	    text[ii]="${!1}"
	    var[ii]=$2
	    change_prompt[ii]="${!3}"
	    info_cmd[ii]="${!4}"
	    [[ -z "$5" ]] || strict_enum[ii]=$5
	done
	toptext1="${!toptext1name}"
	toptext2="${!toptext2name}"
	for (( ii=0; ii < "${#menu_extras_names[ii]}"; ii++ ))
	do
	    menu_extras[ii]="${!menu_extras_names[ii]}"
	done
    }

    menu_extras_names[0]=bb_conf_menu_apply
    menu_extras_names[1]=bb_conf_menu_default
    menu_extras_names[2]=bb_conf_menu_revert
    menu_extras_names[3]=bb_conf_menu_back

    set_descriptors
    # Here's the deal. Whoever calls this will set CFG_CHANGES to the variable 
    # that holds the outstanding changes. So to muck with the list of changes
    # we have to jump through it to access its content.
    # And just for fun, bash doesn't like to let you jump through arrays. 
    # It's good with scalars, but definitely not arrays.
    while true
    do
	pretty_top
	printf '%b|-(%b%s%b)%*b(%b%s%b)\n' \
		"$BBTABLECOLOR" "$BBSUBCOLOR"  "$toptext1" "$BBTABLECOLOR" \
		$((39 - ${#toptext1})) "$BBTABLECOLOR" \
	        "$BBSUBCOLOR" "$toptext2" "$BBTABLECOLOR"
	cfgsize=$(eval echo "\${#${CFG_CHANGES}[@]}")
	# Now we know how many outstanding changes there are.
	# This is where we print out the menu items, but the items will
	# have a star after them if they are modified.
	for (( ii=0; ii < size; ii++ ))
	do
	    star=
	    lvar=${var[ii]}
	    dispval="${!lvar}"
	    for (( jj=0; jj < cfgsize; jj++ ))
	    do
		lval=$(eval "echo \${${CFG_CHANGES}[jj]}")
		IFS='|'
		set -- $lval
		IFS="$old_IFS"
		changed_var="$1"
		newval="$2"
		if [[ "${var[ii]}" == "$changed_var" ]]
		then
		    star='*'
		    dispval="$newval"
		    break
		fi
	    done
	    printf "%b|%b  %2d) %-29b(%b%b%b)%b\n" \
		    "$BBTABLECOLOR" "$BBMAINCOLOR" $ii "${text[ii]}" \
		    "$BBOPTIONCOLOR" "$dispval" "$BBMAINCOLOR" "$star"
	done
	# The first part of the menu has been printed.
	# Now we print the action seperator
	echo -e \
"${BBTABLECOLOR}|-(${BBSUBCOLOR}${bb_conf_action_desc}${BBTABLECOLOR})"
	# followed by the extras.
        for (( ii=0; ii < "${#menu_extras[@]}"; ii++ ))
	do
	    echo -e \
"${BBTABLECOLOR}|-${BBMAINCOLOR} $((ii+size))) ${menu_extras[ii]}${BBTABLECOLOR}"
	done
	# Use printf to compose a prompt for the user so it can be in color.
	prompt=$(printf "%b$bb_conf_menu_entry |> %b " \
		    ${BBINPUTCOLOR} ${BBMAINCOLOR})
	read -e -p "$prompt" action

	echo -e "${BBCOLOROFF}"

	# If the action is in range of the descriptor table then
	# we process it with change_option.
	act="${action//[^0-9]/}"
	if [[ "$action" != "$act" ]]
	then
	    echo 'Error: Input must be numeric'
	elif (( action < size ))
	then
	    change_option \
		"${var[act]}" \
		"${change_prompt[act]}" \
		"${info_cmd[act]}" \
	        ${strict_enum[act]}
	elif (( action < size + "${#menu_extras[@]}" ))
	then
	    # Otherwise we have custom actions that were passed in.
	    # NOTE: None of this works if the sizes are not declared int.
	    size1=size+1
	    size2=size+2
	    size3=size+3
	    case $action in
	    $size)
                eval $size1action
		;;
	    $size1)
		eval $size2action
		;;
	    $size2)
		eval $size3action
		;;
	    $size3)
		eval $size4action
		;;
	    esac
	else
	    pretty_top
	    top_info_line
	    message

echo -e "${BBMAINCOLOR}$bb_conf_err [0-$((size+4))]${BBCOLOROFF}/n"
dashed_line
	fi
    done
} # bbmenuconf

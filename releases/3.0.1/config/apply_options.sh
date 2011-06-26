apply_options()
{
    # Write all the options out to replace the bashburnrc.
    typeset bbtempfile=$(mktemp bashburn_apply_opts.XXXXXX)
    typeset trimval
    typeset ii
    #Apply changes
    # Make sure BashBurn knows it is configured.
    
    for ii in "${BB_KEYWORDS[@]}"
    do
	read trimval <<< ${!ii}
	echo "${ii}: ${trimval}"
    done > ${bbtempfile}
    cp ${bbtempfile} $BBCONFFILE
    rm ${bbtempfile}
}

conf_set_aval()
{
    typeset -a desc
    typeset val="$2"
    typeset line
    typeset oldIFS="$IFS"
    typeset IFS="$oldIFS"
    typeset -r tmpfile=$(mktemp 'bbcfg.XXXXXX')
    typeset varname
    typeset -i found	# Set if the option was found in the changed descriptors.
    typeset -i didsomething=0	# Set if there were any mods at all.
    typeset -i ii
    typeset nvar
    typeset nval
    typeset -i size

    desc=( "$@" )
    size=$#
    #for (( ii=0; ii < size; ii++ ))
    #do
    #	echo ${desc[ii]}
    #done
    while read line
    do
	IFS=:
	set -- $line
	IFS="$oldIFS"
	varname=$1
	found=0
	for (( ii=0; ii < size; ii++ ))
	do
	    IFS='|'
	    set -- ${desc[ii]}
	    IFS="$oldIFS"
	    nvar=$1
	    nval="$2"
	    if [[ "$nvar" == "$varname" ]]
	    then
		eval $nvar=\"$nval\"
		found=1
		didsomething=1
		case $nvar in	# stub to catch special action.
		BBLANG)
		    source_language_modules
		    define_global_menus
		    ;;
		*)
		    ;;
		esac
		break
	    fi
	done
	if (( found ))
	then
	    echo "$nvar: ${!nvar}"
	else
	    echo "$line"
	fi
    done < $BBCONFFILE > $tmpfile
    (( didsomething )) && cp $tmpfile $BBCONFFILE
    rm $tmpfile
}

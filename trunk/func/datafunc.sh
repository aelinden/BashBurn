# This file contains functions for data burning

# Checks number of devices
dev_check()
{
    [[ "${BBNUMDEV}" == 1 ]] && insert_new_CD
}

#This function lets you swap cds if NUMDEV is set to 1
insert_new_CD()
{
    typeset temp
    while true
    do
	echo $bb_dm_newcd
	read -e temp
	[[ -z "$temp" ]] && break
    done
}

copy_data_cd()
{
    typeset -i doit=0

    if ( grep -q $BBCDMNT /etc/mtab )
    then
        # Data appears to be mounted, so start here.
	if (( ${BBNUMDEV} == 2 ))
	then
	    ${BB_READCD} ${BB_READ_OPTS} ${BBCDMNT} | \
		    ${BB_CDBURNCMD} dev=${BBCDWRITER} ${BBDTAO} \
		    -v -data -eject -
	    echo $bb_dm_ch2_5
	elif [[ -n $(find ${BBBURNDIR} -iname '*.iso' 2> /dev/null) ]]
	then	# Does an ISO file exist?
	    echo "$bb_dm_ch2_2${BBBURNDIR}.$bb_dm_ch2_3"
	    echo $bb_dm_ch2_4
	else
	    echo "$bb_dm_cdcopy${BBBURNDIR}..."
	    if ${BB_READCD} ${BB_READCD_OPTS} \
		    -o ${BBBURNDIR}/BashBurn.iso ${BBCDMNT}
	    then
		umount $BBCDMNT
		eject
		insert_new_CD
		if check_cd_status
		then
		    ask_for_blanking && doit=1
		else
		    doit=1
		fi
		if (( doit ))
		then
		    ${BB_CDBURNCMD} dev=${BBCDWRITER} ${BBDTAO} -v \
			    -data -eject "$BBBURNDIR"/BashBurn.iso 
		    echo $bb_dm_ch2_5
		fi
	    else
		echo $bb_dm_cdcopy_err1
		echo $bb_dm_cdcopy_err2
	    fi
	    rm ${BBBURNDIR}/BashBurn.iso
	fi
    else
        # Looks like data CD isn't mounted
	echo -e "Data$bb_dm_ch2_1"
    fi
    wait_for_enter
}

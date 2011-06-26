# Functions for data definition

copy_link_data()
{
    cd ${BBBURNDIR}
    echo $bb_dc_explain1
    echo "$bb_dc_explain2a${BBBURNDIR}$bb_dc_explain2b"
    echo $bb_dc_explain3
    echo $bb_dc_explain4
    echo $bb_dc_explain5
    echo $bb_dc_explain6
    echo $bb_dc_explain7
    echo $bb_dc_explain8
    bash
}

view_contents()
{
    if is_dir_empty "${BBBURNDIR}"
    then
	echo "$bb_dc_ch3_4 ${BBBURNDIR}"
    else
#	ls -lhgG --color ${BBBURNDIR} # Nick - I prefer this so symlinks show... comments?
	ls -lhgGL --color ${BBBURNDIR}
    fi
}

delete_data()
{
    typeset choice
    if is_dir_empty "${BBBURNDIR}"
    then
	echo "$bb_dc_ch3_4 ${BBBURNDIR}"
    else
	ls -lhgGL --color ${BBBURNDIR}
	echo -en "\n$bb_dc_ch3_1"
	read -e choice
	if [[ "$choice" = y ]]
	then
	    rm -rf ${BBBURNDIR}/*
	    echo -ne "\n$bb_dc_ch3_2\n\n"
	else
	    echo -ne "\n$bb_dc_ch3_3\n\n"
	fi
    fi
}

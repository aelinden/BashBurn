m3u_read()
{
    if ! check_for *.m3u
    then
	echo -e "No M3U file exists in ${BBBURNDIR}."
    else
	typeset m3ufile=$(find ${BBBURNDIR} -iname '*.m3u')
	typeset musicfiles

	while read musicfiles
	do
	    ln -sf "$musicfiles" "${BBBURNDIR}"
	done < <(grep -v "#EXT" "${m3ufile}")
    fi
}


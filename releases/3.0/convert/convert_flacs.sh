convert_flacs()
{
    cd ${BBBURNDIR}
    shopt -s nocaseglob
    ${BB_FLACCMD} -d *.flac
    shopt -u nocaseglob
    echo $bb_conv_flac_1
    sleep 2s
}

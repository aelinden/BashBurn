convert_oggs()
{
    cd ${BBBURNDIR}
    shopt -s nocaseglob
    ${BB_OGGDEC} *.ogg
    shopt -u nocaseglob
    message "$bb_conv_ogg"
}

typeset -a configure_adv_changes # Global used by advanced and change_option.

config_adv_apply()
{
    pretty_top
    top_info_line
    get_new_settings && return
    conf_set_aval "${configure_adv_changes[@]}"
    config_adv_revert
    set_descriptors
}

config_adv_default()
{
    pretty_top
    top_info_line
    get_really_sure && return
    configure_adv_changes=( \
	    'BB_CDBURNCMD|cdrecord' \
	    'BB_DVDBURNCMD|growisofs' \
	    'BB_ISOCMD|mkisofs' \
	    'BB_DVDBLANK|dvd+rw-format' \
	    'BB_CDIMAGECMD|cdrdao' \
	    'BB_CDAUDIORIP|cdparanoia' \
	    'BB_READCD|mkisofs' \
	    'BB_READ_OPTS|-r -R -J -l --allow-leading-dots' \
	    'BB_MP3ENC|lame' \
	    'BB_MP3DEC|mpg123' \
	    'BB_OGGENC|oggenc' \
	    'BB_OGGDEC|oggdec' \
	    'BB_FLACCMD|flac' \
	    'BB_EJECT|eject' \
	    'BB_NORMCMD|normalize' \
	    )
    conf_set_aval "${configure_adv_changes[@]}"
    config_adv_revert
}

config_adv_revert()
{
    configure_adv_changes=()
    BB_ADVANCED_CONFIG_MODIFIED=0
}

advanced()
{
    # Advanced menu
    # Swap out the variables that track if something is modified.
    CFG_CHANGES=configure_adv_changes
    BB_ADVANCED_CONFIG_MODIFIED=0
    BB_CONFIG_VAR=BB_ADVANCED_CONFIG_MODIFIED
    bbconfmenu \
	    advancedmenu \
	    bb_adv_menutitle \
            bb_conf_menu_toptext2 \
	    config_adv_apply \
	    config_adv_default \
	    config_adv_revert \
	    'get_confirm || break'
    return 0
}

# BB_CONFIG_MODIFIED is 0 if no configparams were modified and 1 if
# any of them were. Once the config params are written out then it 
# gets reset back to 0
typeset -i BB_CONFIG_MODIFIED=0
typeset -i BB_ADVANCED_CONFIG_MODIFIED=0
# BB_CONFIG_VAR is equal to BB_CONFIG_MODIFIED (not $BB_CONFIG_MODIFIED)
# unless we are in the advanced menu. Then it will be set
# to BB_ADVANCED_CONFIG_MODIFIED.
typeset BB_CONFIG_VAR

typeset -a configure_changes	# Global used by configure and change_option.

config_apply()
{
    pretty_top
    top_info_line
    get_new_settings && return
    conf_set_aval "${configure_changes[@]}"
    config_revert
    set_descriptors
}

config_default()
{
    pretty_top
    top_info_line
    get_really_sure && return
    configure_changes=( \
	    'BBISCONF|0' \
	    'BBCDWRITER|<Change me>' \
	    'BBCDROM|<Change me>' \
	    'BBCDMNT|<Change me>' \
	    'BBSPEED|-1' \
	    'BBBLANKING|fast' \
	    'BBNUMDEV|1' \
	    'BBBURNDIR|/tmp/burn' \
	    'BBFIFODIR|/tmp' \
	    'BBDESCRIPTION|Burnt with BashBurn' \
	    'BBAUTHOR|<Change me>' \
	    'BBLABEL|BashBurn CD/DVD' \
	    'BBNORMALIZE|no' \
	    'BBDRIVEROPT|' \
	    'BBDELTEMPBURN|no' \
	    'BBOVERBURN|no' \
	    'BBBITRATE|192' \
	    'BBLANG|English' \
	    'BBDTAO|-tao' \
	    'BBPADDING|-pad' \
	    )
    conf_set_aval "${configure_changes[@]}"
    config_revert
#    bb_parse_config
}

config_revert()
{
    configure_changes=()
    BB_CONFIG_MODIFIED=0
}

configure()
{
    CFG_CHANGES=configure_changes
    BB_CONFIG_MODIFIED=0
    BB_CONFIG_VAR=BB_CONFIG_MODIFIED
    bbconfmenu \
	    conf_menuitems \
	    bb_conf_menu_toptext1 \
            bb_conf_menu_toptext2 \
	    config_apply \
	    config_default \
	    config_revert \
	    'get_confirm || break'
    return 0
}

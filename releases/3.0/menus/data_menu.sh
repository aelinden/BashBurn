blank_CDROM()
{
    
    if check_cd_status
    then
	blank_cd
    else
	message $bb_cdrw_blank6
    fi
}

data_menu()
{
    bbmenu bb_dm_menu_title datamenu
}

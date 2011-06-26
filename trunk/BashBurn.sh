#!/bin/bash

errmsg()
{
    echo -e "$@" 1>&2
}

die()
{
    errmsg "$@"
    exit 1
}

# Creates a default config file if one is missing
create_config()
{
    {
	create_reg_config
	create_advanced_config
    } > $BBCONFFILE
}


create_reg_config()
{
    typeset line

    echo -e "
VERSION: 3.1.x
BBISCONF: 0
BBCDWRITER: <Change me>
BBCDROM: <Change me>
BBCDMNT: <Change me>
BBSPEED: -1
BBBLANKING: fast
BBNUMDEV: 1
BBBURNDIR: /tmp/burn
BBFIFODIR: /tmp
BBDESCRIPTION: Burnt with BashBurn
BBAUTHOR: <Change me>
BBLABEL: BashBurn CD/DVD
BBNORMALIZE: no
BBDRIVEROPT:
BBDELTEMPBURN: no
BBOVERBURN: no
BBBITRATE: 192
BBLANG: English
BBDTAO: -tao
BBPADDING: -pad
"
}

create_advanced_config ()
{
    echo -e "
BB_CDBURNCMD: cdrecord
BB_DVDBURNCMD: growisofs
BB_DVDBURNCMDOPTS: -r -f -v -J -joliet-long
BB_ISOCMD: mkisofs
BB_DVDBLANK: dvd+rw-format
BB_CDIMAGECMD: cdrdao
BB_CDAUDIORIP: cdparanoia
BB_READCD: mkisofs
BB_READ_OPTS: -r -R -J -l --allow-leading-dots
BB_MP3ENC: lame
BB_MP3DEC: mpg123
BB_OGGENC: oggenc
BB_OGGDEC: oggdec
BB_FLACCMD: flac
BB_EJECT: eject
BB_NORMCMD: normalize
BB_NRG2ISO: nrg2iso
"
}

exit_handler()
{
    echo -e "

${BBMAINCOLOR}$bb_quit1${BBHEADCOLOR}${BBVERSION}
${BBMAINCOLOR}$bb_quit2${BBSUBCOLOR}$bb_quit3${BBMAINCOLOR}$bb_quit4${BBCOLOROFF}"
    # Reset terminal
    tput sgr0
    stty $TERMINAL_CHARACTERISTICS
    history -w
}

force_quit()
{
    exit 0
}

typeset -ra BB_REG_KEYWORDS=( \
	VERSION \
	BBCDWRITER \
	BBCDROM \
	BBCDMNT \
	BBSPEED \
	BBBLANKING \
	BBNUMDEV \
	BBBURNDIR \
	BBLABEL \
	BBDESCRIPTION \
	BBAUTHOR \
	BBNORMALIZE \
	BBDRIVEROPT \
	BBFIFODIR \
	BBDELTEMPBURN \
	BBOVERBURN \
	BBBITRATE \
	BBLANG \
	BBISCONF \
	BBDTAO \
	BBPADDING \
	BBCONFFILE \
	)

typeset -ra BB_ADV_KEYWORDS=( \
	BB_CDBURNCMD \
	BB_DVDBURNCMD \
        BB_DVDBURNCMDOPTS \
	BB_ISOCMD \
	BB_DVDBLANK \
	BB_CDIMAGECMD \
	BB_CDAUDIORIP \
	BB_READ_OPTS \
	BB_READCD \
	BB_MP3ENC \
	BB_MP3DEC \
	BB_OGGENC \
	BB_OGGDEC \
	BB_FLACCMD \
	BB_EJECT \
	BB_NORMCMD \
        BB_NRG2ISO \
	)
typeset -ra BB_KEYWORDS=( "${BB_REG_KEYWORDS[@]}" "${BB_ADV_KEYWORDS[@]}" )

typeset -a mainmenu
typeset -a advancedmenu
typeset -a audiomenu
typeset -a configmenu
typeset -a datamenu
typeset -a isomenu
typeset -a imagemenu
typeset -a multimenu
typeset -a mountmenu
typeset -a datadefinemenu
typeset -a conf_menuitems
typeset CFG_CHANGES


typeset -r grepcdfstab="grep -E 'cdrom|dvd|writer|cdrw' /etc/fstab"
typeset -r lslang='ls -I ${BBLANG} -1 ${BBROOTDIR}/lang'
typeset -r checkdrive='$BB_CDBURNCMD dev=$BBCDWRITER driveropts=help \
		       -checkdrive 2>&1 > /dev/null | grep -A 20 "Driver options"'

# Creates a list of all CD-drives in the system. Each drive is
# appended as NAME : BLOCKDEVICE to $cdroms which is printed when
# needed by printcdroms
#typeset cdroms
#for line in $(hal-find-by-property --key storage.drive_type --string cdrom); do
#    name=$(hal-get-property --udi $line --key storage.model); 
#    bdevice=$(hal-get-property --udi $line --key block.device);
#    cdroms="$cdroms\n$name : $bdevice"
#done
#typeset -r printcdroms="printf \"$cdroms\""


define_global_menus()
{
    # Define the menu array entries. Colon is the seperator.
    # Field 1 is always the the prompt.
    # Field 2 is always the action if there's a match.
    # If field three exists then it is the current value to be displayed.
    # The above description only applies to menus. It does NOT apply to
    # configuration menus. Regular menus are fed to bbmenu. Configuration 
    # menus are fed to bbmenuconf.
    # Format for bbmenuconf is
    # Fld1 is field description.
    # Fld2 is the name of the config param.
    # Fld3 is the prompt if you want to change the value of fld2.
    # Fld4 (optional) is the code to execute to provide more data at runtime
    # for fld3.
    mainmenu[0]="$bb_menu_1@audio_menu"
    mainmenu[1]="$bb_menu_2@data_menu"
    # 3.1.0 - Move ISO and bin/cue into image menu together
    # together with NRG to ISO conversion.
    mainmenu[2]="$bb_menu_imgs@image_menu"
    mainmenu[3]="$bb_menu_5@multi"
    mainmenu[4]="$bb_menu_6@configure && return"	# Very tricky.
    mainmenu[5]="$bb_conf_menu_adv@advanced"
    mainmenu[6]="$bb_menu_7@mount_func"
    mainmenu[7]="$bb_menu_8@check_path"
    mainmenu[8]="$bb_menu_9@datadefine"
    mainmenu[9]="$bb_menu_0@bbexit"

    advancedmenu[0]='bb_adv_cdburncmd@BB_CDBURNCMD@bb_adv_cdburncmd_help'
    advancedmenu[1]='bb_adv_dvdburncmd@BB_DVDBURNCMD@bb_adv_dvdburncmd_help'
    advancedmenu[2]='bb_adv_dvdburncmdopts@BB_DVDBURNCMDOPTS@bb_adv_dvdburncmdopts_help'
    advancedmenu[3]='bb_adv_isocmd@BB_ISOCMD@bb_adv_isocmd_help'
    advancedmenu[4]='bb_adv_dvdblankcmd@BB_DVDBLANK@bb_adv_dvdblankcmd_help'
    advancedmenu[5]='bb_adv_imgburncmd@BB_CDIMAGECMD@bb_adv_imgburncmd_help'
    advancedmenu[6]='bb_adv_audioripcmd@BB_CDAUDIORIP@bb_adv_audioripcmd_help'
    advancedmenu[7]='bb_adv_cdcopycmd@BB_READCD@bb_adv_cdcopycmd_help'
    advancedmenu[8]='bb_adv_cdcopyopts@BB_READ_OPTS@bb_adv_cdcopyopts_help'
    advancedmenu[9]='bb_adv_mp3enc@BB_MP3ENC@bb_adv_mp3enc_help'
    advancedmenu[10]='bb_adv_mp3dec@BB_MP3DEC@bb_adv_mp3dec_help'
    advancedmenu[11]='bb_adv_oggenc@BB_OGGENC@bb_adv_oggenc_help'
    advancedmenu[12]='bb_adv_oggdec@BB_OGGDEC@bb_adv_oggdec_help'
    advancedmenu[13]='bb_adv_flac@BB_FLACCMD@bb_adv_flac_help'
    advancedmenu[14]='bb_adv_eject@BB_EJECT@bb_adv_eject_help'
    advancedmenu[15]='bb_adv_norm@BB_NORMCMD@bb_adv_norm_help'
    advancedmenu[16]='bb_adv_nrg2iso@BB_NRG2ISO@bb_adv_nrg2iso_help'

    audiomenu[0]="$bb_am_menu_1@convert_and_burn_from_files"
    audiomenu[1]="$bb_am_menu_2@burning --pipeline"
    audiomenu[2]="$bb_am_menu_3@copy_audio_cd"
    audiomenu[3]="$bb_am_menu_4@copy_cd_to_hd"
    audiomenu[4]="$bb_am_menu_5@burn_m3u_playlist"
    audiomenu[5]="$bb_am_menu_6@create_mp3s_from_wavs"
    audiomenu[6]="$bb_am_menu_7@create_oggs_from_wavs"
    audiomenu[7]="$bb_am_menu_8@create_flacs_from_wavs"
    audiomenu[8]="$bb_am_menu_9@create_mp3s_from_cd"
    audiomenu[9]="$bb_am_menu_10@create_oggs_from_cd"
    audiomenu[10]="$bb_am_menu_11@create_flacs_from_cd"
    audiomenu[11]="$bb_am_menu_0@return"

    # If old behaviour of grepping /etc/fstab is wanted 
    # when selecting burner/reader, replace printcdroms with grepcdfstab
    conf_menuitems[0]='bb_conf_menu_writer@BBCDWRITER@bb_conf_ch_writer@grepcdfstab'
    conf_menuitems[1]='bb_conf_menu_cddev@BBCDROM@bb_conf_ch_cddev@grepcdfstab'
    conf_menuitems[2]='bb_conf_menu_cdmnt@BBCDMNT@bb_conf_ch_cdmnt@grepcdfstab'
    conf_menuitems[3]='bb_conf_menu_speed@BBSPEED@bb_conf_ch_speed'
    conf_menuitems[4]='bb_conf_menu_blank@BBBLANKING@bb_conf_ch_blanking'
    conf_menuitems[5]='bb_conf_menu_numdev@BBNUMDEV@bb_conf_ch_numdev'
    conf_menuitems[6]='bb_conf_menu_burn@BBBURNDIR@bb_conf_ch_burndir'
    conf_menuitems[7]='bb_conf_menu_label@BBLABEL@bb_conf_ch_label'
    conf_menuitems[8]='bb_conf_menu_auth@BBAUTHOR@bb_conf_ch_author'
    conf_menuitems[9]='bb_conf_menu_desc@BBDESCRIPTION@bb_conf_ch_desc'
    conf_menuitems[10]='bb_conf_menu_norm@BBNORMALIZE@bb_conf_ch_norm'
    conf_menuitems[11]='bb_conf_menu_dropt@BBDRIVEROPT@bb_conf_ch_dropts@checkdrive'
    conf_menuitems[12]='bb_conf_menu_fifo@BBFIFODIR@bb_conf_ch_fifo'
    conf_menuitems[13]='bb_conf_menu_deltmp@BBDELTEMPBURN@bb_conf_ch_tempdel'
    conf_menuitems[14]='bb_conf_menu_ob@BBOVERBURN@bb_conf_ch_ob'
    conf_menuitems[15]='bb_conf_menu_bitrate@BBBITRATE@bb_conf_ch_bitrate'
    conf_menuitems[16]='bb_conf_menu_lang@BBLANG@bb_conf_ch_lang@lslang'
    conf_menuitems[17]='bb_conf_menu_dtao@BBDTAO@bb_conf_ch_dtao'
    conf_menuitems[18]='bb_conf_menu_gap@BBPADDING@bb_conf_ch_pad'

    imagemenu[0]="$bb_image_menu1@iso_menu"
    imagemenu[1]="$bb_image_menu2@bincue"
    imagemenu[2]="$bb_image_menu3@convert_images *.nrg"
    imagemenu[3]="$bb_image_menu_back@return"

    datamenu[0]="$bb_dm_menu_1@burning --data"
    datamenu[1]="$bb_dm_menu_2@copy_data_cd"
    datamenu[2]="$bb_dm_menu_3@burning --dvddata"
    datamenu[3]="$bb_dm_menu_4@blank_CDROM"
    datamenu[4]="$bb_dm_menu_5@burning --dvdblank"
    datamenu[5]="$bb_dm_menu_0@return"

    isomenu[0]="$bb_im_menu_1@burning --iso"
    isomenu[1]="$bb_im_menu_2${BBBURNDIR}@create_iso_from_dir"
    isomenu[2]="$bb_im_menu_3@create_iso_from_cd"
    isomenu[3]="$bb_im_menu_4@burning --dvdimage"
    isomenu[4]="$bb_im_menu_5@mount_in_loopback"
    isomenu[5]="$bb_im_menu_0@return"

    multimenu[0]="$bb_multi_menu_1@burn_multi -m 0"
    multimenu[1]="$bb_multi_menu_2@burn_multi -m 1"
    multimenu[2]="$bb_multi_menu_3@burn_multi 1"
    multimenu[3]="$bb_multi_menu_0@return"

    mountmenu[0]="$bb_mnt_menu_1@mount_device"
    mountmenu[1]="$bb_mnt_menu_2@umount_device"
    mountmenu[2]="$bb_mnt_menu_3@eject_device"
    mountmenu[3]="$bb_mnt_menu_0@return"

    datadefinemenu[0]="$bb_dc_menu_1${BBBURNDIR}@copy_link_data"
    datadefinemenu[1]="$bb_dc_menu_2${BBBURNDIR}@{ view_contents; wait_for_enter; }"
    datadefinemenu[2]="$bb_dc_menu_3${BBBURNDIR}@{ delete_data; wait_for_enter; }"
    datadefinemenu[3]="$bb_dc_menu_0@return"
}

source_language_modules()
{
    # This to GO when all configure.lang are fixed
    # This just adds help descriptions in English
    # for languages that have not yet got the new $VAR
    # else they get NO help descriptions at all.
    . ${BBROOTDIR}/misc/configure_temp_help.lang 

    typeset -r langdir=${BBROOTDIR}/lang/${BBLANG}
    # Language files
    . $langdir/BashBurn.lang
    . $langdir/advanced.lang
    . $langdir/audio_menu.lang
    . $langdir/bincue.lang
    . $langdir/burning.lang
    . $langdir/check_path.lang
    . $langdir/commonfunctions.lang
    . $langdir/configure.lang
    . $langdir/convert_audio.lang
    . $langdir/convert_images.lang
    . $langdir/data_menu.lang
    . $langdir/datadefine.lang
    . $langdir/iso_menu.lang
    . $langdir/image_menu.lang
    . $langdir/loopback.lang
    . $langdir/mount.lang
    . $langdir/multi.lang
}

bbexit()
{
    typeset -r bberrlog=/dev/null
    echo -e "--\n" >> $bberrlog
    exit 0
}

getconfigparam()
{
    typeset param=$1
    typeset oldIFS="$IFS"
    typeset IFS=:
    typeset line
    while read line
    do
	set -- $line
	if [[ $1 == $param ]]
	then
	    IFS="$oldIFS"
	    read trimval <<< $2
	    eval $param=$trimval
	    return 0	# found
	fi
    done < $BBCONFFILE
    return 1
}

# Decoline must be two characters longer than version or it will look funny.
typeset -r BBDECOLINE='+----------------+'
# Version number (should not contain whitespaces at beginning or
# end [petsound]).
typeset -r BBVERSION='BashBurn 3.1.0'
# Bashburn configuration file:
typeset -r HOMEDIR=$HOME # User identification
# Default config file, used if no config file in user dir 
typeset BBCONFFILE=$HOMEDIR/.bashburnrc
typeset BBROOTDIR='@@BBROOTDIR@@'

typeset TERMINAL_CHARACTERISTICS
typeset HISTFILE=$HOMEDIR/.bashburn_history

# Error log
typeset bberrorlog=/tmp/bb-error.log
typeset -r OLD_IFS="$IFS"
typeset -r BBLANGdef=English

echo -e "$(date)\n" >> $bberrorlog

# Current terminal characteristics.
TERMINAL_CHARACTERISTICS=$(stty -g)

# Detect signals as 'CTRL+C', INIT, KILL, call to function force_quit, 
# show BashBurn info and quit.
trap exit_handler EXIT
trap force_quit SIGHUP SIGINT SIGQUIT SIGTERM

# Pull in minimal files
. ${BBROOTDIR}/misc/colors.idx
colordef
. ${BBROOTDIR}/config/apply_options.sh
. ${BBROOTDIR}/misc/commonfunctions.sh

BBLANG=$BBLANGdef
source_language_modules

# Create $HOMEDIR/.bashburnrc if it is not available
# Check if an old version is being used
if [[ -r $BBCONFFILE ]]
then
	if (! grep -q "VERSION: 3.1.x"  $BBCONFFILE)
	then
	message \
	"\n	You have an different version of $BBCONFFILE that
	will not work with version ${BBVERSION}.
	Please remove ${BBCONFFILE}, restart BashBurn, and
	immediately reconfigure ([option 4] in the main menu).\n"
	die
	 fi

fi
if [[ ! -r $BBCONFFILE ]]
then
    # We have no rc file and we have to say *something* so for now we will 
    # default to English
    message \
"There is no '${BBCONFFILE}'.
This is the file where BashBurn stores and reads its configuration.
BashBurn  will now attempt to create a default template file.
PLEASE remember to setup your configuration first [option 4] in the main menu."
    create_config
    if [[ -r $BBCONFFILE ]]
    then
	message "${BBCONFFILE} file created successfully..."
    else
	die 'Failed to create config file. This should not happen.
Please report this bug to the BashBurn developers.'
    fi
fi
# If we get to here then the rc file exists.
. ${BBROOTDIR}/misc/commands.idx
bb_parse_config

if [[ ! -d ${BBROOTDIR}/lang/${BBLANG} ]]
then
    message \
"Text files for configured language does not exist.
Defaulting to English."
    # Since the set language did not exist,
    # set it to English and save the option
    # so that in the future this message is not
    # shown again.
    BBLANG=English
fi

# Read in all files here
# This needs to go after all BBLANG help texts are completed/updated.
source_language_modules

# Function files
. ${BBROOTDIR}/burning/bincue.sh
. ${BBROOTDIR}/burning/burning.sh
. ${BBROOTDIR}/burning/multi.sh	
. ${BBROOTDIR}/convert/convert_audio.sh
. ${BBROOTDIR}/convert/convert_images.sh
. ${BBROOTDIR}/func/advancedfunc.sh
. ${BBROOTDIR}/func/audiofunc.sh
. ${BBROOTDIR}/func/bincuefunc.sh
. ${BBROOTDIR}/func/configfunc.sh
. ${BBROOTDIR}/func/datafunc.sh
. ${BBROOTDIR}/func/definefunc.sh
. ${BBROOTDIR}/func/isofunc.sh
. ${BBROOTDIR}/func/mountfunc.sh
. ${BBROOTDIR}/func/multifunc.sh
. ${BBROOTDIR}/menus/advanced.sh
. ${BBROOTDIR}/menus/audio_menu.sh
. ${BBROOTDIR}/menus/bbmenu.sh
. ${BBROOTDIR}/menus/configure.sh
. ${BBROOTDIR}/menus/datadefine.sh
. ${BBROOTDIR}/menus/data_menu.sh
. ${BBROOTDIR}/menus/iso_menu.sh
. ${BBROOTDIR}/menus/image_menu.sh
. ${BBROOTDIR}/menus/mount.sh
. ${BBROOTDIR}/misc/check_path.sh
. ${BBROOTDIR}/misc/loopback.sh
. ${BBROOTDIR}/misc/m3u_read.sh

apply_options

# Create temporary directory if it does not exist
mkdir -p $BBBURNDIR

define_global_menus
####PROGRAM START####
# bbmenu is called in a loop because
# the configure menu will cause an exit. This will give the mainmenu
# the opportunity to re-evaluate the array.
while true
do
    bbmenu bb_main_menu mainmenu
done
exit 0

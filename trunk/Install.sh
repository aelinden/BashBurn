#!/bin/bash

#functions

errmsg()
{
    echo "$prog:$@" 1>&2
}

die()
{
    errmsg "$@"
    exit 1
}

proc_opts()
{
    typeset temp
    typeset arg

    temp=$(getopt -o :P:UHm --long prefix:,uninstall,help,make-tar -n $prog -- "$@")
    (( $? )) && usage && die 'getopt failure'

    # Note the quotes around `$temp': they are essential!
    eval set -- "$temp"
    while true
    do
        case "$1" in
	-P|--prefix)
	    [[ -z "$potprefix" ]] || usage 'You already specified --destdir'
	    potprefix="$2"	# POTential PREFIX
	    shift 2
	    ;;
	-U|--uninstall)
	    (( unistall )) && usage 'You said --uninstall twice?'
	    uninstall=1
	    shift
	    ;;
	-H|--help)
	    help=1
	    shift
	    ;;
	-m|--make-tar)
	    (( maketar )) && usage 'You said --make-tar twice?'
	    maketar=1
	    shift
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    usage "$1: Unknown option"
	    ;;
        esac
    done
    (( $# > 0 )) && die "Too many arguments: $@"
} # proc_opts

usage()
{
    errmsg "$@"
    cat <<EOF 1>&2
Usage:
	$0 [OPTIONS]

	-P dir, --prefix=dir
	-U, --uninstall
	-H, --help
	-m, --make-tar

--prefix= will allow the user to specify the prefix directory 
where BashBurn will be installed or uninstalled.
The default is $defprefix. The support files will go
into \$dir/lib/BashBurn/lib and the program(s) will be in \$dir/bin

--uninstall will remove all of the BashBurn files from your system 
based on its knowledge of what prefix is.

--make-tar will create a .tar.bz2 file suitable for use in creating an RPM. 
           Must be used with --prefix.

--help This message

EOF
    exit 1
}

installation_finish()
{
    uninstall_info
    printf "\nInstallation finished successfully.
Now start %bBashBurn%b with the command %bbashburn%b, and
remember to configure it before trying to use it.\n\n" \
	"${green}" "${coloff}" "${blue}" "${coloff}"
}

install_files()
{
    typeset ii
    typeset jj
    typeset kk
    typeset -a dir_list=( \
	    burning \
	    config \
	    convert \
	    docs \
	    func \
	    lang \
	    menus \
	    misc \
	    )
    typeset -ra docs_files=( \
	    ChangeLog \
	    COPYING \
	    CREDITS \
	    FAQ \
	    HOWTO \
 	    README \
	    TODO \
	    TRANSLATION_RULE \
	    )
    typeset -ra top_files=( \
	    BashBurn.sh \
	    )
    typeset -ra burning_files=( \
	    bincue.sh \
	    burning.sh \
	    multi.sh \
	    )
    typeset -ra config_files=( \
	    apply_options.sh \
	    )
    typeset -ra convert_files=( \
	    convert_audio.sh \
	    convert_images.sh \
	    )
    typeset -ra func_files=( \
	    advancedfunc.sh \
	    audiofunc.sh \
	    bincuefunc.sh \
	    configfunc.sh \
	    datafunc.sh \
	    definefunc.sh \
	    isofunc.sh \
	    mountfunc.sh \
	    multifunc.sh \
	    )
	# Edit this when more languages are updated
    typeset -ra languages=( \
	    #Czech \
	    English \
	    German \
	    #Italian \
	    #Norwegian \
	    #Polish \
	    #Spanish \
	    Swedish \
	    )
    typeset -ra lang_files=( \
	    BashBurn.lang \
	    README \
	    advanced.lang \
	    audio_menu.lang \
	    bincue.lang \
	    burning.lang \
	    check_path.lang \
	    commonfunctions.lang \
	    configure.lang \
	    convert_audio.lang \
	    convert_images.lang \
	    data_menu.lang \
	    datadefine.lang \
	    iso_menu.lang \
	    image_menu.lang \
	    loopback.lang \
	    mount.lang \
	    multi.lang \
	    )
    typeset -ra menus_files=( \
	    advanced.sh \
	    audio_menu.sh \
	    bbmenu.sh
	    configure.sh \
	    datadefine.sh \
	    data_menu.sh \
	    iso_menu.sh \
	    image_menu.sh \
	    mount.sh \
	    )
    typeset -ra misc_files=( \
	    check_path.sh \
	    colors.idx \
	    commands.idx \
	    commonfunctions.sh \
	    loopback.sh \
	    m3u_read.sh \
	    configure_temp_help.lang \  # This needs to go after all BBLANG help
					# texts are completed/updated
	    )
    echo -e "\nInstalling files... "
    mkdir -p $bblib || die 'Error: Can not create lib directory.'
    for ii in "${dir_list[@]}"
    do
	mkdir -p $bblib/$ii || 
		die 'Error: Can not create a subdirectory in lib.'
	if [[ $ii == lang ]]
	then
	    for jj in "${languages[@]}"
	    do
		mkdir -p $bblib/$ii/$jj ||
			die 'Error: Can not create a lang directory.'
		for kk in $(eval echo "\${${ii}_files[@]}")
		do
		    cp "lang/${jj}/$kk" $bblib/$ii/$jj/ ||
		    die "Failed to copy $ii/$jj/$kk" ||
			die 'Error: Failed to copy a file to a lang dir.'
		done
	    done
	else
	    for kk in $(eval echo "\${${ii}_files[@]}")
	    do
		cp $ii/$kk $bblib/$ii/ || die "Failed to copy $ii/$kk"
	    done
	fi
    done
    for ii in "${top_files[@]}"
    do
	cp $ii $bblib/$ii || die "Failed to copy $ii"
    done
    # After installing, See what tickles are needed.
    make -C bashburn_man
    mkdir -p $prefix/share/man/man1
    gzip < bashburn_man/bashburn.1 > $prefix/share/man/man1/bashburn.1.gz
    if (( ! maketar ))
    then
	cd $bblib
	sed -e "s%@@BBROOTDIR@@%$bblib%" BashBurn.sh > newbb-$$.sh
	mv newbb-$$.sh BashBurn.sh
	chmod +x BashBurn.sh
	echo -e "${green}[DONE]${coloff}"

	echo -n "Creating symlink... "
	mkdir -p $bin || die 'Error could not create the bin directory.'
	ln -sf $bblib/BashBurn.sh $bin/bashburn || die "Can not create symlink"
	echo -e "${green}[DONE]${coloff}"

	echo -en "Setting ownership..."
	(( $(id -u) == 0 )) && chown -R root:root $bblib
	echo -e "${green}[DONE]${coloff}"
	installation_finish
    fi
}

uninstall_info()
{
    printf "\nTo remove %bBashBurn%b from your system, just run
%bInstall.sh --uninstall%b
to delete these files:
%b%s%b  (symlink)\n%b%s%b  (directory).\n" \
	"${green}" "${coloff}" "$blue" "$coloff" "$blue" "$bin/bashburn" "$coloff" "$blue" "$lib" "$coloff"
}

uninstall_files()
{
    printf "\nRemoving %bBashBurn%b from your system..." "$blue" "$coloff"
    rm -rf $bin/bashburn $bblib $prefix/share/man/man1/bashburn.1.gz
    echo -e "${green}[DONE]${coloff}\n\n"
}

intro_banner()
{
   printf "%b
   (             )  (                  
 ( )\    )    ( /(( )\   (  (          
 )((_)( /( (  )\())((_) ))\ )(   (     
((_)_ )(_)))\((_)((_)_ /((_)()\  )\ )  
%b | _%b )(_)_((_)%b |(_) _%b )_))( ((_)_(_/(  
%b | _ \ _\` (_-< ' \| _ \ || | '_| ' \%b))%b 
 |___\__,_/__/_||_|___/\_,_|_| |_||_|  
                                       
%b" "$yellow" "$red" "$yellow" "$red" "$yellow" "$red" "$yellow" "$red" "$coloff"
} 

# Keep in spectrum order
typeset -r red="\e[1;31m"
typeset -r yellow="\e[1;33m"
typeset -r green="\e[1;32m"
typeset -r blue="\e[1;36m"
typeset -r coloff="\e[1;0m"	# Color off.

prog=$0
typeset -i uninstall=0
typeset -i help=0
typeset -i maketar=0
typeset -r defprefix=/usr

proc_opts "$@"
(( maketar && uninstall )) && usage '--make-tar is incompatible with --uninstall'
if (( maketar )) && [[ -z "$potprefix" ]]
then
    usage '--make-tar requires --prefix'
fi
(( help )) && usage
if (( uninstall ))
then
    echo -e "\nUninstall script for:"
else
    echo -e "\nInstallation script for:"
fi
intro_banner 
sleep 2
prefix=${potprefix:=${defprefix}}
[[ "${prefix:${#foo}-1:1}" == / ]] && prefix="${prefix:0:${#prefix}-1}"
printf "Directory prefix has been set to $blue $prefix $coloff\n"
bin=${prefix}/bin
lib=${prefix}/lib/Bashburn
bblib=${lib}/lib
bbpo=${lib}/po
if (( uninstall ))
then
    uninstall_files
else
    install_files
fi
exit 0

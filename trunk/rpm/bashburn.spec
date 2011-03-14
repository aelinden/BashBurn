Name:		bashburn
Version:	3.1
Release:	1%{?dist}
Summary:	Thin interface used to manage cds and dvds written in bash
Group:		System Environment
License:	GPLv2
URL:		http://bashburn.dose.se/
Source0:	%{name}-%{version}.tar.bz2
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}
BuildArch:	noarch
Requires:	bash

%description
This package provides the bashburn command for operating on cds and dvds.

%prep
%setup -q

%build
:

%install
rm -rf %buildroot
echo "RPM_BUILD_ROOT:%buildroot"
echo "i'm in $PWD"
#mkdir -p %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)/usr
find . -print | cpio -pdum %buildroot/usr

%clean
rm -rf %buildroot


%files
%defattr(-,root,root,-)
%define bblib %{_libdir}/Bashburn/lib
%attr(0555,root,root) %{bblib}/BashBurn.sh
%{bblib}/burning/bincue.sh
%{bblib}/burning/burning.sh
%{bblib}/burning/multi.sh
%{bblib}/config/apply_options.sh
%{bblib}/convert/convert_audio.sh
%{bblib}/convert/convert_flacs.sh
%{bblib}/convert/convert_mp3s.sh
%{bblib}/convert/convert_oggs.sh
%{bblib}/docs/COPYING
%{bblib}/docs/CREDITS
%{bblib}/docs/ChangeLog
%{bblib}/docs/FAQ
%{bblib}/docs/HOWTO
%{bblib}/docs/README
%{bblib}/docs/TODO
%{bblib}/docs/TRANSLATION_RULE
%{bblib}/func/advancedfunc.sh
%{bblib}/func/audiofunc.sh
%{bblib}/func/bincuefunc.sh
%{bblib}/func/configfunc.sh
%{bblib}/func/datafunc.sh
%{bblib}/func/definefunc.sh
%{bblib}/func/isofunc.sh
%{bblib}/func/mountfunc.sh
%{bblib}/func/multifunc.sh
%{bblib}/lang/Czech/BashBurn.lang
%{bblib}/lang/Czech/README
%{bblib}/lang/Czech/advanced.lang
%{bblib}/lang/Czech/audio_menu.lang
%{bblib}/lang/Czech/bincue.lang
%{bblib}/lang/Czech/burning.lang
%{bblib}/lang/Czech/check_path.lang
%{bblib}/lang/Czech/commonfunctions.lang
%{bblib}/lang/Czech/configure.lang
%{bblib}/lang/Czech/convert_flacs.lang
%{bblib}/lang/Czech/convert_mp3s.lang
%{bblib}/lang/Czech/convert_oggs.lang
%{bblib}/lang/Czech/data_menu.lang
%{bblib}/lang/Czech/datadefine.lang
%{bblib}/lang/Czech/iso_menu.lang
%{bblib}/lang/Czech/loopback.lang
%{bblib}/lang/Czech/mount.lang
%{bblib}/lang/Czech/multi.lang
%{bblib}/lang/English/BashBurn.lang
%{bblib}/lang/English/README
%{bblib}/lang/English/advanced.lang
%{bblib}/lang/English/audio_menu.lang
%{bblib}/lang/English/bincue.lang
%{bblib}/lang/English/burning.lang
%{bblib}/lang/English/check_path.lang
%{bblib}/lang/English/commonfunctions.lang
%{bblib}/lang/English/configure.lang
%{bblib}/lang/English/convert_flacs.lang
%{bblib}/lang/English/convert_mp3s.lang
%{bblib}/lang/English/convert_oggs.lang
%{bblib}/lang/English/data_menu.lang
%{bblib}/lang/English/datadefine.lang
%{bblib}/lang/English/iso_menu.lang
%{bblib}/lang/English/loopback.lang
%{bblib}/lang/English/mount.lang
%{bblib}/lang/English/multi.lang
%{bblib}/lang/German/BashBurn.lang
%{bblib}/lang/German/README
%{bblib}/lang/German/advanced.lang
%{bblib}/lang/German/audio_menu.lang
%{bblib}/lang/German/bincue.lang
%{bblib}/lang/German/burning.lang
%{bblib}/lang/German/check_path.lang
%{bblib}/lang/German/commonfunctions.lang
%{bblib}/lang/German/configure.lang
%{bblib}/lang/German/convert_flacs.lang
%{bblib}/lang/German/convert_mp3s.lang
%{bblib}/lang/German/convert_oggs.lang
%{bblib}/lang/German/data_menu.lang
%{bblib}/lang/German/datadefine.lang
%{bblib}/lang/German/iso_menu.lang
%{bblib}/lang/German/loopback.lang
%{bblib}/lang/German/mount.lang
%{bblib}/lang/German/multi.lang
%{bblib}/lang/Italian/BashBurn.lang
%{bblib}/lang/Italian/README
%{bblib}/lang/Italian/advanced.lang
%{bblib}/lang/Italian/audio_menu.lang
%{bblib}/lang/Italian/bincue.lang
%{bblib}/lang/Italian/burning.lang
%{bblib}/lang/Italian/check_path.lang
%{bblib}/lang/Italian/commonfunctions.lang
%{bblib}/lang/Italian/configure.lang
%{bblib}/lang/Italian/convert_flacs.lang
%{bblib}/lang/Italian/convert_mp3s.lang
%{bblib}/lang/Italian/convert_oggs.lang
%{bblib}/lang/Italian/data_menu.lang
%{bblib}/lang/Italian/datadefine.lang
%{bblib}/lang/Italian/iso_menu.lang
%{bblib}/lang/Italian/loopback.lang
%{bblib}/lang/Italian/mount.lang
%{bblib}/lang/Italian/multi.lang
%{bblib}/lang/Norwegian/BashBurn.lang
%{bblib}/lang/Norwegian/README
%{bblib}/lang/Norwegian/advanced.lang
%{bblib}/lang/Norwegian/audio_menu.lang
%{bblib}/lang/Norwegian/bincue.lang
%{bblib}/lang/Norwegian/burning.lang
%{bblib}/lang/Norwegian/check_path.lang
%{bblib}/lang/Norwegian/commonfunctions.lang
%{bblib}/lang/Norwegian/configure.lang
%{bblib}/lang/Norwegian/convert_flacs.lang
%{bblib}/lang/Norwegian/convert_mp3s.lang
%{bblib}/lang/Norwegian/convert_oggs.lang
%{bblib}/lang/Norwegian/data_menu.lang
%{bblib}/lang/Norwegian/datadefine.lang
%{bblib}/lang/Norwegian/iso_menu.lang
%{bblib}/lang/Norwegian/loopback.lang
%{bblib}/lang/Norwegian/mount.lang
%{bblib}/lang/Norwegian/multi.lang
%{bblib}/lang/Polish/BashBurn.lang
%{bblib}/lang/Polish/README
%{bblib}/lang/Polish/advanced.lang
%{bblib}/lang/Polish/audio_menu.lang
%{bblib}/lang/Polish/bincue.lang
%{bblib}/lang/Polish/burning.lang
%{bblib}/lang/Polish/check_path.lang
%{bblib}/lang/Polish/commonfunctions.lang
%{bblib}/lang/Polish/configure.lang
%{bblib}/lang/Polish/convert_flacs.lang
%{bblib}/lang/Polish/convert_mp3s.lang
%{bblib}/lang/Polish/convert_oggs.lang
%{bblib}/lang/Polish/data_menu.lang
%{bblib}/lang/Polish/datadefine.lang
%{bblib}/lang/Polish/iso_menu.lang
%{bblib}/lang/Polish/loopback.lang
%{bblib}/lang/Polish/mount.lang
%{bblib}/lang/Polish/multi.lang
%{bblib}/lang/Spanish/BashBurn.lang
%{bblib}/lang/Spanish/README
%{bblib}/lang/Spanish/advanced.lang
%{bblib}/lang/Spanish/audio_menu.lang
%{bblib}/lang/Spanish/bincue.lang
%{bblib}/lang/Spanish/burning.lang
%{bblib}/lang/Spanish/check_path.lang
%{bblib}/lang/Spanish/commonfunctions.lang
%{bblib}/lang/Spanish/configure.lang
%{bblib}/lang/Spanish/convert_flacs.lang
%{bblib}/lang/Spanish/convert_mp3s.lang
%{bblib}/lang/Spanish/convert_oggs.lang
%{bblib}/lang/Spanish/data_menu.lang
%{bblib}/lang/Spanish/datadefine.lang
%{bblib}/lang/Spanish/iso_menu.lang
%{bblib}/lang/Spanish/loopback.lang
%{bblib}/lang/Spanish/mount.lang
%{bblib}/lang/Spanish/multi.lang
%{bblib}/lang/Swedish/BashBurn.lang
%{bblib}/lang/Swedish/README
%{bblib}/lang/Swedish/advanced.lang
%{bblib}/lang/Swedish/audio_menu.lang
%{bblib}/lang/Swedish/bincue.lang
%{bblib}/lang/Swedish/burning.lang
%{bblib}/lang/Swedish/check_path.lang
%{bblib}/lang/Swedish/commonfunctions.lang
%{bblib}/lang/Swedish/configure.lang
%{bblib}/lang/Swedish/convert_flacs.lang
%{bblib}/lang/Swedish/convert_mp3s.lang
%{bblib}/lang/Swedish/convert_oggs.lang
%{bblib}/lang/Swedish/data_menu.lang
%{bblib}/lang/Swedish/datadefine.lang
%{bblib}/lang/Swedish/iso_menu.lang
%{bblib}/lang/Swedish/loopback.lang
%{bblib}/lang/Swedish/mount.lang
%{bblib}/lang/Swedish/multi.lang
%{bblib}/menus/advanced.sh
%{bblib}/menus/audio_menu.sh
%{bblib}/menus/bbmenu.sh
%{bblib}/menus/configure.sh
%{bblib}/menus/data_menu.sh
%{bblib}/menus/datadefine.sh
%{bblib}/menus/iso_menu.sh
%{bblib}/menus/mount.sh
%{bblib}/misc/check_path.sh
%{bblib}/misc/colors.idx
%{bblib}/misc/commands.idx
%{bblib}/misc/commonfunctions.sh
%{bblib}/misc/configure_temp_help.lang
%{bblib}/misc/loopback.sh
%{bblib}/misc/m3u_read.sh
%doc
/usr/share/man/man1/bashburn.1.gz

%post
	sed -e "s^@@BBROOTDIR@@^%{bblib}^" %{bblib}/BashBurn.sh > newbb-$$.sh
	mv newbb-$$.sh %{bblib}/BashBurn.sh
	chmod 755 %{bblib}/BashBurn.sh
	mkdir -p %{_bindir}
	ln -sf %{bblib}/BashBurn.sh %{_bindir}/bashburn




%changelog

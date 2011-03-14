# With credits to the backup manager authors from which this file
# was copied.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Real gettext library.

# Initialize the gettext stuff
. /usr/bin/gettext.sh

# Which prefix name the mo file has (e.g. bashburn_test.mo -> bashburn_test):
TEXTDOMAIN=bashburn_test
export TEXTDOMAIN

# Where mo files live (not necessary if mo files are in dir "/usr/share/locale").
# Note to specify path only until 'locale':
TEXTDOMAINDIR=./locale
export TEXTDOMAINDIR

# This is the wrapper to the gettext function
# We use eval_gettext in order to substitue every
# variable prensent in the string.
translate()
{
	eval_gettext "$1"; echo
}

# This can do an echo with -n or not, and after 
# having gettextized the string.
echo_translated()
{
	if [ "$1" = "-n" ]; then
		message=$(translate "$2")
		echo -n "$message"
	else
		message=$(translate "$1")
		echo "$message"
	fi
}

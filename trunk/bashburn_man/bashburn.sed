#1s/^\(.*\)$/\.TH \1/
/NAME/s/^\(.*\)$/\.SH \1/
/DESCRIPTION/s/^\(.*\)$/\.SH \1/
/\<INFORMATION\>/s/^\(.*\)$/\.SH \1/
/\<USAGE\>/s/^\(.*\)$/\.SH \1/
/\<TRANSLATION\>/s/^\(.*\)$/\.SH \1/
/\<INSTALLATION\>/s/^\(.*\)$/\.SS \1/
/\<CONFIGURATION\>/s/^\(.*\)$/\.SS \1/
/\<TRANSLATOR MASTER\>/s/^\(.*\)$/\.SS \1/
/\<FAQ\>/s/^\(.*\)$/\.SH \1/
/\<SEE ALSO\>/s/^\(.*\)$/\.SH \1/
/AUTHOR/s/^\(.*\)$/\.SH \1/
/MANPAGE/s/^\(.*\)$/\.SH \1/
/LICENSE/s/^\(.*\)$/\.SH \1/
/CONTACTS/s/^\(.*\)$/\.SH \1/
/UPDATES/s/^\(.*\)$/\.SS \1/

s/bashburn/\\fIbashburn\\fR/g
s/BashBurn/\\fIBashBurn\\fR/g
/11111/,/22222/{
a\
.br
}
/EXAMPLEMARK/,/EXAMPLEMARK/{
a\
.br
}
/EXAMPLEMARK/s///
/11111/s///
/22222/s///

/SEE ALSO/,/AUTHOR/{
/^[a-z]/s/^\(.*\)$/\.BR \1/
s/(\([1-9]\))/ "(\1), "/g
s/(C++)/ "(C++), "/g
s/(C++)$/ "(C++)"/
}

/UPDATES/{
i\

a\
	See  http://bashburn.dose.se/  for updates.
}
/AUTHOR/{
i\

a\
   	\\fI\\fRAnders\ \\fI\\fRLinden et alia
}

/MANPAGE/{
i\

a\
   	For any man page errors please report to the developers (see CONTACTS)
}

/TRANSLATOR MASTER/{
i\

a\
   	\\fI\\fRMarkus\ \\fI\\fRKollmar
}

/LICENSE/{
i\

a\
	BashBurn is released under the GNU GPL - http://www.gnu.org/copyleft/gpl.html
}

/CONTACTS/{
i\

a\
	http://bashburn.dose.se/index.php?s=contacts
}

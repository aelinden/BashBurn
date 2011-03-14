BB		:= bashburn

all		:		${BB}.1

${BB}.1	:		${BB}.template ${BB}.sed
	sed -f ${BB}.sed ${BB}.template > $@

clean		:
	rm -f ${BB}.1 ${BB}.man ${BB}.ps

${BB}.man	:		${BB}.1
	groff -pte -man -Tascii $< > $@

${BB}.ps	:		${BB}.1
	groff -pte -man $< > $@

.PHONY: clean

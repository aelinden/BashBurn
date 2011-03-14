# Generates all needed i18n-language files for bashburn.
#
# Bashburn uses the GNU "gettext" tools to make this.
# The process in short is as following:
#
# SRC_FILE -> POT_FILE -> PO_FILE -> MO_FILE
#
# VERSION: 10okt2008
# MAINTAINER: Markus Kollmar
###############################################################################

# Name of package (project) which to translate:
PACKAGE='bashburn_test'

# Installation dir prefix for mo-files:
MO_DIR='./locale/'

# Prefix where po files and fresh created mo files live:
PO_DIR='po/'

# Specifies a file in which all source files with translatable strings are listed:
SRC_FILE_LIST='TRANSLATION_FILES'

# We dump all translation textes into one file:
POT_FILE=$(PACKAGE).pot

# Here are the language files which a translator should translate. For this he
# can use any editor or special po-editor's like emacs+po-mode, KBabel,...
PO_FILES=$(shell ls $(PO_DIR)*.po)

# This are the machine object files. This are binary files which are <m>achine
# dependent.
MO_FILES=$(patsubst %.po,%.mo,$(PO_FILES))

###############################################################################

all: POT PO MO

add_language: PO
	msginit -i $(POT_FILE) -l $(lang) -o $(PO_DIR)$(lang).po

.PHONY: help
help:
	@echo "-> Create POT file if none is existent: 'make POT'"
	@echo "-> Create new language translation sceleton if it is not existent (in po dir): 'make add_language lang=de_DE'"
	@echo "-> Update/make translation: 'make'"
	@echo "-> Install translation (mo-files): 'make install [MO_DIR=<other_mo_dir>]'"
	@echo "-> Check translation and get status: 'make check'"
	@echo "-> Clean temporary files (which can be easily generated) if needed again): 'make clean'"

install: $(MO_FILES)
	echo "Installing mo files..."
	for file in $(MO_FILES); do \
	    lang=`echo $${file} | sed -e 's/.*\([a-zA-Z_]\{2\}\)\.mo$\/\1/g'`; \
	    echo "$${lang}"; \
	    install -d $(MO_DIR)$${lang}/LC_MESSAGES/; \
	    install -m 0644 $${file} $(MO_DIR)$${lang}/LC_MESSAGES/$(PACKAGE).mo; \
	done

.PHONY: POT
POT:
	xgettext --keyword=echo_translated --language=Shell -o $(POT_FILE) --files-from=$(SRC_FILE_LIST)

PO: POT $(PO_FILES)
	for file in $(PO_FILES); do \
	    echo "Merging $(POT_FILE) and $${file}"; \
	    msgmerge $${file} $(POT_FILE) -o $${file}.new; \
	    if [ "`diff $${file} $${file}.new | grep '[<>]' | wc -l`" -ne 2 ]; \
	    then \
	        mv -f $${file}.new $${file}; \
	    else \
	        rm -f $${file}.new; \
	    fi \
	done

MO: $(PO_FILES)
	@for file in $(PO_FILES); do \
	    lang=`echo $${file} | sed 's/\.po//'`; \
	    msgfmt -o /dev/null -c -v --statistics $${file}; \
	    msgfmt --no-hash -o $${lang}.mo $${file}; \
	done

.PHONY: check
check:
	@for file in $(PO_FILES); do \
	    printf "$${file}: "; \
	    msgfmt -o /dev/null -c -v --statistics $${file}; \
	done

.PHONY: clean
clean:
	rm -fr locale $(MO_FILES) $(POT_FILE)

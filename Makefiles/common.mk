.PHONY : all_and_more all clean install


LATEXMODE=-interaction nonstopmode -recorder

LATEX=latex

# Define it at 0 if it does not exist:
USE_PDFTEX ?= 0
ifeq ($(USE_PDFTEX),1)
	LATEX=pdflatex
	TEX_TARGET=pdf
else
	TEX_TARGET=dvi
endif


#batchmode

# If we want to add directories to the TEXINPUTS path:
ifdef INSERT_TEXINPUTS
ifdef TEXINPUTS
TEXINPUTS:=$(INSERT_TEXINPUTS):$(TEXINPUTS)
else
TEXINPUTS:=$(INSERT_TEXINPUTS)::
endif
# Export the new path to all sub-commands:
export TEXINPUTS
endif

ifdef APPEND_TEXINPUTS
ifdef TEXINPUTS
TEXINPUTS:=$(TEXINPUTS):$(APPEND_TEXINPUTS)
else
TEXINPUTS:=::$(APPEND_TEXINPUTS)
endif
# Export the new path to all sub-commands:
export TEXINPUTS
endif

ifdef MAKEINDEX
	# Permute a LaTeX index insitu
	# Don't deal with '"!' to escape the '!'. TODO...
	# Rebuild the French accented letters to have better sorting
	COMPUTE_INDEX = sed --in-place -e "s/\\\\'e/é/g" -e "s/\\\\'E/É/g" -e 's/\\`a/à/g' -e 's/\\`A/À/g' -e 's/\\`e/è/g' -e 's/\\`E/È/g' -e 's/\\IeC {\\^\\i }/î/g' -e 's/^\(\\indexentry{\)\([^!]\+\)!\([^!]\+\)!\([^!]\+\)\(}{[^{}]\+}\)$$/\1\2!\3!\4\5\n\1\2!\4!\3\5\n\1\3!\2!\4\5\n\1\3!\4!\2\5\n\1\4!\2!\3\5\n\1\4!\3!\2\5/' -e 's/^\(\\indexentry{\)\([^!]\+\)!\([^!]\+\)\(}{[^{}]\+}\)$$/\1\2!\3\4\n\1\3!\2\4/' $(1).idx; makeindex $(1)
else
	COMPUTE_INDEX =
endif

# To publish stuff on the Par4All site:
PUBLISHING_HOST=download.par4all.org
PUBLISHING_DIR=/srv/www-par4all/download/doc



all : all_and_more $(FILES_TO_INSTALL) $(OTHER_FILES_TO_INSTALL)

install:
	# Install somewhere on the same host, for example in a directory
	# that will be published somewhere, such as ~/public_html
	mkdir -p $(INSTALL_SUBDIR)
	cp -p $(FILES_TO_INSTALL) $(OTHER_FILES_TO_INSTALL) $(INSTALL_SUBDIR)

publish:
	# Publish stuff on the WWW site:
	ssh $(PUBLISHING_HOST) mkdir -p $(PUBLISHING_DIR)/$(PUBLISHING_SUBDIR)
	scp -pr $(FILES_TO_INSTALL) $(OTHER_FILES_TO_INSTALL) $(PUBLISHING_HOST):$(PUBLISHING_DIR)/$(PUBLISHING_SUBDIR)

clean::
	-rm -- $(FILES_TO_GENERATE) *.aux *.bbl *.blg *.dvi *.fls *.idx *.ilg *.ind *.log *.los *.nav *.out *.rel *.snm *.tmp *.toc *.vrb $(MORE_FILES_TO_CLEAN)

%.gz : %
	-gzip -f -9 $<

%.ps : %.dvi Makefile
	dvips $* -o

%.$(TEX_TARGET) : %.tex $(SOURCES) Makefile
	echo $$TEXINPUTS
	-$(LATEX) $(LATEXMODE) '\def\VersionExpose{}\input{'$*'}'
	# Twice because of some BibTeXing...
	-bibtex $*
	-$(call COMPUTE_INDEX,$*)
	-makeindex $*
	-$(LATEX) $(LATEXMODE) '\def\VersionExpose{}\input{'$*'}'

%.pdf : %.ps Makefile
	# Avoid weird autorotating inspiration since it is always in the same
	# orientation
	ps2pdf -dAutoRotatePages=/None $*.ps $*.pdf

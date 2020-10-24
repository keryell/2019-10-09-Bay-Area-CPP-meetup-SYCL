# A Makefile to compute a Beamer presentation with also a handout version
# Ronan.Keryell@xilinx.com

# Compute the absolute top directory from the makefile position:
TEX_ROOT=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

# To find TeX libraries and images
INSERT_TEXINPUTS=::$(TEX_ROOT)/TeX//:$(TEX_ROOT)/Images//:$(TEX_ROOT)

# Parameter variables:
# DOCUMENT : the LaTeX document
# INSTALL_SUBDIR : where to install for publication
# OTHER_FILES_TO_INSTALL : some stuff to install but the LaTeX output.
# TEX_ROOT should point to where our local TeX stuff is installed.

# To be defined elsewhere when including this Makefile:

FILES_TO_INSTALL = $(DOCUMENT)-expose.pdf $(DOCUMENT)-copie.pdf

FILES_TO_GENERATE += $(FILES_TO_INSTALL)

MORE_FILES_TO_CLEAN = $(DOCUMENT)-expose.tex $(DOCUMENT)-copie.tex

# Define it at 0 if it does not exist:
USE_PDFTEX ?= 0
ifeq ($(USE_PDFTEX),1)
	LATEX:=pdflatex
	TEX_TARGET:=pdf
else
	TEX_TARGET:=dvi
endif

%-expose.tex: %.tex
	ln -s $< $@

%-copie.tex: %.tex
	ln -s $< $@

%-expose.$(TEX_TARGET) : %-expose.tex $(SOURCES) Makefile
	echo $$TEXINPUTS
	-$(LATEX) $(LATEXMODE) '\def\VersionExpose{}\input{'$*-expose'}'
	# Twice because of some BibTeXing...
	-bibtex $*-expose
	-$(call COMPUTE_INDEX,$*-expose)
	-$(LATEX) $(LATEXMODE) '\def\VersionExpose{}\input{'$*-expose'}'
#	-$(LATEX) $(LATEXMODE) '\def\VersionExpose{}\input{'$*-expose'}'

%-copie.$(TEX_TARGET) : %-copie.tex $(SOURCES) Makefile
	echo $$TEXINPUTS
	# Now rely on psnup do have 4 tr/p for better toc numbering
	-$(LATEX) $(LATEXMODE) '\def\VersionNoTwoUp{}\input{'$*-copie'}'
	# Twice because of some BibTeXing...
	-bibtex $*-copie
	-$(call COMPUTE_INDEX,$*-copie)
	-$(LATEX) $(LATEXMODE) '\def\VersionNoTwoUp{}\input{'$*-copie'}'
	-$(LATEX) $(LATEXMODE) '\def\VersionNoTwoUp{}\input{'$*-copie'}'

include $(TEX_ROOT)/Makefiles/common.mk

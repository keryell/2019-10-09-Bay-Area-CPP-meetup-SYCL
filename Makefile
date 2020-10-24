world: 2019-10-09-Bay-Area-C++-meetup-SYCL.pdf

# We have an index to compute
#MAKEINDEX=1

# Use pdfLaTeX instead of the legacy DVI LaTeX
USE_PDFTEX=1
#USE_PDFTEX=0

include Makefiles/beamer.mk

# To compile the modern C++ programs
CXXFLAGS = -std=c++2a
LDLIBS += -lboost_system -lboost_filesystem -lpthread

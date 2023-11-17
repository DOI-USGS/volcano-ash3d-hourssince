##############################################################################
#  Makefile for libhourssince.a
#
#    User-specified flags are in this top block
#
###############################################################################

#      This file is a component of the volcanic ash transport and dispersion model Ash3d,
#      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov),
#      Larry G. Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).

#      The model and its source code are products of the U.S. Federal Government and therefore
#      bear no copyright.  They may be copied, redistributed and freely incorporated 
#      into derivative products.  However as a matter of scientific courtesy we ask that
#      you credit the authors and cite published documentation of this model (below) when
#      publishing or distributing derivative products.

#      Schwaiger, H.F., Denlinger, R.P., and Mastin, L.G., 2012, Ash3d, a finite-
#         volume, conservative numerical model for ash transport and tephra deposition,
#         Journal of Geophysical Research, 117, B04204, doi:10.1029/2011JB008968. 

#      We make no guarantees, expressed or implied, as to the usefulness of the software
#      and its documentation for any purpose.  We assume no responsibility to provide
#      technical support to users of this software.

#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort
#    This variable cannot be left blank
#      
SYSTEM = gfortran
#SYSTEM = ifort
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#    This variable cannot be left blank

RUN = DEBUG
#RUN = PROF
#RUN = OPT
#RUN = OMPOPT
#
INSTALLDIR=/opt/USGS
#INSTALLDIR=$(HOME)/intel

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################



###############################################################################
###############################################################################

###############################################################################
##########  GNU Fortran Compiler  #############################################
ifeq ($(SYSTEM), gfortran)
    FCHOME=/usr
    FC = /usr/bin/gfortran
    COMPINC = -I./ -I$(FCHOME)/include -I$(FCHOME)/lib64/gfortran/modules
    COMPLIBS = -L./ -L$(FCHOME)/lib64
    LIBS = $(COMPLIBS) $(COMPINC)

# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS = -O0 -g3 -Wall -Wextra -fimplicit-none  -Wall  -Wline-truncation  -Wcharacter-truncation  -Wsurprising  -Waliasing  -Wimplicit-interface  -Wunused-parameter  -fwhole-file  -fcheck=all  -std=f2008  -pedantic  -fbacktrace -Wunderflow -ffpe-trap=invalid,zero,overflow -fdefault-real-8
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g -pg -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
endif
    EXFLAGS =
endif
###############################################################################
##########  Intel Fortran Compiler  #############################################
ifeq ($(SYSTEM), ifort)
    FCHOME = /opt/intel/oneapi/compiler/latest/linux/
    FC = $(FCHOME)/bin/intel64/ifort
    COMPINC = -I./ -I$(FCHOME)/include
    COMPLIBS = -L./ -L$(FCHOME)/lib
    LIBS = $(COMPLIBS) $(COMPINC)

# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -traceback -ftrapuv -debug all
endif
#ifeq ($(RUN), DEBUGOMP)
#    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -traceback -ftrapuv -debug all -openmp
#endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g2 -pg
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -ftz -w -ipo
endif
ifeq ($(RUN), OMPOPT)
    FFLAGS = -O3 -ftz -w -ipo -openmp
endif
      # Extra flags
    EXFLAGS =
endif
###############################################################################


LIB = libhourssince.a

EXEC = \
 HoursSince1900 \
 yyyymmddhh_since_1900

###############################################################################
# TARGETS
###############################################################################

lib: $(LIB)

tools: $(EXEC)

test: testHours

all: libhourssince.a $(EXEC) makefile testHours

libhourssince.a: HoursSince.f90 HoursSince.o makefile
	ar rcs libhourssince.a HoursSince.o
HoursSince.o: HoursSince.f90 makefile
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) -c HoursSince.f90
HoursSince1900: HoursSince1900.f90 HoursSince.o
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) HoursSince1900.f90 HoursSince.o -o HoursSince1900
yyyymmddhh_since_1900: yyyymmddhh_since_1900.f90 HoursSince.o
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) yyyymmddhh_since_1900.f90 HoursSince.o -o yyyymmddhh_since_1900
testHours: testHours.f90 HoursSince.o makefile
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) testHours.f90 HoursSince.o -o testHours

clean:
	rm -f *.o *__genmod.f90 *__genmod.mod
	rm -f libhourssince.a
	rm -f $(EXEC) testHours

install:
	install -d $(INSTALLDIR)/lib/
	install -d $(INSTALLDIR)/bin/
	install -m 644 $(LIB) $(INSTALLDIR)/lib/
	install -m 755 $(EXEC) $(INSTALLDIR)/bin/

uninstall:
	rm -f $(INSTALLDIR)/lib/$(LIB)
	rm -f $(INSTALLDIR)/bin/HoursSince1900
	rm -f $(INSTALLDIR)/bin/yyyymmddhh_since_1900



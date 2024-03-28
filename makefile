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

#      Sequence of commands:
#      "make"  compiles the libhourssince.a library
#      "make all" builds the library, and the tools executables
#      "make check" runs two test cases
#      "make install" copies the library to the install location
#                        e.g. /opt/USGS
#
#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort , aocc
#    This variable cannot be left blank
#
SYSTEM = gfortran
SYSINC = make_$(SYSTEM).inc
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#      OPT   : includes optimizations flags for fastest runtime
#    This variable cannot be left blank

#RUN = DEBUG
#RUN = PROF
RUN = OPT

INSTALLDIR=/opt/USGS

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################

###############################################################################
# Import the compiler-specific include file.  Currently one of:
#  GNU Fortran Compiler
#  Intel Fortran Compiler
#  AMD Optimizing C/C++/Fortran Compiler (aocc)
include $(SYSINC)
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

all: libhourssince.a $(EXEC) makefile $(SYSINC) testHours

libhourssince.a: HoursSince.f90 HoursSince.o makefile $(SYSINC)
	ar rcs libhourssince.a HoursSince.o
HoursSince.o: HoursSince.f90 makefile $(SYSINC)
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) -c HoursSince.f90
HoursSince1900: HoursSince1900.f90 HoursSince.o $(SYSINC)
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) HoursSince1900.f90 HoursSince.o -o HoursSince1900
yyyymmddhh_since_1900: yyyymmddhh_since_1900.f90 HoursSince.o
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) yyyymmddhh_since_1900.f90 HoursSince.o -o yyyymmddhh_since_1900
testHours: testHours.f90 HoursSince.o makefile $(SYSINC)
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) testHours.f90 HoursSince.o -o testHours
check: testHours HoursSince1900 makefile $(SYSINC)
	bash check.sh

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


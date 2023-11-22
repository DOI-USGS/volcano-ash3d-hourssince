HoursSince
==========

HoursSince is a collection of functions and subroutines that calculate
the number of hours of a given calendar date from Jan. 1 of a reference year.
These functions were written as a component of the USGS volcanic ash
transport and dispersion model, Ash3d.  However, since they are useful for
other programs outside of Ash3d, they are collected into a stand-along file
that can either be compiled as a library or simply compiled directly with
other source code.

To compile as a library, simple type:

  `make`

Some subroutines in HoursSince.f90 have stand-alone wrapper programs, using 1900
as the base year for the hours calculation.  
  `HoursSince1900`  
  `yyyymmddhh_since_1900`

To compile these wrapper programs, type:

  `make tools`

To test the library, type:

  `make check`

This will run two tests.  The first, the self-test program `testHours` which
verifies internal consistency of the subroutines.  Second, the program
`HoursSince1900` is used to calculate hour differences between random date
pairs, with a comparison to the calculation using the unix `date` command.

To install the library, edit the `INSTALLDIR` variable of the makefile (the
default is `/opt/USGS`) and type:

  `make install`

You will need to have write permission in `${INSTALLDIR}` or install as root.


Authors
-------

Hans F. Schwaiger <hschwaiger@usgs.gov>  
Larry G. Mastin <lgmastin@usgs.gov>  
Roger P. Denlinger <rdenlinger@usgs.gov>

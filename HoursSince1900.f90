!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!      This file is a component of the volcanic ash transport and dispersion model Ash3d,
!      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov),
!      Larry G. Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).
!
!      The model and its source code are products of the U.S. Federal Government and therefore
!      bear no copyright.  They may be copied, redistributed and freely incorporated 
!      into derivative products.  However as a matter of scientific courtesy we ask that
!      you credit the authors and cite published documentation of this model (below) when
!      publishing or distributing derivative products.
!
!      Schwaiger, H.F., Denlinger, R.P., and Mastin, L.G., 2012, Ash3d, a finite-
!         volume, conservative numerical model for ash transport and tephra deposition,
!         Journal of Geophysical Research, 117, B04204, doi:10.1029/2011JB008968. 
!
!      Although this program has been used by the USGS, no warranty, expressed or
!      implied, is made by the USGS or the United States Government as to the accuracy
!      and functioning  of the program and related program material nor shall the fact of
!      distribution constitute  any such warranty, and no responsibility is assumed by
!      the USGS in connection therewith.
!
!      We make no guarantees, expressed or implied, as to the usefulness of the software
!      and its documentation for any purpose.  We assume no responsibility to provide
!      technical support to users of this software.
!
!      This program is just a wrapper for the function call to
!      HS_hours_since_baseyear with base_year set to 1900
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


      program hours_since_1900

!     input iyear,imonth,iday,hours
      
!     function that calculates the number of hours since 1900 of a year, month, day, and hour (UT)      
      ! Check against calculator on
      ! http://www.7is7.com/otto/datediff.html

      implicit none

      integer              :: iyear,imonth
      integer              :: iday
      integer              :: nargs
      character(len=80)    :: garbage1, garbage2, garbage3, garbage4
      real(kind=8)         :: hours
      real(kind=8)         :: hours_out
      real(kind=8)         :: HS_hours_since_baseyear     ! function that calculates hours

      integer :: byear    = 1900
      logical :: useLeaps = .true.

!     TEST READ COMMAND LINE ARGUMENTS
      nargs = iargc()
      if (nargs.lt.4) then
           write(6,*) 'error in input to HoursSince1900'
           write(6,*) 'input should be year month day hour'
           write(6,*) 'program stopped'
           stop 1
         else
           call getarg(1,garbage1)
           call getarg(2,garbage2)
           call getarg(3,garbage3)
           call getarg(4,garbage4)
           read(garbage1,*) iyear
           read(garbage2,*) imonth
           read(garbage3,*) iday
           read(garbage4,*) hours
      end if

      hours_out = HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)

      write(6,'(f12.2)') hours_out

      end program hours_since_1900


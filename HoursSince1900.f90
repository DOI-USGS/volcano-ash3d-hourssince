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

      ! This module requires Fortran 2003 or later
      use iso_fortran_env, only : &
         input_unit,output_unit,error_unit

!     input iyear,imonth,iday,hours
      
!     program that calculates the number of hours since 1900 of a year, month, day, and hour (UT)      
      ! Check against calculator on
      ! http://www.7is7.com/otto/datediff.html

      implicit none

      integer             :: iyear
      integer             :: imonth
      integer             :: iday
      integer             :: nargs
      character(len=80)   :: arg1, arg2, arg3, arg4
      integer             :: iostatus
      character(len=120)  :: iomessage
      integer             :: inlen
      real(kind=8)        :: hours
      real(kind=8)        :: hours_out

      integer :: byear    = 1900
      logical :: useLeaps = .true.

      INTERFACE
        real(kind=8) function HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)
          integer     ,intent(in) :: iyear
          integer     ,intent(in) :: imonth
          integer     ,intent(in) :: iday
          real(kind=8),intent(in) :: hours
          integer     ,intent(in) :: byear
          logical     ,intent(in) :: useLeaps
        end function HS_hours_since_baseyear
      END INTERFACE

!     TEST READ COMMAND LINE ARGUMENTS
      nargs = command_argument_count()
      if (nargs.lt.4) then
        write(error_unit,*) 'error in input to HoursSince1900'
        write(error_unit,*) 'input should be year month day hour'
        write(error_unit,*) 'program stopped'
        stop 1
      else
        call get_command_argument(1, arg1, length=inlen, status=iostatus)
        if(iostatus.ne.0)write(error_unit,*)"ERROR: could not read command-line argument (1)"
        call get_command_argument(2, arg2, length=inlen, status=iostatus)
        if(iostatus.ne.0)write(error_unit,*)"ERROR: could not read command-line argument (2)"
        call get_command_argument(3, arg3, length=inlen, status=iostatus)
        if(iostatus.ne.0)write(error_unit,*)"ERROR: could not read command-line argument (3)"
        call get_command_argument(4, arg4, length=inlen, status=iostatus)
        if(iostatus.ne.0)write(error_unit,*)"ERROR: could not read command-line argument (4)"
        read(arg1,*,iostat=iostatus,iomsg=iomessage) iyear
        if(iostatus.ne.0)then
          write(error_unit,*)"ERROR: could not read comand-line argument (1)"
          write(error_unit,*)" iyear = ",iyear
          write(error_unit,*)iomessage
          stop 1
        endif
        read(arg2,*,iostat=iostatus,iomsg=iomessage) imonth
        if(iostatus.ne.0)then
          write(error_unit,*)"ERROR: could not read comand-line argument (1)"
          write(error_unit,*)" imonth = ",imonth
          write(error_unit,*)iomessage
          stop 1
        endif
        read(arg3,*,iostat=iostatus,iomsg=iomessage) iday
        if(iostatus.ne.0)then
          write(error_unit,*)"ERROR: could not read comand-line argument (1)"
          write(error_unit,*)" iday = ",iday
          write(error_unit,*)iomessage
          stop 1
        endif
        read(arg4,*,iostat=iostatus,iomsg=iomessage) hours
        if(iostatus.ne.0)then
          write(error_unit,*)"ERROR: could not read comand-line argument (1)"
          write(error_unit,*)" hours = ",hours
          write(error_unit,*)iomessage
          stop 1
        endif
      endif

      hours_out = HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)

      write(output_unit,'(f12.2)') hours_out

      end program hours_since_1900


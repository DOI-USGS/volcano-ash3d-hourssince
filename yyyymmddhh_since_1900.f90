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


      program yyyymmddhh_since_1900


!     Stand-alone version of the function HS_yyyymmddhh_since with baseyear
!     set to 1900.
!     Returns a character string yyyymmddhh.hh giving the year, month, day, and hour, given
!     the number of hours since January 1, 1900.

      implicit none

      character (len=18)   ::  string1
      character (len=80)   ::  linebuffer
      integer              ::  status
      real(kind=8)         ::  HoursSince1900
      integer              ::  iyear, imonth, iday, ihour, ifraction, idoy
      real(kind=8)         ::  fraction, hour
      integer              ::  nargs

      integer :: iostatus
      character(len=120) :: iomessage

      integer :: byear    = 1900
      logical :: useLeaps = .true.

      INTERFACE
        subroutine HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)
          real(kind=8),intent(in)       :: HoursSince
          integer     ,intent(in)       :: byear
          logical     ,intent(in)       :: useLeaps
          integer     ,intent(out)      :: iyear
          integer     ,intent(out)      :: imonth
          integer     ,intent(out)      :: iday
          real(kind=8),intent(out)      :: hours
          integer     ,intent(out)      :: idoy
        end subroutine
      END INTERFACE

      !TEST READ COMMAND LINE ARGUMENTS
      nargs = command_argument_count()
      if (nargs.ne.1) then
        write(6,*) 'error in input to yyyymmddhh_since_1900'
        write(6,*) 'input should be a single real number.'
        write(6,*) 'program stopped'
        stop
      else
        call get_command_argument(1, linebuffer, status)
        read(linebuffer,*,iostat=iostatus,iomsg=iomessage) HoursSince1900
        if(iostatus.ne.0)then
          write(6,*)'HS ERROR:  Error reading value from command-line argument'
          write(6,*)'           Expecting to read: HoursSince1900 (real*8)'
          write(6,*)'           From the following input line : '
          write(6,*)linebuffer
          write(6,*)'HS System Message: '
          write(6,*)iomessage
          stop 1
        endif
      endif

      call HS_Get_YMDH(HoursSince1900,byear,useLeaps,iyear,imonth,iday,hour,idoy)

      ihour = int(hour)
      fraction = hour-real(ihour,kind=8)
      if(fraction.gt.1.0_8)then
        ! if the nearest integer of ifraction is actually the next
        ! hour, adjust ifraction and ihour accordingly
        ihour = ihour + int(fraction)
        fraction = fraction-int(fraction)
      endif
      ifraction = nint(fraction*60.0_8)            !turn hour fraction into minutes

      write(string1,2) iyear, imonth, iday, ihour, ifraction
2     format(i4,'.',i2.2,'.',i2.2,'.',2i2.2,'UTC')
       
      write(6,*) string1

      end program yyyymmddhh_since_1900

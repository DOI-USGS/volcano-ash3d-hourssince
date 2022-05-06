      program testHours

      implicit none

      integer            :: i

      integer            :: iyear,imonth
      integer            :: iday, idoy
      real(kind=8)       :: hours
      integer            :: byear    = 1000
      logical            :: useLeaps = .true.

      real(kind=8)       :: HS_hours_since_baseyear
      real(kind=8)       :: HoursSince
      real(kind=8)       :: hours2

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

      ! Check against calculator on
      ! http://www.7is7.com/otto/datediff.html
      ! Use the Proleptic Gregorian calendar
      ! https://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar

      !DO i = 1,876576  ! # of hours in a normal century
      DO i = 1,1884648  ! # of hours from 1800 to 2015
      !DO i = 1,8897303  ! # of hours from 1000 to 2015
        HoursSince = real(i,kind=8)
        call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)
        hours2 = HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)
        write(*,*)"     ",HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy,hours2
        IF(abs(HoursSince-hours2).gt.0.01)THEN
          write(*,*)"ERROR",HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy,hours2
        ENDIF
      ENDDO


      end program testHours

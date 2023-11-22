      program testHours

      implicit none

      integer,parameter      :: NRAND      = 10000    ! Number of pseudo-random tests
      real(kind=8),parameter :: HOURTHRESH = 0.01_8   ! Tolerance in hours for inverse functions

      integer            :: i

      integer            :: iyear,imonth
      integer            :: iday, idoy
      real(kind=8)       :: hours
      integer            :: byear    = 1000
      logical            :: useLeaps = .true.

      integer                          :: n
      integer,allocatable,dimension(:) :: seed
      real(kind=8)                     :: s_rand
      real(kind=8)       :: HoursSince
      real(kind=8)       :: hours2
      logical            :: Check_failed

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
        real(kind=8) function HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)
          integer     ,intent(in)       :: iyear
          integer     ,intent(in)       :: imonth
          integer     ,intent(in)       :: iday
          real(kind=8),intent(in)       :: hours
          integer     ,intent(in)       :: byear
          logical     ,intent(in)       :: useLeaps
        end function HS_hours_since_baseyear
      END INTERFACE

      ! You can always check against calculator on:
      !   http://www.7is7.com/otto/datediff.html
      ! Use the Proleptic Gregorian calendar
      ! https://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar

      write(*,*)"Verifying that HS_Get_YMDH and HS_hours_since_baseyear are inverses"
      write(*,*)"for 10000 random times between 1000 and 2015"

      Check_failed = .false.
      call random_seed(size=n)
      allocate(seed(n))
      seed(:) = 123456789
      call random_seed(put=seed)
      deallocate(seed)

      do i = 1,NRAND
        call random_number(s_rand)
        ! scale s_rand to the range byear-> 2015
        HoursSince = s_rand*8760.0_8*real((2015-byear),kind=8)
        call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)
        hours2 = HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)
        if(abs(HoursSince-hours2).gt.HOURTHRESH)then
          Check_failed = .true.
          write(*,*)"ERROR",HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy,hours2
        endif
      enddo

      if(Check_failed)then
        write(*,*)"volcano-ash3d-hourssince internal check: FAIL"
        stop 1
      else
        write(*,*)"volcano-ash3d-hourssince internal check: PASS"
        stop 0
      endif

      end program testHours

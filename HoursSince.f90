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
!      This file contains several functions and a subroutine that calculate the 
!      difference in hours of calendar dates compared to a reference (or base)
!      year.  The consideration of leap years can be set using the logical parameter
!      useLeaps.  If leap years are used, the proleptic Gregorian calendar is used.
!      Given an 'HoursSince' value, several functions are given to calculate the
!      corresponding calendar information as well as a few functions to format text
!      strings.
!
!      contains:
!        function HS_IsLeapYear(iyear)
!        function HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)
!        subroutine HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)
!        function HS_xmltime(HoursSince,byear,useLeaps)
!        function HS_yyyymmddhhmm_since(HoursSince,byear,useLeaps)
!        function HS_yyyymmddhh_since(HoursSince,byear,useLeaps)
!        function HS_DayOfYear(HoursSince,byear,useLeaps)
!        function HS_HourOfDay(HoursSince,byear,useLeaps)
!        function HS_YearOfEvent(HoursSince,byear,useLeaps)
!        function HS_MonthOfEvent(HoursSince,byear,useLeaps)
!        function HS_DayOfEvent(HoursSince,byear,useLeaps)
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


!##############################################################################
!
!     HS_IsLeapYear
!
!     This function takes and integer year as input and returns a logical
!      value (.true. or .false.) if that year is a leap year
!
!##############################################################################

      function HS_IsLeapYear(iyear)

      implicit none

      integer            :: iyear
      logical            :: HS_IsLeapYear

      ! Note, this uses the proleptic Gregorian calendar which includes year 0
      ! and considers y=0 to be a leap year.

      if ((mod(iyear,4).eq.0).and.(mod(iyear,100).ne.0).or.(mod(iyear,400).eq.0)) then
        HS_IsLeapYear = .true.
      else
        HS_IsLeapYear = .false.
      endif

      return

      end function HS_IsLeapYear

!##############################################################################
!
!     HS_hours_since_baseyear
!
!     function that calculates the number of hours since Jan 1, of a base year,
!     given the input (year, month, day, and hour (UT))
!
!##############################################################################

      function HS_hours_since_baseyear(iyear,imonth,iday,hours,byear,useLeaps)

      implicit none

      integer            :: iyear
      integer            :: imonth
      integer            :: iday
      real(kind=8)       :: hours
      integer            :: byear
      logical            :: useLeaps

      real(kind=8)       :: HS_hours_since_baseyear

                                   !cumulative hours in each month
      integer            :: i,ileaphours
      integer, dimension(0:12)  :: monthours     = (/0,744,1416,2160,2880,3624,4344,5088,5832,6552,7296,8016,8760/)
      logical :: IsLeap
      logical :: HS_IsLeapYear

      ! First check input values
      if (iyear.lt.byear) then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  year must be greater or equal to base year."
        write(0,*)"      Base Year = ",byear
        write(0,*)"     Input Year = ",iyear
        stop 1
      endif
      if (imonth.lt.1.or.imonth.gt.12) then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  month must be between 1 and 12."
        write(0,*)"     Input Month = ",imonth
        stop 1
      endif
      if (iday.lt.1) then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  day must be greater than 0."
        write(0,*)"     Input Day = ",iday
        stop 1
      endif
      if ((imonth.eq.1.or.&
           imonth.eq.3.or.&
           imonth.eq.5.or.&
           imonth.eq.7.or.&
           imonth.eq.8.or.&
           imonth.eq.10.or.&
           imonth.eq.12).and.iday.gt.31)then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  day must be <= 31 for this month."
        write(0,*)"     Input Month = ",imonth
        write(0,*)"     Input Day = ",iday
        stop 1
      endif
      if ((imonth.eq.4.or.&
           imonth.eq.6.or.&
           imonth.eq.9.or.&
           imonth.eq.11).and.iday.gt.30)then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  day must be <= 30 for this month."
        write(0,*)"     Input Month = ",imonth
        write(0,*)"     Input Day = ",iday 
        stop 1
      endif
      if ((imonth.eq.2).and.iday.gt.29)then
        write(0,*)"HS ERROR: HS_hours_since_baseyear"
        write(0,*)"HS ERROR:  day must be <= 29 for this month."
        write(0,*)"     Input Month = ",imonth
        write(0,*)"     Input Day = ",iday
        stop 1
      endif

      if(useLeaps)then
        ! First find out if given year is a leap year
        IsLeap = HS_IsLeapYear(iyear)

        ! Now find out how many leap days (actually hours) are between the given
        ! year and the base year
        ileaphours = 0
        do i = byear,iyear
          if (HS_IsLeapYear(i)) ileaphours = ileaphours + 24
        enddo
      
        ! If this is a leap year, but still in Jan or Feb, removed the
        ! extra 24 hours credited above
        if (IsLeap.and.imonth.lt.3) ileaphours = ileaphours - 24
      else
        ileaphours = 0
      endif

      HS_hours_since_baseyear = real((iyear-byear)*monthours(12) + & ! number of hours per normal year 
                                      monthours(imonth-1)        + & ! hours in year at beginning of month
                                      ileaphours                 + & ! total leap hours since base year
                                      24*(iday-1),kind=8)        + & ! hours in day
                                          hours                      ! hour of the day

      return

      end function HS_hours_since_baseyear

!##############################################################################
!
!     HS_Get_YMDH
!
!     subroutine that calculates the year, month, day and hour, given the
!     number of hours since Jan 1, of a base year.
!     This is essentially the inverse of HS_hours_since_baseyear
!
!##############################################################################

      subroutine HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      implicit none

      real(kind=8),intent(in)       :: HoursSince
      integer     ,intent(in)       :: byear
      logical     ,intent(in)       :: useLeaps
      integer     ,intent(out)      :: iyear
      integer     ,intent(out)      :: imonth
      integer     ,intent(out)      :: iday
      real(kind=8),intent(out)      :: hours
      integer     ,intent(out)      :: idoy

      integer, dimension(0:12)  :: monthours     = (/0,744,1416,2160,2880,3624,4344,5088,5832,6552,7296,8016,8760/)
      integer, dimension(0:12)  :: leapmonthours = (/0,744,1440,2184,2904,3648,4368,5112,5856,6576,7320,8040,8784/)

      integer :: HoursIn_Century
      integer :: HoursIn_This_Century
      integer :: HoursIn_Year
      integer :: HoursIn_This_Year
      integer :: HoursIn_Leap
      integer :: ileaphours
      integer :: byear_correction
      integer :: i
      integer :: icent
      integer :: BaseYear_Y0_OffsetHours_int
      real(kind=8) :: rem_hours
      real(kind=8) :: InYear_Y0_OffsettHours
      logical :: IsLeap
      logical :: HS_IsLeapYear
      real(kind=8) :: month_start_hours,month_end_hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      ! div-by-four ARE leapyears -> +1
      ! div-by-100  NOT leapyears -> -1
      ! div-by-400  ARE leapyears -> +1
      !  So, every 400 years, the cycle repeats with 97 extra leap days 
      !  Otherwise, normal centuries have 24 leap days
      !  And four-year packages have 1 leap day
      if(useLeaps)then
        HoursIn_Century  = 24*(365 * 100 + 24)
        HoursIn_Year     = 24*(365)
        HoursIn_Leap     = 24
      else
        HoursIn_Century  = 24*(365 * 100)
        HoursIn_Year     = 24*(365)
        HoursIn_Leap     = 0
      endif

      ! Get the number of hours between base year and year 0
      !  First leap hours
      ileaphours = 0
      byear_correction = 0
      if(useLeaps)then
        if(byear.ge.0)then
          ! clock starts at 0 so include 0 in the positive accounting
          do i = 0,byear
            if (HS_IsLeapYear(i)) ileaphours = ileaphours + 24
          enddo
          if (HS_IsLeapYear(byear))then
            ! If the base year is itself a leapyear, remove the extra 24 hours
            ! since we will always be using Jan 1 of the base year
            byear_correction = -24
          endif
        else
          ! for negative years, count from year -1 to byear
          do i = byear,-1
            if (HS_IsLeapYear(i)) ileaphours = ileaphours + 24
          enddo
          if (HS_IsLeapYear(byear))then
            ! If the base year is itself a leapyear, remove the extra 24 hours
            ! since we will always be using Jan 1 of the base year
            byear_correction = -24
          endif
        endif
      else
        byear_correction = 0
      endif
      ! Now total hours
      BaseYear_Y0_OffsetHours_int = abs(byear)*HoursIn_Year  + &
                                     ileaphours               + &
                                     byear_correction
      BaseYear_Y0_OffsetHours_int = sign(BaseYear_Y0_OffsetHours_int,byear)

      InYear_Y0_OffsettHours = real(BaseYear_Y0_OffsetHours_int,kind=8) + &
                                     HoursSince
      rem_hours = InYear_Y0_OffsettHours
      if(InYear_Y0_OffsettHours.ge.0.0)then
        ! byear and HoursSince result in an iyear .ge. 0
          icent = 0
          HoursIn_This_Century = HoursIn_Century + HoursIn_Leap
          HoursIn_This_Year = HoursIn_Year + HoursIn_Leap

          ! Find which century we are in
          do while (rem_hours.ge.HoursIn_This_Century)
              ! Account for this century
            icent = icent + 1
            rem_hours = rem_hours - HoursIn_This_Century
              ! Figure out the number of hours in the next century to check
            if (mod(icent,4).eq.0) then
              HoursIn_This_Century = HoursIn_Century + HoursIn_Leap
              HoursIn_This_Year = HoursIn_Year + HoursIn_Leap
            else
              HoursIn_This_Century = HoursIn_Century
              HoursIn_This_Year = HoursIn_Year
            endif
          enddo

          ! Find which year we are in
          iyear = 0
          do while (rem_hours.ge.HoursIn_This_Year) 
              ! Account for this year
            iyear = iyear + 1
            rem_hours = rem_hours - HoursIn_This_Year
              ! Figure out the number of hours in the next year to check
            if (mod(iyear,4).eq.0) then
              HoursIn_This_Year = HoursIn_Year + HoursIn_Leap
            else
              HoursIn_This_Year = HoursIn_Year
            endif
          enddo

          iyear = iyear + 100*icent
      else
        ! iyear will be negative
        stop 1
      endif
        ! Check if iyear is a leap year

      if(useLeaps)then
        if (HS_IsLeapYear(iyear))then
           IsLeap = .true.
        else
          IsLeap = .false.
        endif
      else
        IsLeap = .false.
      endif
        ! Calculate the day-of-year
      idoy = int(rem_hours/24.0_8)+1

        ! Get the month we are in
      do imonth=1,12
        if(IsLeap)then
          month_start_hours = real(leapmonthours(imonth-1),kind=8)
          month_end_hours   = real(leapmonthours(imonth),kind=8)
        else
          month_start_hours = real(monthours(imonth-1),kind=8)
          month_end_hours   = real(monthours(imonth),kind=8)
        endif
        if(rem_hours.ge.month_start_hours.and.rem_hours.lt.month_end_hours)then
          rem_hours = rem_hours - month_start_hours
          exit
        endif
      enddo
        ! And the day-of month
      iday = int(rem_hours/24.0_8)+1
        ! Hours of day
      hours = rem_hours - real((iday-1)*24,kind=8)

      return

      end subroutine HS_Get_YMDH

!##############################################################################
!
!     HS_xmltime
!
!     Returns the xml time stamp 'yyyy-mm-ddThh:mm:ssZ',
!     giving the year, month, day, hour, minutes, and seconds in 
!     Universal Time, given the number of hours since January 1, baseyear.
!
!##############################################################################

      function HS_xmltime(HoursSince,byear,useLeaps)
      
      implicit none
      character (len=20)        :: HS_xmltime, string1
      real(kind=8)              :: HoursSince
      integer                   :: byear
      logical                   :: useLeaps

      integer                   :: iyear, imonth, iday, idoy
      real(kind=8)              :: hours
      integer                   :: ihours, iminutes, iseconds

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      ihours = int(hours)
      iminutes = int(60.0_8*(hours-real(ihours,kind=8)))
      iseconds = int((60.0_8*(hours-real(ihours,kind=8)))-iminutes)*60

        ! build the string
      write(string1,1) iyear, imonth, iday, ihours, iminutes, iseconds
1     format(i4,'-',i2.2,'-',i2.2,'T',i2.2,':',i2.2,':',i2.2,'Z')
       
      HS_xmltime = string1
      
      return

      end function HS_xmltime

!##############################################################################
!
!     HS_yyyymmddhhmm_since
!
!     Returns a character string yyyymmddhh.hh giving the year, month, day, and
!     hour, given the number of hours since January 1, of baseyear.
!
!##############################################################################

      function HS_yyyymmddhhmm_since(HoursSince,byear,useLeaps)
      

      implicit none
      character (len=13)         ::  HS_yyyymmddhhmm_since, string1
      character (len=1)          ::  string0                        ! a filler character
      real(kind=8)               ::  HoursSince
      integer                    ::  byear
      logical                    ::  useLeaps

      integer                    ::  iyear, imonth, iday, idoy
      real(kind=8)               ::  hours

      integer                    ::  ihours, iminutes

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      string0 = ':'

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      ihours = int(hours)
      iminutes = int(60.0_8*(hours-real(ihours,kind=8)))
        ! build the string
      write(string1,'(i4,3i2.2,a,i2.2)') iyear, imonth, iday, ihours, string0, iminutes
       
      HS_yyyymmddhhmm_since = string1
      
      return
      end function HS_yyyymmddhhmm_since

!##############################################################################
!
!     HS_yyyymmddhh_since
!
!     Returns a character string yyyymmddhh.hh giving the year, month, day, and
!     hour, given the number of hours since January 1, of baseyear.
!
!##############################################################################

      function HS_yyyymmddhh_since(HoursSince,byear,useLeaps)
      
      implicit none

      character (len=13)         ::  HS_yyyymmddhh_since
      real(kind=8)               ::  HoursSince
      integer                    ::  byear
      logical                    ::  useLeaps

      integer                    ::  iyear, imonth, iday, idoy
      real(kind=8)               ::  hours

      character (len=13)         ::  string1
      character (len=1)          ::  string0              ! a filler character
      integer                    ::  ihours, ifraction

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      string0 = '.'

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      ihours = int(hours)
      ifraction = nint(100.0_8*(hours-real(ihours,kind=8)))
      if(ifraction.eq.100)then
        ! if the nearest integer of ifraction is acutually the next
        ! hour, adjust ifraction and ihour accordingly
        ifraction = 0
        ihours = ihours + 1
      endif
      
        ! build the string
      write(string1,'(i4,3i2.2,a,i2.2)') iyear, imonth, iday, ihours, string0, ifraction
       
      HS_yyyymmddhh_since = string1
      
      return

      end function HS_yyyymmddhh_since

!##############################################################################
!
!     HS_DayOfYear
!
!     function that calculates the integer day of year given the
!     HoursSince, base year and useLeaps
!       Check against calculator on
!       http://www.7is7.com/otto/datediff.html
!
!##############################################################################

      function HS_DayOfYear(HoursSince,byear,useLeaps)

      implicit none

      integer               :: HS_DayOfYear
      real(kind=8)          :: HoursSince
      integer               :: byear
      logical               :: useLeaps

      integer               ::  iyear, imonth, iday, idoy
      real(kind=8)          ::  hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9_8)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      HS_DayOfYear = idoy

      return

      end function HS_DayOfYear

!##############################################################################
!
!     HS_HourOfDay
!
!     function that calculates the real hour of day given the
!     HoursSince
!
!##############################################################################

      function HS_HourOfDay(HoursSince,byear,useLeaps)

      implicit none

      real(kind=8)          :: HS_HourOfDay
      real(kind=8)          :: HoursSince
      integer               :: byear
      logical               :: useLeaps

      integer               ::  iyear, imonth, iday, idoy
      real(kind=8)          ::  hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9_8)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      HS_HourOfDay = hours

      return

      end function HS_HourOfDay

!##############################################################################
!
!     HS_YearOfEvent
!
!     function that calculates the integer year given the
!     HoursSince
!
!##############################################################################

      function HS_YearOfEvent(HoursSince,byear,useLeaps)

      implicit none

      integer            :: HS_YearOfEvent
      real(kind=8)       :: HoursSince
      integer            :: byear
      logical            :: useLeaps

      integer               ::  iyear, imonth, iday, idoy
      real(kind=8)          ::  hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9_8)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      HS_YearOfEvent = iyear

      return

      end function HS_YearOfEvent

!##############################################################################
!
!     HS_MonthOfEvent
!
!     function that calculates the integer month of year given the
!     HoursSince
!
!##############################################################################

      function HS_MonthOfEvent(HoursSince,byear,useLeaps)

      implicit none

      integer          :: HS_MonthOfEvent
      real(kind=8)     :: HoursSince
      integer          :: byear
      logical          :: useLeaps

      integer               ::  iyear, imonth, iday, idoy
      real(kind=8)          ::  hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9_8)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      HS_MonthOfEvent = imonth

      return

      end function HS_MonthOfEvent

!##############################################################################
!
!     HS_DayOfEvent
!
!     function that calculates the integer day of month given the
!     HoursSince
!
!##############################################################################

      function HS_DayOfEvent(HoursSince,byear,useLeaps)

      implicit none

      integer         :: HS_DayOfEvent
      real(kind=8)    :: HoursSince
      integer         :: byear
      logical         :: useLeaps

      integer               ::  iyear, imonth, iday, idoy
      real(kind=8)          ::  hours

      ! Error checking the first argument
      ! Note: this must be real*8; if it was passed as real*4, then it will be
      !        nonesense
      if(HoursSince.lt.0.or.HoursSince.gt.1.0e9_8)then
        write(0,*)"HS ERROR: HoursSince variable is either negative or larger"
        write(0,*)"          than ~100,000 years."
        write(0,*)"          Double-check that it was passed as real*8"
        stop 1
      endif

      call HS_Get_YMDH(HoursSince,byear,useLeaps,iyear,imonth,iday,hours,idoy)

      HS_DayOfEvent = iday

      return

      end function HS_DayOfEvent



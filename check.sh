#!/bin/bash

# This bash script is run for the target 'make check'
# This script runs two tests; and internal check and a check against other programs:
# 1) testHours; program which verifies that HS_Get_YMDH and HS_hours_since_baseyear
#               are actual inverses of each other, within a tolerance of 0.01 hours
# 2) test time difference between 100 random date pairs using unix 'date' command

rc=0
echo "Looking for required programs: bc and date"
which bc > /dev/null
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
  echo "Error: Could not find bc in your path"
  echo "       bc is needed to verify accuracy of routines."
  exit 1
fi
which date > /dev/null
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
  echo "Error: Could not find date in your path"
  echo "       date is needed as an independent check on time calculations."
  exit 1
fi
# We now need to know if we are using GNU date or the BSD flavor
if date --version >/dev/null 2>&1 ; then
    echo "gnu date (linux)"
    GNUDATE=1
else
    echo "BSD date (Mac)"
    GNUDATE=0
fi
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

######################################################
#  Test 1
#    Run the tool testHours and test the return code.
######################################################
echo "Running internal check."
echo "   Verifying that HS_Get_YMDH and HS_hours_since_baseyear are inverses."
./testHours > /dev/null 2>&1
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
    printf " ---> ${RED}FAIL${NC}\n"
else
    printf " ---> ${GREEN}PASS${NC}\n"
fi

######################################################
#  Test 2
#    Compare tool HoursSince1900 with the unix 'date'
#    command.
######################################################
echo "Running comparison test with unix date command."
echo "  Generating 100 random date pairs for time-differencing."
rc=0
for (( r1=1 ; r1<=100 ; r1++ ));
do
  # Get two random dates between between 1970-1-1 and 2020-12-31
  x1=$RANDOM   # random number (0->32767) for year
  x2=$RANDOM   # for day of year
  y1=$(echo "1970+$((x1))/32767.0*50.0" | bc -l)
  YYYY1=${y1%.*}
  d1=$(echo "1+$((x2))/32767.0*364.0" | bc -l)   # This skips Dec 31 of all leap years
  DoY1=${d1%.*}
  h1=12.0
  if [ $GNUDATE -eq 1 ];then
    echo "gnu date (linux)"
    date1=`date --date="${YYYY1}/1/1 + ${DoY1} days" +%F`
    MM1=`date '+%m' -d "${date1} 12:00:00 UTC"`
    DD1=`date '+%d' -d "${date1} 12:00:00 UTC"`
    u1=$(date '+%s' -d "${date1} 12:00:00 UTC")   # unix time in seconds
  else
    echo "BSD date (Mac)"
    date1=`date -v${YYYY1}y -v1m -v1d -v0H -v0M -v0S -v+${DoY1}d -u +%F`
    MM1=`date -j -f "%Y-%m-%d %H:%M:%S" "${date1} 12:00:00"  +%m`
    DD1=`date -j -f "%Y-%m-%d %H:%M:%S" "${date1} 12:00:00"  +%d`
    u1=$(`date -j -f "%Y-%m-%d %H:%M:%S" "${date1} 12:00:00"  +%s`)   # unix time in seconds
  fi
  U1=$(echo "$((u1))/3600.0" | bc -l)       # unix time in hours
  
  x1=$RANDOM   # random number (0->32767) for year
  x2=$RANDOM   # for day of year
  y2=$(echo "1970+$((x2))/32767.0*50.0" | bc -l)
  YYYY2=${y2%.*}
  d2=$(echo "1+$((x2))/32767.0*364.0" | bc -l)   # This skips Dec 31 of all leap years
  DoY2=${d2%.*}
  h2=12.0
  if [ $GNUDATE -eq 1 ];then
    echo "gnu date (linux)"
    date2=`date --date="${YYYY2}/1/1 + ${DoY2} days" +%F`
    MM2=`date '+%m' -d "${date2} 12:00:00 UTC"`
    DD2=`date '+%d' -d "${date2} 12:00:00 UTC"`
    u2=$(date '+%s' -d "${date2} 12:00:00 UTC")   # unix time in seconds
  else
    echo "BSD date (Mac)"
    date2=`date -v${YYYY2}y -v1m -v1d -v0H -v0M -v0S -v+${DoY1}d -u +%F`
    MM2=`date -j -f "%Y-%m-%d %H:%M:%S" "${date2} 12:00:00"  +%m`
    DD2=`date -j -f "%Y-%m-%d %H:%M:%S" "${date2} 12:00:00"  +%d`
    u2=$(`date -j -f "%Y-%m-%d %H:%M:%S" "${date2} 12:00:00"  +%s`)   # unix time in seconds
  fi
  U2=$(echo "$((u2))/3600.0" | bc -l)       # unix time in hours
  # Now calculate the difference in hours to the two unix times
  udifH=$(echo "$((u2-u1))/3600.0" | bc -l )

  # Use the tool HoursSince1900 to calculate the difference in hours
  t1=`./HoursSince1900 $YYYY1 $MM1 $DD1 $h1`
  diff1=`echo "$U1 - $t1" | bc -l`
  t2=`./HoursSince1900 $YYYY2 $MM2 $DD2 $h2`
  diff2=`echo "$U2 - $t2" | bc -l`
  HSdifH=$(echo "$t2 - $t1" | bc -l)
  # Get the absolute value of the difference in hours between the two measures (should be 0)
  Hdiff=`echo "sqrt(($udifH - $HSdifH)^2)" | bc -l`
  # increment error code with this difference
  rc=$((rc + Hdiff))
done
if [[ "$rc" -ne 0 ]] ; then
    printf " ---> ${RED}FAIL${NC}\n"
else    
    printf " ---> ${GREEN}PASS${NC}\n"
fi


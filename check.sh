#!/bin/bash

# This bash script is run for the target 'make check'
# This script runs two tests; and internal check and a check against other programs:
# 1 testHours : program which verifies that HS_Get_YMDH and HS_hours_since_baseyear
#               are actual inverses of each other, within a tolerance of 0.01 hours
# 2 test time difference between 100 random date pairs usind unix 'date' command

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Running internal check."
echo "   Verifying that HS_Get_YMDH and HS_hours_since_baseyear are inverses."
./testHours > /dev/null 2>&1
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
    printf " ---> ${RED}FAIL${NC}\n"
else
    printf " ---> ${GREEN}PASS${NC}\n"
fi

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
  date1=`date --date="${YYYY1}/1/1 + ${DoY1} days" +%F`
  MM1=`date '+%m' -d "${date1} 12:00:00 UTC"`
  DD1=`date '+%d' -d "${date1} 12:00:00 UTC"`
  h1=12.0
  u1=$(date '+%s' -d "${date1} 12:00:00 UTC")   # unix time in seconds
  U1=$(echo "$((u1))/3600.0" | bc -l)       # unix time in hours
  
  x1=$RANDOM   # random number (0->32767) for year
  x2=$RANDOM   # for day of year
  y2=$(echo "1970+$((x2))/32767.0*50.0" | bc -l)
  YYYY2=${y2%.*}
  d2=$(echo "1+$((x2))/32767.0*364.0" | bc -l)   # This skips Dec 31 of all leap years
  DoY2=${d2%.*}
  date2=`date --date="${YYYY2}/1/1 + ${DoY2} days" +%F`
  MM2=`date '+%m' -d "${date2} 12:00:00 UTC"`
  DD2=`date '+%d' -d "${date2} 12:00:00 UTC"`
  h2=12.0
  u2=$(date '+%s' -d "${date2} 12:00:00 UTC")   # unix time in seconds
  U2=$(echo "$((u2))/3600.0" | bc -l)       # unix time in hours
  
  udifH=$(echo "$((u2-u1))/3600.0" | bc -l )
  
  t1=`./HoursSince1900 $YYYY1 $MM1 $DD1 $h1`
  diff1=`echo "$U1 - $t1" | bc -l`
  t2=`./HoursSince1900 $YYYY2 $MM2 $DD2 $h2`
  diff2=`echo "$U2 - $t2" | bc -l`
  HSdifH=$(echo "$t2 - $t1" | bc -l)
  Hdiff=`echo "$udifH - $HSdifH" | bc -l`
  rc=$((rc + Hdiff))
done
if [[ "$rc" -ne 0 ]] ; then
    printf " ---> ${RED}FAIL${NC}\n"
else    
    printf " ---> ${GREEN}PASS${NC}\n"
fi

#!/bin/bash

# This bash script is run for the target 'make check'
# This script runs two tests; and internal check and a check against other programs:
#  testHours : program which verifies that HS_Get_YMDH and HS_hours_since_baseyear
#              are actual inverses of each other, within a tolerance of 0.01 hours

# Get two random dates between between 1970-1-1 and 2020-12-31
x1=$RANDOM   # random number (0->32767) for year
x2=$RANDOM   # for day of year
y1=$(echo "1970+$((x1))/32767.0*50.0" | bc -l)
YYYY1=${y1%.*}
d1=$(echo "1+$((x2))/32767.0*364.0" | bc -l)   # This skips Dec 31 of all leap years
DoY1=${d1%.*}
date1=`date --date="${YYYY1}/1/1 + ${DoY1} days" +%F`
MM1=`date '+%m' -d "${date1} 00:00:00"`
DD1=`date '+%d' -d "${date1} 00:00:00"`
h1=0.0
u1=$(date '+%s' -d "${date1} 00:00:00")   # unix time in seconds
U1=$(echo "$((u1))/3600.0" | bc -l)       # unix time in hours

x1=$RANDOM   # random number (0->32767) for year
x2=$RANDOM   # for day of year
y2=$(echo "1970+$((x2))/32767.0*50.0" | bc -l)
YYYY2=${y2%.*}
d2=$(echo "1+$((x2))/32767.0*364.0" | bc -l)   # This skips Dec 31 of all leap years
DoY2=${d2%.*}
date2=`date --date="${YYYY2}/1/1 + ${DoY2} days" +%F`
MM2=`date '+%m' -d "${date2} 00:00:00"`
DD2=`date '+%d' -d "${date2} 00:00:00"`
h2=0.0
u2=$(date '+%s' -d "${date2} 00:00:00")   # unix time in seconds
U2=$(echo "$((u2))/3600.0" | bc -l)       # unix time in hours

udifH=$(echo "$((u2-u1))/3600.0" | bc -l )

t1=`./HoursSince1900 $YYYY1 $MM1 $DD1 $h1`
diff1=`echo "$U1 - $t1" | bc -l`
t2=`./HoursSince1900 $YYYY2 $MM2 $DD2 $h2`
diff2=`echo "$U2 - $t2" | bc -l`
HSdifH=$(echo "$t2 - $t1" | bc -l)

echo $YYYY1 $MM1 $DD1 $h1 $t1 $date1 $U1 $diff1
echo $YYYY2 $MM2 $DD2 $h2 $t2 $date2 $U2 $diff2
echo $udifH $HSdifH
echo "$udifH - $HSdifH" | bc -l

#  



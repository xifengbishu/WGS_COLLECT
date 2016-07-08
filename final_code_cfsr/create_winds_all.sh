#!/bin/sh

  . /etc/profile

  year_beg=2012
  year_end=2012
  year=$year_beg
  while [ $year -le $year_end ]
  do 
    rm -f functions/*exe
    ./create_winds.csh $year
    #pick_WND10m.sh recom_${year}_case 
    # --- next year
    year=`expr $year + 1`
  done
  exit
# ========== End of File ==============


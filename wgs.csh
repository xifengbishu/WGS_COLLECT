#!/bin/csh
# ---------------------------------------------------------------------- 
# --- Purpose:                                                       --- 
# ---   sftp WRF winds to shandong SERVICE                           ---
# ---   If WRF result was break , use GFS wind replace               ---
# ---------------------------------------------------------------------- 
# ---                                                                --- 
# --- National Marine Data and Information Service ( NMDIS )         --- 
# --- http://www.nmdis.gov.cn/                                       ---
# --- Wang Guosong                                                   ---  
# --- Please send any further problems, comments, or suggestions to  --- 
# --- <wgs_WRF@163.com>                                              ---
# --- Based on Dr. GAO Shanhong ( OUC ) source program               ---
# --- All rights reserved !                                          --- 
# ---                                                                --- 
# --- History:                                                       --- 
# --- (1) Thu Aug 29 10:43:46 CST 2013, NMDIS.                       --- 
# ---------------------------------------------------------------------- 

#  ==================== README for data of Wind ==========================
#  ===                                                                 ===
#  ===         Based on the tutor Gao's source program                 ===
#  ===         Wang Guosong, 20 Feb 2012.                              ===
#  ===                                                                 ===
#  =======================================================================

# ===
# === Step-1: Check  variables, echo history and usage
# ===
  if (${#} == 0) then
    echo 'Usage '
    echo ' run.csh year '
    echo ' For example '
    echo ' run.csh 2010'
  exit
  endif
           echo 'pget -n 20 '$URL > lftp
           #lftp -f lftp
  
  set sfc_root = "/data/data_tansfer/wind_energy"
  set year = $1
  
  if ( ! -e ${year}'_sfc' ) then  
  ln -s ${sfc_root}/${year}'_sfc' ./
  endif
  
  ls -h ${year}'_sfc'/* | awk '{print $NF}' | wc -l > ${year}_ok
  ls -h ${year}'_sfc'/* | awk '{print $NF}' >> ${year}_ok

  if ( ! -e sfc2bin.exe ) then 
    pgf90 sfc2bin.f90 -o sfc2bin.exe
  endif
    sfc2bin.exe ${year}_ok ${year}
 

# ------------------------------
  set num = 1
  while ( ${num} < 100 )

  set num = `expr $num + 1`
  end
# ------------------------------
  foreach file ( `ls *eps` )
   echo $file:r  
  end
# ------------------------------
#  --- judge if WRFDA is done or not
      sleep 10
      set wait_wrfda_num = 0
      while ( $wait_wrfda_num < 360 )
        grep "Powerful Machine later" my_case_result/my_final.msg > if_wrfda_ok
        if ( -s if_wrfda_ok )  then
           sleep 5
           rm -f if_wrfda_ok
           break
        else
           sleep 10
        endif
        set wait_wrfda_num = `expr $wait_wrfda_num + 1`
      end 
# ---------------------------

          sed 's/20070428.0200001/'${yr1}${mm1}${dy1}'.'${hr1}'0000/g'  \
               namelist.rdr_base | \
          sed 's/20070428.0500001/'${yr2}${mm2}${dy2}'.'${hr2}'0000/g'  \
               > namelist.rdr
  21: about usage of date
      date +"%C%y%m%d" --date "yesterday"
      date +"%C%y%m%d" --date "tomorrow"
      date +%C%y%m%d --date "yesterday"
      date +%m%d --date "3 day ago"
      date +%m%d --date "2 day"
      date +%m%d --date "next day"
      
      date +%b --date="+ 2 day"

      The date of next 2 days of 20051231
      date -d '20051231 2 days'

      The date of next 2 hours of 20051231_15
      date -d '20051231 15 2 hours'

      The date of next 200 minutes of 20051231 15:00:00
      date -d '20051231 15:00:00 200 minutes'


  set levels = ( "1000" "925" "850"  )

# ------------------------------
  set num = 1
  while ( ${num} <= 3 )
    set lev_sec = ${levels[${num}]}
    sed -e 's/wgs_level/'${lev_sec}'/' -e 's/wgs_H/1/' -e 's/wgs_T/0/' -e 's/wgs_Q/0/' \
    Ana_vs_WRF.ncl > Ana_vs_WRF_OK_${lev_sec}_H.ncl
    ncl Ana_vs_WRF_OK_${lev_sec}_H.ncl
    mv RMSE_CR RMSE_CR_${lev_sec}_H 
  set num = `expr $num + 1`
  end



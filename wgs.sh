#!/bin/sh
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


# ===
# === Step-1: Check  variables, echo history and usage
# ===
# ========= while [ ] do done
      # --- judge if WRFDA is done or not
      sleep 10
      wait_wrfda_num=0
      while [ $wait_wrfda_num -lt 360 ]
      do
        grep -i 'WRF-Var completed successfully' rsl.out.0000 > if_wrfda_ok
        if test -s if_wrfda_ok ; then
           sleep 5
           rm -f if_wrfda_ok
           break
        else
           sleep 10
        fi
        wait_wrfda_num=`expr $wait_wrfda_num + 1`
      done
# ============== if [] ; then  fi ============
      if [ -e da_wrfvar.info ] ; then
        rm -f da_wrfvar.info
      fi
# ====== for ** in ,do done
    for file in *.sfc
    do
      ./plot_wrf_winds.exe $file
    done
# ====== EOF
cat > namelist.input << EOF
&zonerange
  long1 = ${lon_beg},
  long2 = ${lon_end},
  lat1 = ${lat_beg},
  lat2 = ${lat_end},
/
EOF
# ============= lftp 1 : download ===================      
        URL_file=`echo $URL_fcst | sed 's/fcst_hr/'${hr}'/g' `          
        URL=${URL_add}/${URL_root}/${URL_file}${URL_opt}
        #echo ${URL}
        # ---
        if [ ! -e ${URL_file} ] ; then
           echo 'pget -n 40 '$URL > lftp
           lftp -f lftp
        fi
# ============= lftp 2 : translate  ===================      
   lftp -u flow,flow sftp://115.236.180.212 << EOF
   mput /public/wind_flow/flow/cost_time ./shenzhen
   quit
   EOF

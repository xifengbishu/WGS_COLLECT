#!/bin/sh
#
# --- Download GFS Forecast Data using filter_gfs_hd.pl,
# --- which can do choosing of both variables and sub-domain.
# ---
# ---------------------------------------------------------------
# --- History:
# ---   1) Dr. GAO Shanhong, 14 Apr 2012, Yushan campus.
# ---      originally created based on the previous shell script.
# --- 
# ---   2) Dr. GAO Shanhong, 19 Apr 2012, Yushan campus.
# ---      add an input "hour_beg", and an option "limit_num" to 
# ---      control curl-downloading. 
# ---
# ---   3) Dr. GAO Shanhong, 11 Dec 2012, Yushan campus.
# ---      add a ${gfs_ini} label to temp and .Curl_gfs
# ---      "get_gfs.sh" can be parallelly run now.
# ---      
# ---------------------------------------------------------------

  # --- 0. basic information
  . /etc/profile
  . /public/wind_flow/flow/.bashrc
  unalias -a
  current_root=/public/wind_flow/flow/WGS/auto_upload/wgs_wind_shenzhen/GFS
  cd $current_root
  do_check=0
  #
  # --- check and echo usage
  if [ $# -lt 4 ] ; then
    echo ''
    echo '  ===================================================================='
    #echo '  Beforehand, please modify forecast_root and work_dir in this script!'
    #echo '  --------------------------------------------------------------------'
    #echo ''
    echo '  Usage: '
    echo '      get_gfs.sh  0/-1  00/06/12/18  hour_beg hour_end  intv'
    echo ''
    echo '      Notice:  0/-1 -->  0, today; -1, yesterday'
    echo '    '
    echo '      For examples:'
    echo '      assume current time is 2012-04-13'
    echo '      1) get_gfs.sh   0  00  0  6  3 '
    echo '         --- get 2012041300 including gfs.t00z.pgrb2f00, 03, 06'
    echo '    '
    echo '      2) get_gfs.sh  -1  12  0 72  3 '
    echo '         --- get 2012041212 including gfs.t12z.pgrb2f00, 03, ..., 72'
    echo '    '
    echo '  --- Good luck!  '
    echo '  ===================================================================='
    echo ''
    exit
  else
    date_in=$1
    gfs_ini=$2
    fcst_beg=$3
    fcst_end=$4
    fcst_int=$5
  fi

  echo ' ===========   Download GFS files   =========='  > cost_time_${gfs_ini}
  echo '' >> cost_time_${gfs_ini}
  date +' Starting Time: '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
  time1=`date +%s`

# --- 1. Do settings
#
# --- 1.0 Which curl and wgrib2
      #
      # --- For example,
      # --- limit_num=1,  GFS file is downloaded one by one
      # --- limit_num=10, 1st to 10th GFS files are downloaded together, but
      # ---               the left GFS files will be downloaded one by one.
      # ---
      limit_num=20
#
# --- 1.1 sub-domain
      lon_beg=80
      lon_end=180
      lat_beg=0
      lat_end=60
#
# --- 1.2 date-time 
#
      #aim=test
      aim=forecast
      #
      if [ $aim == 'test' ] ; then
         fcst_type=t12z
         fcst_dir=2012041312
         fcst_hr_beg=00
         fcst_hr_end=72
         fcst_hr_inv=3
         fcst_dir=${fcst_dir}
      fi
      #
      # --- morning and afternoon
      if [ $aim == 'forecast' ] ; then
         date_given=`date +"%Y%m%d" --date "$date_in days"`    
         year=`echo $date_given | cut -c1-4`
         yy=`echo $date_given | cut -c3-4`
         month_ok=`echo $date_given | cut -c5-6`
         day_ok=`echo $date_given | cut -c7-8`
         fcst_type=t${gfs_ini}z
         fcst_dir=${date_given}${gfs_ini}
         fcst_hr_beg=${fcst_beg}
         fcst_hr_end=${fcst_end}
         fcst_hr_inv=${fcst_int}
      fi
#
# --- 1.3 basic URL
      #  http://www.ftp.ncep.noaa.gov/data/nccf/com/cfs/prod/cdas.20140513/cdas1.t00z.pgrbanl.grib2
      URL_add="http://www.ftp.ncep.noaa.gov/data/nccf/com/cfs/prod"
      URL_root="cdas.${year}${month_ok}${day_ok}"
      URL_fcst="cdas1.${fcst_type}.pgrbhfcst_hr.grib2"
      URL_anl="cdas1.${fcst_type}.pgrbhanl.grib2"
      URL_opt="" 

# --- 2. Start to download GFS using curl command.
  cd $current_root
      if [ -d ./temp_${gfs_ini} ] ; then
         rm -rf ./temp_${gfs_ini}
      fi
      mkdir ./temp_${gfs_ini}
      #
      hr=${fcst_hr_beg}
      file_num=1
      while [ $hr -le ${fcst_hr_end} ] 
      do
        hr=`expr $hr + 0`
        if [ $hr -lt 10 ] ; then
           hr=0$hr 
        fi
        #
        URL_file=`echo $URL_fcst | sed 's/fcst_hr/'${hr}'/g' `          
        if [ $hr -eq 0 ] ; then
          URL=${URL_add}/${URL_root}/${URL_anl}${URL_opt}
        else
          URL=${URL_add}/${URL_root}/${URL_file}${URL_opt}
        fi
        echo ${URL}
        # ---
        if [ ! -e ${URL_file} ] ; then
           echo 'pget -n 40 '$URL > lftp
           lftp -f lftp
        fi
        mv cdas1.${fcst_type}.pgrb*.grib2 ./temp_${gfs_ini}
        # --------------------------------
        #
        # --- next time
        hr=`expr $hr + ${fcst_hr_inv}`
        file_num=`expr ${file_num} + 1`
      done
      #sleep 10s
      cd $current_root
if [ do_checck = 1 ] ; then
# --- 3. Do check
      echo '' >> cost_time_${gfs_ini}
      date +' Check    now : '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
      wait_num=360
      sleep_sec=5
      user=`whoami`
      loop_num=1
      #
      date +' Exit waiting : '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
      #check_times=5
      check_times=2
      check_num=1
      total_num=`expr \( $fcst_hr_end - $fcst_hr_beg \) \/ $fcst_hr_inv + 1`
      while [ ${check_num} -lt ${check_times} ]
      do
        echo ' Checking Loop: '$check_num >> cost_time_${gfs_ini}
        file_num=1
        OK_num=0
        hr=${fcst_hr_beg}
        while [ $hr -le ${fcst_hr_end} ]
        do
          hr=`expr $hr + 0`
          if [ $hr -lt 10 ] ; then
             hr=0$hr
          fi
          file_num=`expr $file_num + 0`
          if [ $file_num -lt 10 ] ; then
             file_num=0$file_num
          fi
          #
          cd $current_root
          line_end=`wgrib2 ./temp_${gfs_ini}/${yy}${month_ok}${day_ok}${gfs_ini}.gfs.${fcst_type}.pgrb2f${hr} | wc -l`
          #line_end=`/public/wind_flow/flow/WGS/soft/grib2/wgrib2/wgrib2 ./temp_${gfs_ini}/${yy}${month_ok}${day_ok}${gfs_ini}.gfs.${fcst_type}.pgrb2f${hr} | wc -l`
          ok_num=315
          if [ ${line_end} -ge ${ok_num} ] ; then
             echo '   '${file_num}'  GFS File OK  == 'gfs.${fcst_type}.pgrb2f${hr} >> cost_time_${gfs_ini}
             OK_num=`expr $OK_num + 1` 
          else
             echo '   '${file_num}'  GFS File Bad == 'gfs.${fcst_type}.pgrb2f${hr} >> cost_time_${gfs_ini}
             # --- redownload
             date +'  Being re-downloaded at '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
             URL_file=`echo $URL_fcst | sed 's/fcst_hr/'${hr}'/g' `
             URL=${URL_add}/${URL_root}/${URL_file}${URL_opt}
             echo 'pget -n 40 '$URL > lftp
             lftp -f lftp
             mv ${yy}${month_ok}${day_ok}${gfs_ini}.gfs.${fcst_type}.pgrb2f${hr} ./temp_${gfs_ini}
          fi
          # --- next GFS time
          hr=`expr $hr + ${fcst_hr_inv}`
          file_num=`expr $file_num + 1`
        done
        # --- next check
        if [ $OK_num -eq $total_num ] ; then
           break
        else
          check_num=`expr $check_num + 1`
          #sleep 10s
        fi
      done
fi

# --- 4. Finish OK
      # --- give y_order message for ingesting SST
      echo '' >> cost_time_${gfs_ini}
      date +' OK  now      : '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
      echo '' >> cost_time_${gfs_ini}
      time2=`date +%s`
      time_cost=`expr $time2 - $time1`
      echo ' Cost time    : '${time_cost}' seconds'  >> cost_time_${gfs_ini}
      echo ' ' >> cost_time_${gfs_ini}
      echo ' ========= Finish Getting GFS files ==========' >> cost_time_${gfs_ini}
      echo ' ' >> cost_time_${gfs_ini}
      #
      cat cost_time_${gfs_ini} >> cost_time_${fcst_dir}
      if [ ! -d ${fcst_dir} ] ; then
         mkdir ${fcst_dir}
      fi
      mv -f  temp_${gfs_ini}/* ${fcst_dir}
      rm -rf temp_${gfs_ini} cost_time_${gfs_ini}  
      rm -f lftp
      mv cost_time_*  MSG
# ============================= End of File ========================================

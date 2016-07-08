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
  #
  # --- check and echo usage
  if [ $# -lt 5 ] ; then
    echo ''
    echo '  ===================================================================='
    #echo '  Beforehand, please modify forecast_root and work_dir in this script!'
    #echo '  --------------------------------------------------------------------'
    #echo ''
    echo '  Usage: '
    echo '      get_gfs.sh  0/-1  00/06/12/18  hour_beg hour_end  intv  gfs_type'
    echo ''
    echo '      Notice:  0/-1 -->  0, today; -1, yesterday'
    echo '    '
    echo '      For examples:'
    echo '      assume current time is 2012-04-13'
    echo '      1) get_gfs.sh   0  00  0  6  3  1'
    echo '         --- get 2012041300 including gfs.t00z.pgrb2f00, 03, 06  1deg_GFS'
    echo '    '
    echo '      2) get_gfs.sh  -1  12  0 72  3 0'
    echo '         --- get 2012041212 including gfs.t12z.pgrb2f00, 03, ..., 72 0.5deg_GFS'
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
    gfs_type=$6
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
      # --- 1 degree gfs (gfs.t12z.pgrbf00.grib2) === 1
      # --- 0.5 degree gfs ( gfs.t12z.pgrb2bf00 ) === 0
      if [ $gfs_type == 1 ] ; then
         URL_opt="pgrbffcst_hr.grib2"
      else
         URL_opt="pgrb2ffcst_hr"
      fi
#
# --- 1.3 basic URL
     gfs_new="http://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/gfs.2013072512/gfs.t12z.pgrb2bf00"
     gfs_less="http://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/gfs.2013072512/gfs.t12z.pgrbf00.grib2"
      URL_add="http://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod"
      URL_root=""
      #URL_fcst="gfs.${year}${month_ok}${day_ok}${gfs_ini}/gfs.${fcst_type}.pgrb2ffcst_hr"
      URL_fcst="gfs.${year}${month_ok}${day_ok}${gfs_ini}/gfs.${fcst_type}."
      #URL_fcst="grib.${fcst_type}/${yy}${month_ok}${day_ok}${gfs_ini}.gfs.${fcst_type}.pgrb2ffcst_hr"
      #      http://soostrc.comet.ucar.edu/data/grib/gfs/20120510/grib.t00z/12051000.gfs.t00z.pgrb2f00
      #URL_opt="" 

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
        URL_file=`echo ${URL_fcst}${URL_opt} | sed 's/fcst_hr/'${hr}'/g' `          
        URL=${URL_add}/${URL_root}${URL_file}
        # ---
        if [ ! -e ${URL_file} ] ; then
           echo 'pget -n 40 '$URL > lftp
           lftp -f lftp
        fi
        mv gfs.${fcst_type}.pgrb* ./temp_${gfs_ini}
        echo gfs.${fcst_type}.${URL_file}
        # --------------------------------
        #
        # --- next time
        hr=`expr $hr + ${fcst_hr_inv}`
        file_num=`expr ${file_num} + 1`
      done
      #sleep 10s
      cd $current_root
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
          if [ $gfs_type == 1 ] ; then
            gfs_file=gfs.${fcst_type}.pgrbf${hr}.grib2
          else
            gfs_file=gfs.${fcst_type}.pgrb2f${hr}
          fi
          line_end=`wgrib2 ./temp_${gfs_ini}/${gfs_file} | wc -l`
          echo $gfs_file
          echo "line_end " $line_end
          ok_num=315
          if [ ${line_end} -ge ${ok_num} ] ; then
             echo '   '${file_num}'  GFS File OK  == 'gfs.${fcst_type}.pgrb2f${hr} >> cost_time_${gfs_ini}
             OK_num=`expr $OK_num + 1` 
          else
             echo '   '${file_num}'  GFS File Bad == 'gfs.${fcst_type}.pgrb2f${hr} >> cost_time_${gfs_ini}
             # --- redownload
             date +'  Being re-downloaded at '%Y-%m-%d_%H:%M:%S >> cost_time_${gfs_ini}
             URL_file=`echo ${URL_fcst}${URL_opt} | sed 's/fcst_hr/'${hr}'/g' `          
             URL=${URL_add}/${URL_root}${URL_file}
             echo 'pget -n 40 '$URL > lftp
             lftp -f lftp
             mv ${gfs_file} ./temp_${gfs_ini}
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

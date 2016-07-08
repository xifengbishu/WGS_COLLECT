#!/bin/sh
# ---
# ---  Purpose:
# ---    Extract a small domain from a GRIB2 file
# ---    Interpolate onto latlon grids
# ---
# ---    wgrib2 with V1.9 above is needed!
# ---    
# ------------------------------------------------
# ---  History:
# ---    Dr. GAO Shanhong, 16 Feb 2011.
# ---
# ------------------------------------------------

  # --- set domian and resolution
  lon_beg=23
  lon_end=63
  lat_beg=-40
  lat_end=-5
  res=0.1
  wnd10m_root="/data/share/WGS/wgs_CFSR_forcast_wnd10m"

  # ======= End of YOur Mofifications =============

  if [ $# -eq 0  ] ; then
     echo ' '
     echo ' Usage:'
     echo '   pick_WND10m.sh casetime-file  '
     echo '   pick_WND10m.sh recom_2009_case'
     exit
  fi

  LAT1=` echo $lat_beg | awk '{ print $1 * 1000 }' `
  LAT2=` echo $lat_end | awk '{ print $1 * 1000 }' `
  LON1=` echo $lon_beg | awk '{ print $1 * 1000 }' `
  LON2=` echo $lon_end | awk '{ print $1 * 1000 }' `
  DLAT=` echo $res | awk '{ print $1 * 1000 }' `
  DLON=` echo $res | awk '{ print $1 * 1000 }' `
  DIS_LAT=` expr $LAT2 - $LAT1 `
  DIS_LON=` expr $LON2 - $LON1 `
  NX=` expr $DIS_LON \/ $DLON + 1`
  NY=` expr $DIS_LAT \/ $DLAT + 1`

  # --- get variable
  hour_time=( "00" "00" "06" "12" "18" )
  case_file=$1
  line=1
  line_num=`wc -l ${1} |  awk '{ print $1 }'`
  while [ $line -le $line_num ]
  do
  echo 'case'$line
  case_date=`sed -n ${line}p ${1} |  awk '{ print $1 }'`
  #echo ${case_date}

  fyear1=`echo $case_date | cut -c1-4`
  fmonth1=`echo $case_date | cut -c5-6`
  fday1=`echo $case_date | cut -c7-8`
      # --- creat the file name
      fyear=`date +%Y -d "$fyear1$fmonth1$fday1 2 days"`
      fmonth=`date +%m -d "$fyear1$fmonth1$fday1 2 days"`
      fday=`date +%d -d "$fyear1$fmonth1$fday1 2 days"`
      #
      fyear0=`date +%Y -d "$fyear1$fmonth1$fday1 1 days ago"`
      if [ ${fyear0} -ne ${fyear1} ] ; then
        fyear=`date +%Y -d "$fyear1$fmonth1$fday1 3 days"`
        fmonth=`date +%m -d "$fyear1$fmonth1$fday1 3 days"`
        fday=`date +%d -d "$fyear1$fmonth1$fday1 3 days"`
      fi
      #
      fdate=${fyear}${fmonth}${fday}
  
  # --------------------------
  time=1
  time_num=1
  while [ $time -le $time_num ]
  do
  ftime=`echo ${hour_time[${time}]}`
  ftime_ok=`expr ${ftime} + 3`
  if [ ${ftime_ok} -lt 10 ] ; then
    ftime_ok='0'${ftime_ok}
  fi
  input_file=${fdate}${ftime}
  input_fcst=${fdate}${ftime_ok}
  output_file=${fdate}_${ftime}
  output_fcst=${fdate}_${ftime_ok}
  echo $input_file $NX $NY 

  fyear=`echo $fdate | cut -c1-4`
  # --- splanl date
  if [ ${fyear} -ge 2011 -a ${fmonth} -ge 4 ] ; then
    middle=cdas
    wgirb2_middle=cdas1
  else
    middle=gdas
    wgirb2_middle=gdas
  fi
  if [ ${fyear} -ge 2012 ] ; then
    middle=cdas
    wgirb2_middle=cdas1
  fi

  if [ $fyear -ge 2011 ] ; then
    cfsr_root="/data/share/WGS/cfsv2_splanl"
  else
    cfsr_root="/data/data_tansfer/cfsr"
  fi
    splanl_path=${cfsr_root}/${fyear}/${fyear}${fmonth}
    splanl_file=${splanl_path}/splanl.${middle}.${fdate}${ftime}.grb2
  grib2_path=${wnd10m_root}/${fyear}
  wgrib2_file=${grib2_path}/wnd10m.${wgirb2_middle}.${fyear}${fmonth}.grb2
  echo ln -s $wgrib2_file . >> msg
  
  # --- extract winds only (UGRD and VGRD)
  if [ $fyear -ge 2010 ] ; then
    if [ ! -e $splanl_file ] ; then
      echo "No this file "$splanl_file  >> ${fyear}.msg
      exit
    else
        if [ ! -e splanl.${middle}.${fdate}${ftime}.grb2 ] ; then
          ln -s $splanl_file . >> ${fyear}.msg
        fi
    fi
    wgrib2 $splanl_file | grep GRD | wgrib2 -i $splanl_file -grib_out temp_file.grib2 > msg
  else
    wgrib2 $wgrib2_file | grep d=$input_file |  grep "anl" | wgrib2 -i $wgrib2_file -grib_out temp_file.grib2 >> msg
  fi

  # --- do interpolation
  wgrib2 temp_file.grib2 -new_grid_winds earth -new_grid_interpolation bilinear \
          -new_grid latlon ${lon_beg}:${NX}:${res} ${lat_beg}:${NY}:${res} \
           ${output_file}.grib2 >> msg
  # --- convert GRIB2 into ASCII format
  wgrib2 ${output_file}.grib2 -text sfc_wind >> msg
  # --- call convert_winds.f90
  if test -e dimension.dat ; then
     rm -f dimension.dat
  fi
  if test ! -e functions/convert_winds.exe ; then
     pgf90 functions/convert_winds.f90 -o functions/convert_winds.exe
  fi
  echo $NX $NY $lon_beg $lon_end $lat_beg $lat_end $res > dimension.dat
  functions/convert_winds.exe
  mv sfc_wind_ok ${output_file}.sfc
  rm -f sfc_wind

  # --- do delete
  rm -f msg  dimension.dat sfc_wind ${output_file}.grib2 
  
  # ---
  YY=`echo $fdate | cut -c1-4`
  MM=`echo $fdate | cut -c5-6`
  DD=`echo $fdate | cut -c7-8`
  HH=`echo $ftime`
  sed 's/YYYY-MM-DD:HH/'$YY-$MM-${DD}\_$HH'/g' ${output_file}.sfc > tmp_file
  mv -f tmp_file ${output_file}.sfc

 # ==================== End of File ========================

  # ---
    # --- next case
    time=`expr ${time} + 1`
  done
    rm -f temp_file.grib2 temp_fcst.grib2 msg
    rm -f *.grb2
    if test ! -s ${YY}.msg ; then
      rm -f ${YY}.msg
    fi
    if test ! -d ${fyear1}_cases ; then
      mkdir ${fyear1}_cases
    fi
    cd ${fyear1}_cases
    line_ok=`echo $line`
    if [ ${line_ok} -lt 10 ] ; then
     line_ok='0'${line_ok}
    fi
    if test ! -d case${line_ok} ; then
      mkdir case${line_ok}
    fi
    cd case${line_ok}
    mv ../../*.sfc ./
    cd ../..
    line=`expr ${line} + 1`
  done
 # ==================== End of File ========================

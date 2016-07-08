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
  lon_beg=117
  lon_end=130
  lat_beg=25
  lat_end=41
  res=0.1

  max_spd=0      
  int_hour=3
  out_all=1
  if_plot=0   # --- need out_all=1
  # ======= End of YOur Mofifications =============

  if [ $# -eq 0  ] ; then
     echo ' '
     echo ' Usage:'
     echo '   get_cfs_uv.sh wgrib2_file '
     echo ' '
     exit
  fi
  # --- get variables
  wgrib2_file=$1
  # ====== different setting after 2010 ==========
  output_file=`wgrib2 $wgrib2_file | sed -n 1p | sed 's/:/ /g' |  sed 's/=/ /g' | awk '{print $4}'`
  fyear=`echo $output_file | cut -c1-4`
  if [ $fyear -ge 2010 ] ; then
    line_int1=12
    line_int2=11
  else
    line_int1=14
    line_int2=13
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
  
  nline=`wgrib2 $wgrib2_file | awk '{print $NF}' | wc -l `
  day_num=`expr $nline \/ ${line_int1}`
  day_num=1
  day=1
  while [ $day -le $day_num ]
  do
    line=`expr $day \* ${line_int1} - ${line_int2}`

  output_file=`wgrib2 $wgrib2_file | sed -n ${line}p | sed 's/:/ /g' |  sed 's/=/ /g' | awk '{print $4}'`
  fyear=`echo $output_file | cut -c1-4`
  fmonth=`echo $output_file | cut -c5-6`
  fdate=`echo $output_file | cut -c1-8`
  ftime=`echo $output_file | cut -c9-10`
  input_file=${fdate}${ftime}
  output_file=${fdate}_${ftime}
  
  echo "=================="
  echo $output_file $NX $NY 

  # --- extract winds only (UGRD and VGRD)
  if [ $fyear -ge 2010 ] ; then
    # --- splanl date
    if [ ${fyear} -ge 2011 -a ${fmonth} -ge 4 ] ; then
      middle=cdas
    else
      middle=gdas
    fi
    if [ ${fyear} -ge 2012 ] ; then
      middle=cdas
    fi

    if [ $fyear -ge 2011 ] ; then
      cfsr_root="/data/share/WGS/cfsv2_splanl"
    else
      cfsr_root="/data/data_tansfer/cfsr"
    fi
      splanl_path=${cfsr_root}/${fyear}/${fyear}${fmonth}
      splanl_file=${splanl_path}/splanl.${middle}.${fdate}${ftime}.grb2
    if [ ! -e $splanl_file ] ; then
      echo "No this file "$splanl_file  >> ${fyear}.msg
      exit
    else
        if [ ! -e splanl.${middle}.${fdate}${ftime}.grb2 ] ; then
          ln -s $splanl_file . >> ${fyear}.msg
        fi
    fi
    # ------
    wgrib2 $splanl_file | grep "VFLX" | wgrib2 -i $splanl_file -grib_out temp_file.grib2 > msg
  else
    wgrib2 $wgrib2_file |  grep "VFLX" | wgrib2 -i $wgrib2_file -grib_out temp_file.grib2 >> msg
  fi
  # --- do interpolation
  wgrib2 temp_file.grib2 -small_grib ${lon_beg}:${lon_end} ${lat_beg}:${lat_end} ${output_file}.grib2
  exit
  wgrib2 temp_file.grib2 -new_grid_winds earth -new_grid_interpolation bilinear \
          -new_grid latlon ${lon_beg}:${NX}:${res} ${lat_beg}:${NY}:${res} \
           ${output_file}.grib2 >> msg
 exit
  # --- save the dimension
  if test -e dimension.dat ; then
     rm -f dimension.dat
  fi
  echo $NX $NY $lon_beg $lon_end $lat_beg $lat_end $res > dimension.dat
  # -------------------------------------
  # ----- max_spd for cases -------------
  if [ ${max_spd} -ge 1 ] ; then
    # --- convert GRIB2 into ASCII format
    wgrib2 ${output_file}.grib2 -text ${output_file}.txt >> msg
    # --- call convert_winds.f90
    if test ! -e functions/max_spd.exe ; then
       pgf90 functions/max_spd.f90 -o functions/max_spd.exe
    fi
    functions/max_spd.exe ${output_file}.txt
    rm -f ${output_file}.txt
  fi
  # -------------------------------------
  # ----- output all data   -------------
  if [ ${out_all} -ge 1 ] ; then
    wgrib2 ${output_file}.grib2 -text sfc_wind >> msg
    if test ! -e functions/convert_winds.exe ; then
       pgf90 functions/convert_winds.f90 -o functions/convert_winds.exe
    fi
    functions/convert_winds.exe
    mv sfc_wind_ok ${output_file}.sfc
    rm -f sfc_wind temp_file.grib2
    # ---
    YY=`echo $fdate | cut -c1-4`
    MM=`echo $fdate | cut -c5-6`
    DD=`echo $fdate | cut -c7-8`
    HH=`echo $ftime`
    sed 's/YYYY-MM-DD:HH/'$YY-$MM-${DD}\_$HH'/g' ${output_file}.sfc > tmp_file
    mv -f tmp_file ${output_file}.sfc
    # --- do plot
    if [ $if_plot -ge 1 ] ; then
      if test ! -e functions/plot_winds.exe ; then
         pgf90 functions/plot_winds.f90 -o functions/plot_winds.exe
      fi
      functions/plot_winds.exe ${output_file}.sfc
    fi
    # --- output 
    if test ! -d ${YY}_sfc ; then
      mkdir ${YY}_sfc
    fi
    cd ${YY}_sfc

    if test ! -d sfc_${MM} ; then
      mkdir sfc_${MM}
    fi
    cd sfc_${MM}
    mv ../../*.sfc ./
    cd ../..
    
    if [ $if_plot -ge 1 ] ; then
      cd ${YY}_sfc
      if test ! -d jpg_${MM} ; then
         mkdir jpg_${MM}
      fi
      cd jpg_${MM}
      mv ../../*.gif ./
      cd ../..
    fi
  fi
  #=========================================
  #------------ fcst 5 times ---------------
  if [ ${int_hour} -ge 3 ] ; then
    fcst=3
    fcst_all=3
  else 
    fcst=1
    fcst_all=5
  fi

  if [ ${int_hour} -ge 6 ] ; then
    fcst=6
    fcst_all=3
  fi
 
  while [ $fcst -le ${fcst_all} ]
  do
    ftime_ok=`expr ${ftime} + ${fcst}`
    if [ ${ftime_ok} -lt 10 ] ; then
      ftime_ok='0'${ftime_ok}
    fi
    input_fcst=${fdate}${ftime_ok}
    output_fcst=${fdate}_${ftime_ok}
    echo $output_fcst $NX $NY 
    # ---
    wgrib2 $wgrib2_file | grep d=$input_file |  grep "${fcst} hour fcst" | wgrib2 -i $wgrib2_file -grib_out \
    temp_fcst.grib2 >>msg
    # ---
    wgrib2 temp_fcst.grib2 -new_grid_winds earth -new_grid_interpolation bilinear \
          -new_grid latlon ${lon_beg}:${NX}:${res} ${lat_beg}:${NY}:${res} \
           ${output_fcst}.grib2 >> msg
    # -------------------------------------
    # ----- max_spd for cases -------------
    if [ ${max_spd} -ge 1 ] ; then
      wgrib2 ${output_fcst}.grib2 -text ${output_fcst}.txt >> msg
      functions/max_spd.exe ${output_fcst}.txt
      rm -f  ${output_fcst}.txt
    fi
    # -------------------------------------
    # ----- output all data   -------------
    if [ ${out_all} -ge 1 ] ; then
      wgrib2 ${output_fcst}.grib2 -text sfc_wind >> msg
      functions/convert_winds.exe
      mv sfc_wind_ok ${output_fcst}.sfc
      rm -f sfc_wind temp_file.grib2
      # ---
      YY=`echo $fdate | cut -c1-4`
      MM=`echo $fdate | cut -c5-6`
      DD=`echo $fdate | cut -c7-8`
      HH=`echo $ftime_ok`
      sed 's/YYYY-MM-DD:HH/'$YY-$MM-${DD}\_$HH'/g' ${output_fcst}.sfc > tmp_file
      mv -f tmp_file ${output_fcst}.sfc
      # --- do plot
      if [ $if_plot -ge 1 ] ; then
        if test ! -e functions/plot_winds.exe ; then
         pgf90 functions/plot_winds.f90 -o functions/plot_winds.exe
        fi
        functions/plot_winds.exe ${output_fcst}.sfc
      fi
      # --- output 
      if test ! -d ${YY}_sfc ; then
        mkdir ${YY}_sfc
      fi
      cd ${YY}_sfc

      if test ! -d sfc_${MM} ; then
        mkdir sfc_${MM}
      fi
      cd sfc_${MM}
      mv ../../*.sfc ./
      cd ../..
    
      if [ $if_plot -ge 1 ] ; then
        cd ${YY}_sfc
        if test ! -d jpg_${MM} ; then
           mkdir jpg_${MM}
        fi
        cd jpg_${MM}
        mv ../../*.gif ./
        cd ../..
      fi
    fi
    # -------------------------------------
    # --- next case
    fcst=`expr $fcst + 1`
  done 

  # =================================
  # --- do delete
  rm -f msg temp*.grib2 dimension.dat *.grib2
  if test ! -s ${YY}.msg ; then
    rm -f ${YY}.msg
  fi
  # =================================
  # --- next case
   day=`expr ${day} + 1`
 done
 # ==================== End of File ========================


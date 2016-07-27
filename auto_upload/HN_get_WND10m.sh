#!/bin/sh
  . /etc/profile
  . ~/.bashrc
  unalias -a
  current_root=/public/wind_flow/flow/WGS/auto_upload/wgs_wind
  cd $current_root
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
  #lon_beg=105
  #lon_end=127.5
  #lat_beg=18
  #lat_end=41.5
  lon_beg=105
  lon_end=120
  lat_beg=9
  lat_end=24
  #lon_beg=117
  #lon_end=130
  #lat_beg=25
  #lat_end=41
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
  int_hour=`wgrib2 $wgrib2_file | sed -n 1p | sed 's/:/ /g' |  sed 's/=/ /g' | awk '{print $9}'`
  #echo $output_file $int_hour
  echo $output_file $int_hour
  if [ $int_hour = 'anl' ] ; then
    int_hour=0
  fi
  beg_day=` echo $output_file | cut -c1-8`
  beg_hour=` echo $output_file | cut -c9-10`
  #echo $beg_day $beg_hour $int_hour
  output_file=` date +"%C%y%m%d%H" -d ''${beg_day}' '${beg_hour}' '${int_hour}' hours' `
  #echo $output_file
  fyear=`echo $output_file | cut -c1-4`
  fmonth=`echo $output_file | cut -c5-6`
  fdate=`echo $output_file | cut -c1-8`
  ftime=`echo $output_file | cut -c9-10`
  
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
  
  echo "=================="
  echo $output_file $NX $NY 

  # ------
  wgrib2 $wgrib2_file | grep GRD | grep "10 m above" | wgrib2 -i $wgrib2_file -grib_out temp_file.grib2 > msg
  # --- do interpolation
  wgrib2 temp_file.grib2 -new_grid_winds earth -new_grid_interpolation bilinear \
          -new_grid latlon ${lon_beg}:${NX}:${res} ${lat_beg}:${NY}:${res} \
           ${output_file}.grib2 >> msg
  # --- save the dimension
  if test -e dimension.dat ; then
     rm -f dimension.dat
  fi
  echo $NX $NY $lon_beg $lon_end $lat_beg $lat_end $res > dimension.dat
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

  # =================================
  # --- do delete
  rm -f msg temp*.grib2 dimension.dat *.grib2
  if test ! -s ${YY}.msg ; then
    rm -f ${YY}.msg
  fi
 # ==================== End of File ========================


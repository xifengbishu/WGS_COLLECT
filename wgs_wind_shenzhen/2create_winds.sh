#!/bin/sh
  . /etc/profile
  unalias -a
  current_root=/public/wind_flow/flow/WGS/auto_upload/wgs_wind_shenzhen
  cd $current_root
  wnd10m_root=${current_root}/GFS/GFS_DATA
  
  # ==============================
  # --- Step 1 Download GFS ---
  # ==============================
  cd ./GFS
  # --- Download GFS Files 
  ./get_gfs.sh  -1  12  12  60  3 
  fdate_dir=`date +"%Y%m%d" `
  date_dir=`date +"%Y%m%d" --date "-1 days"`

  gfs_num=`ls ./${date_dir}12/*gfs.t12z* | wc -l`
  if [ $gfs_num -lt 17 ] ;  then
     if [ -d ${date_dir}12 ] ; then
        rm -rf ${date_dir}12
     fi
     ./less_get_gfs.sh -1  12  12  60  3  0
  fi
  # --- Combine
  if [ -d ${date_dir}12 ] ; then
    mv ./${date_dir}12 ./${fdate_dir}00
  fi
  if [ -d ./GFS_DATA/${fdate_dir}00 ] ; then
    rm -rf ./GFS_DATA/${fdate_dir}00
  fi
  mv ./${fdate_dir}00 ./GFS_DATA 
  # ------------------------------
  #  --- judge if WRFDA is done or not
  sleep 10
  wait_wrfda_num=0
  while [ $wait_wrfda_num -lt 360 ]
  do
     gfs_num=`ls ./GFS_DATA/${fdate_dir}00/*gfs.t12z* | wc -l`
     if [ $gfs_num -eq 17 ] ; then
        echo ' GFS download was OK '
        sleep 5
        break
     else
        sleep 10
     fi
     wait_wrfda_num=`expr $wait_wrfda_num + 1`
  done 
  # ==============================
  # --- Step 2 get_WND10m  ---
  # ==============================

  # --- yesterday
  year=`date +%Y `
  mon=`date +%m `
  day=`date +%d `
  # ----
  cd $current_root
  # ==== D01
  ln -s ${wnd10m_root}/$year$mon${day}00/*gfs.t12z* ./ 
  for file in ./*gfs.t12z*
  do
    ./get_WND10m_D01.sh ${file}
    rm -f $file
  done
  ./wrf_all_winds_nc.exe *sfc

  if [ ! -e $year$mon${day}/D01/sfc ] ; then
     mkdir -p $year$mon${day}/D01/sfc
  fi
  
  mv ${current_root}/*sfc ./$year$mon${day}/D01/sfc
  mv ${current_root}/wrf_${year}${mon}${day}.nc ./$year$mon${day}/D01/${year}${mon}${day}.nc
  # ==== D02
  ln -s ${wnd10m_root}/$year$mon${day}00/*gfs.t12z* ./ 
  for file in ./*gfs.t12z*
  do
    ./get_WND10m_D02.sh ${file}
    rm -f $file
  done
  ./wrf_all_winds_nc.exe *sfc
  if [ ! -e $year$mon${day}/D02/sfc ] ; then
     mkdir -p $year$mon${day}/D02/sfc
  fi
  
  mv ${current_root}/*sfc ./$year$mon${day}/D02/sfc
  mv ${current_root}/wrf_${year}${mon}${day}.nc ./$year$mon${day}/D02/${year}${mon}${day}.nc
# ======= End of FIle =============

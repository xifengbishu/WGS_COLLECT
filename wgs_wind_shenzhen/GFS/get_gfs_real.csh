#!/bin/csh
  . /etc/profile
  . /public/wind_flow/flow/.bashrc
  unalias -a
  set current_root = /public/wind_flow/flow/WGS/auto_upload/wgs_wind_shenzhen/GFS
  cd $current_root
  # --- Download GFS Files 
  ./get_gfs.sh  -1  12  12  60  3 
  # --- Combine
  set fdate_dir = `date +"%Y%m%d" `
  set date_dir = `date +"%Y%m%d" --date "-1 days"`
  if ( -d ${date_dir}12 )  then
    mv ./${date_dir}12 ./${fdate_dir}00
    mv ./${fdate_dir}00 ./GFS_DATA 
  endif
# ===================== End of File ========================

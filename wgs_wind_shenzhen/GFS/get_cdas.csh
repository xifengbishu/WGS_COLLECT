#!/bin/csh
  . /etc/profile
  . /public/wind_flow/flow/.bashrc
  unalias -a
  set current_root = /public/wind_flow/flow/WGS/auto_upload/wgs_wind_shenzhen/GFS
  cd $current_root
  # --- Download GFS Files 
  ./get_cdas.sh  -1  00  0 6 1 
  ./get_cdas.sh  -1  06  0 6 1 
  ./get_cdas.sh  -1  12  0 6 1 
  ./get_cdas.sh  -1  18  0 6 1 
# ===================== End of File ========================

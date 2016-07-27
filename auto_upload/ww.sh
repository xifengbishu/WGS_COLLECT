
  # =========================================
  # --- Step 3 get_WND10m  for ZHEJIANG---
  # =========================================
  #/home/nmdis/WGS/wgs_wind/WRF_WIND/wrf_create_winds_1h_D02.sh
#==================================
datetime=`date +%Y%m%d`
    lftp -u flow,flow sftp://115.236.180.212 << EOF
    mput -c -E -O fvcom/output/netcdf $HOME/WGS/wgs_wind/WRF_WIND/${datetime}/wind${datetime}.nc
    quit
EOF

# ======= End of FIle =============

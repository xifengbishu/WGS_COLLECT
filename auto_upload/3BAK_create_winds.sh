#!/bin/sh
  . /etc/profile
  . ~/.bashrc
  unalias -a
  current_root=/public/wind_flow/flow/WGS/auto_upload/wgs_wind
  cd $current_root
  wnd10m_root=${current_root}/GFS/GFS_DATA
  
  # =========================================
  # --- Step 2 get_WND10m  for SHENZHEN---
  # =========================================

  # --- yesterday
  year=`date +%Y `
  mon=`date +%m `
  day=`date +%d `
  # ----
  cd $current_root
  ln -s ${wnd10m_root}/$year$mon${day}00/*gfs.t12z* ./ 
  for file in ./*gfs.t12z*
  do
    #ln -s $file ./
    #gfs_file=` echo $file:t `
    ./SZ_get_WND10m.sh ${file}
    rm -f $file
  done

  cd ~/wrf_winds_wgs
  if [ ! -e $year$mon${day} ] ; then
     mkdir $year$mon${day}
  fi
  mv ${current_root}/*sfc ./$year$mon${day}
  datetime=`date +%Y%m%d`
  mv ./$year$mon${day} ./SZ_$year$mon${day}
  tar -cvf ${datetime}.tar SZ_${datetime}

#==================================


    lftp -u flow,nmdis693 sftp://61.144.248.178 << EOF
    mput -c -E -O test/wind $HOME/wrf_winds_wgs/${datetime}.tar
    quit
EOF

  # =========================================
  # --- Step 3 get_WND10m  for ZHEJIANG---
  # =========================================
  /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/wrf_create_winds_1h_D02.sh
  datetime=`date +%Y%m%d`
  cp /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime}/wind${datetime}.nc /public/data/wind${datetime}.nc
  mv /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime} ~/wrf_winds_wgs/${datetime}_D02
  mv /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime} /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime}_D02
 
  /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/wrf_create_winds_1h_D01.sh
  datetime=`date +%Y%m%d`
  cp /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime}/wind${datetime}.nc /public/data/HaiNan_wind${datetime}.nc
  cp -r /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime} ~/wrf_winds_wgs/${datetime}_D01
  mv /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime} /public/wind_flow/flow/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime}_D01
 
#==================================

  # =========================================
  # --- Step 4 get_WND10m  for BEIJING---
  # =========================================
#  /home/nmdis/WGS/wgs_wind/WRF_WIND/wrf_create_winds_1h_D02.sh
#==================================
    datetime=`date +%Y%m%d`

    lftp -u flow,flow sftp://115.236.180.212 << EOF
    mput -c -E -O fvcom/output/netcdf $HOME/WGS/auto_upload/wgs_wind/WRF_WIND/${datetime}_D02/wind${datetime}.nc
    quit
EOF


# ======= End of FIle =============

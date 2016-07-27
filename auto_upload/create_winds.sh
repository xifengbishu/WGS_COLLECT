#!/bin/sh
  . /etc/profile
  . ~/.bashrc
  unalias -a
  current_root=/home/nmdis/WGS/wgs_wind
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
datetime=`date +%Y%m%d`

cd $HOME/WGS/GFS/GFS_DATA
    tar -cvf ${datetime}00.tar ${datetime}00

    lftp -u flow,nmdis693 sftp://61.144.248.178 << EOF
    mput -c -E -O test/wgs_wind_shenzhen/GFS/GFS_DATA $HOME/WGS/GFS/GFS_DATA/${datetime}00.tar
    quit
EOF

# ======= End of FIle =============

#!/bin/sh
  . /etc/profile
  . ~/.bashrc
  unalias -a
  current_root=$HOME/WGS/wgs_wind
  cd $current_root
  wnd10m_root=${current_root}/GFS/GFS_DATA
  
  # ==============================
  # --- Step 1 Download GFS ---
  # ==============================
  
  cd ./GFS
  ./get_gfs_cycle.sh
  # ==============================
  # --- Step 2 get_WND10m  ---
  # ==============================

  # --- yesterday
  year=`date +%Y `
  mon=`date +%m `
  day=`date +%d `
  # ----
  cd $current_root
  ln -s ${wnd10m_root}/$year$mon${day}12/*gfs.t* ./ 
  for file in ./*gfs.t*
  do
    #ln -s $file ./
    #gfs_file=` echo $file:t `
    ./get_WND10m.sh ${file}
    rm -f $file
  done

  cd ../wind2
  if [ ! -e $year$mon${day}12 ] ; then
     mkdir $year$mon${day}12
  fi
  mv ${current_root}/*sfc ./$year$mon${day}12

#==================================
datetime=`date +%Y%m%d`

cd $HOME/WGS/wind2
    tar -cvf ${datetime}12.tar ${datetime}12

    lftp -u flow,nmdis693 sftp://61.144.248.178 << EOF
    mput -c -E -O test/wind2 $HOME/WGS/wind2/${datetime}12.tar
    quit
EOF

# ======= End of FIle =============

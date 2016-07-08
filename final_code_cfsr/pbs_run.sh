#!/bin/bash
#PBS -N wgs_wind
#PBS -o PBS_run.msg
#PBS -e PBS_run.msg
#PBS -j oe 
#
# =======================================================
# ---
# ---   Please do modify below !!!
# ---
# =======================================================
# --- Please modify nodes and ppn
# --- for server seafog, change ppn (<=12) only!
# --- 18 Jan 2011, Gao Shanhong.
# ----------------------------------------------
# 
#PBS -l nodes=1:ppn=1
#PBS -l walltime=999999:00:00
#
# =======================================================

  RUN_HOST="hostname"
  NA=`wc -l < $PBS_NODEFILE`
  cd $PBS_O_WORKDIR
  cat $PBS_NODEFILE > .nodefile

  ulimit -s unlimited
  ./create_winds_all.sh  $NA > my_final.msg 2>&1

#===================== End of File ======================


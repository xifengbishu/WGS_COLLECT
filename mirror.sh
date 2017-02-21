#!/bin/sh
# ----------------------------------------------------------------------
# --- Purpose:                                                       ---
# ---   sftp WRF winds to shandong SERVICE                           ---
# ---   If WRF result was break , use GFS wind replace               ---
# ----------------------------------------------------------------------
# ---                                                                ---
# --- National Marine Data and Information Service ( NMDIS )         ---
# --- http://www.nmdis.gov.cn/                                       ---
# --- Wang Guosong                                                   ---
# --- Please send any further problems, comments, or suggestions to  ---
# --- <wgs_WRF@163.com>                                              ---
# --- Based on Dr. GAO Shanhong ( OUC )source program                ---
# --- All rights reserved !                                          ---
# ---                                                                ---
# --- History:                                                       ---
# --- (1) Thu Aug 29 10:43:46 CST 2013, NMDIS.                       ---
# ----------------------------------------------------------------------

# === Step-0:
# ===
  current_root=/public/wind_flow/flow
  user=flow
  passwd=flow\!flow\!
  svr_ip=218.249.66.30
  LCD=/home/wind/WGS/Bulletin/Monthly_Bulletin/download/ssh
  RCD=/public/wind_flow/flow/WGS/Bulletin/Monthly_Bulletin/download/ssh


echo  “script Start at “ `date +%Y-%m-%d_%H:%M`

# ===
# === Step-1: Check  variables, echo history and usage
# ===

    lftp -u ${user},${passwd} sftp://${svr_ip} << EOF
    echo "Load OK !!! "
    mirror $RCD $LCD
    quit
EOF
echo  “script End at “ `date +%Y-%m-%d_%H:%M`

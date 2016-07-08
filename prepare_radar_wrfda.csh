#! /bin/csh
# ------------------------------------------------------------------------------
#
#  Note :         
#     Radar_date must put in the folder named "radar_data" !!!
#
#     Each radar date time must contain FOUR elvation.
#
#     Of course, every time have reflectivity and velocity !
#     
#     EACH RESULT FILE CONTAINS THREE TIME ( T1, T2, T3 )
#                                                ^
#                                                ^
#                                       TIME READING OBS DATA
#
# ------------------------------------------------------------------------------

  # ------------------------------ time setting --------------------------------
  # ---- [Beijing time]
  #
  # ---- date_intv unit: hour
  # ---- If you need interval, which is less than a hour, 
  # ---- then change the file namelist.rdr by yourself!
  #=============================================================================
  #=====      if_three = 0 / 1                                             =====
  #=====      1: each result contains three times                          =====
  #=====      0: each result only contains middle time                     =====
  #=====      NOTE: if_three = 1, change radar_num = 3 (namelist.rdr_base) =====
  #=====            if_three = 0, change radar_num = 1 (namelist.rdr_base) =====
  #===== 2010-10-10: Do not change "namelist.rdr_base" any more!!!         =====
  #=============================================================================
  # ----------------------------------------------------------------------------
    #
    set year = 2007
    set mon  = 04
    set day  = 28
    set hour = 02
    #
    set case_num  = 7
    set date_intv = 1
    #
    set if_three = 0
    #
  # -------------------------------------------------
  #
  #  DO NOT CHANGE ANYTHING BELOW, ANY QUESTION 
  #  CONTACT WITH DR.GAO SH OR WANG YM PLEASE!
  #
  # -------------------------------------------------
  #
  # ---- judge floder "radar_data" exist?
    if( ! -d radar_data) then
       echo ' '
       echo ' Radar_data is needed, where the radar data put!'
       echo ' '
       exit
    endif

  # ---- judge namelist.rdr_base exist?
    if( ! -e namelist.rdr_base ) then
       echo ' '
       echo ' namelist.rdr_base is needed!'
       echo ' '
       exit
    endif

  # ---- judge namelist.rdr & radar_obs exist?
    if( -e namelist.rdr ) then
       rm -f namelist.rdr
    endif
    #
    if( -d radar_obs ) then
       rm -rf radar_obs
    endif
  
  # --- creat a new radar_obs
    mkdir radar_obs
  
  # ---- go into radar_obs
    cd radar_obs/
    cp ../namelist.rdr_base .
    ln -s ../radar_data .

  # ---- start to creat the file which WRFDA needed 
    set num = 0
    set case_num = `expr $case_num - 1`
    while( $num <= $case_num )
      set hh1 = `expr $num \* $date_intv - 1`
      set hh  = `expr $num \* $date_intv`
      #
      # --- creat the file name
      #
          set yr = `date +%Y -d "$year$mon$day $hour $hh hours"`
          set mm = `date +%m -d "$year$mon$day $hour $hh hours"`
          set dy = `date +%d -d "$year$mon$day $hour $hh hours"`
          set hr = `date +%H -d "$year$mon$day $hour $hh hours"`
      #
      set result_file = obs_radar_${yr}${mm}${dy}_${hr}0000.radar
      #
      # --- creat the begin time
      #
      if( $hh1 >= 0 ) then
          set yr1 = `date +%Y -d "$year$mon$day $hour $hh1 hours"` 
          set mm1 = `date +%m -d "$year$mon$day $hour $hh1 hours"` 
          set dy1 = `date +%d -d "$year$mon$day $hour $hh1 hours"` 
          set hr1 = `date +%H -d "$year$mon$day $hour $hh1 hours"`
      endif
      #
      if( $hh1 < 0 ) then
          set hh1 = `expr -1 \* $hh1`
          set yr1 = `date +%Y -d "$year$mon$day $hour $hh1 hours ago"`
          set mm1 = `date +%m -d "$year$mon$day $hour $hh1 hours ago"`
          set dy1 = `date +%d -d "$year$mon$day $hour $hh1 hours ago"`
          set hr1 = `date +%H -d "$year$mon$day $hour $hh1 hours ago"`
      endif
      #
      # --- creat the end time
      #
      set hh2 = `expr $date_intv - 1`
      set yr2 = `date +%Y -d "$yr1$mm1$dy1 $hr1 $hh2 hours"`
      set mm2 = `date +%m -d "$yr1$mm1$dy1 $hr1 $hh2 hours"`
      set dy2 = `date +%d -d "$yr1$mm1$dy1 $hr1 $hh2 hours"`
      set hr2 = `date +%H -d "$yr1$mm1$dy1 $hr1 $hh2 hours"`
      #
      # ---- submit new time to namelist.rdr
      if( ${if_three} == 1 ) then
          sed 's/20070428.0200001/'${yr1}${mm1}${dy1}'.'${hr1}'0000/g'  \
               namelist.rdr_base | \
          sed 's/20070428.0500001/'${yr2}${mm2}${dy2}'.'${hr2}'0000/g'  \
               > namelist.rdr
          sed '/ radar_num = 1,/c\\ radar_num = 3,'  namelist.rdr > msg
      else
          sed 's/20070428.0200001/'${yr}${mm}${dy}'.'${hr}'0000/g' \
               namelist.rdr_base | \
          sed 's/20070428.0500001/'${yr}${mm}${dy}'.'${hr}'0000/g' \
               > namelist.rdr
      endif
      # ---- run radar.exe to creat the file
      ln -s ../radar_codes/radar.exe .
      ./radar.exe

      # ---- next case ---
      set num = `expr $num + 1`
      
      # ---- put result into should folder
      mkdir step${num}
      mv ob.radar ${result_file}
      mv ${result_file} step${num}/

      # ---- delete radar.exe
      rm -f radar.exe
    end
    
    # ---- delete namelist* and linked
     rm -f namelist* radar_data

# ========================== End of File ========================

#!/bin/csh
# --------------------------------------------------
# --- Purpose:
# ---   Create namelist.input files for WRFDA use.
# ---
# ---
# --- Dr. GAO Shanhong, 11 Jul 2009, Yushan campus.
# --------------------------------------------------
# --- 1) Modified for the date of SGI
# ---    machine names: a330, a3700
# ---    29 Oct 2009, Yushan campus.
# ---
# --- 2) Let it be called and executed automatically
# ---    by cycling_3dvar_wrf_run.csh 
# ---    31 Oct 2009, Yushan campus.  
# ---    However, please be careful !   
# ---    
# --- 3) It is OK for V3.2 !  
# ---    11 Apr 2010, Yushan campus.
# ---
# --- 4) Usage of Date is automatically decided!
# ---    14 Apr 2010.
# ---
# --- 5) For cycling hybrid-3dvar
# ---    input num_tiles
# ---    10 Aug 2010.
# ---
# --- 6) add je_factor and alpha_corr_scale
# ---    14 Sep 2010.
# ---
# --- 7) add PBL, MP control
# ---    14 Apr 2011.
# ---
# --- 8) add alpha_vertloc
# ---    23 Dec 2012, Yushan campus.
# --------------------------------------------------

 #set aim = 'test'
 set aim = 'real'

 if( $aim == 'test' ) then
   echo ' --- for test only !'
 else
   if( ${#} < 4 ) then
     echo ""
     echo ' Error:'
     echo '       Input vaiables are not enough!'
     echo ""
     exit
   endif
 endif

 # --- test aim
 if( $aim == 'test' ) then
   # --- do settings of Date-Time 
   set cycle_date_beg = 2006-03-05_12 
   set cycle_date_end = 2006-03-06_00
   set cycle_intv_hr  = 3
   #
   #set cv_number      = 3
   # --- If you have prepares your own be.dat, then 
   set cv_number      = 5 
   #
   set num_tiles      = 8
   # ==========================================
   # ==== Here, End of Your Modifications! ====
   # ==========================================
 endif

 # --- real aim
 if( $aim == 'real' ) then
   # --- do settings of Date-Time
   set cycle_date_beg = ${1}
   set cycle_date_end = ${2}
   set cycle_intv_hr  = ${3}
   set cv_number      = ${4}
   set num_tiles      = ${5}
   set je_factor      = ${6}
   set alpha_corr_scale = ${7}
   set alpha_vertloc    = ${8}
   set mps  = ${9}
   set lays = ${10}
   set sfcs = ${11}
   set pbls = ${12}
   set cups = ${13}
   set rass = ${14}
   set rals = ${15}
   set radt = ${16}
   set nsol = ${17}
   set cutt = ${18}
 endif

 # --- do clean
 set num = 1
 while( $num <= 99 )
   #
   if( -e namelist.input_step${num} ) then
     rm -f namelist.input_step${num} namelist.input_step*
   endif
   #
   set num = ` expr $num + 1 `
 end

 # --- how many times of 3dvar-cycle ?
 set date_beg  = `echo $cycle_date_beg | sed "s/_/ /g" | awk '{print $1}'`
 set hour_beg  = `echo $cycle_date_beg | sed "s/_/ /g" | awk '{print $2}'`

 set cycle_num = 1
 while( $cycle_num <= 99  )
   set hr = `expr $cycle_num \* $cycle_intv_hr `
   set cycle_check = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $hr hours"`
   if( $cycle_check == $cycle_date_end ) then
     break
   endif
   set cycle_num = ` expr $cycle_num + 1 `
 end
 set cycle_end_num = `expr $cycle_num + 1`

 # --- calculate half_window time
 set cycle_intv_min = `expr $cycle_intv_hr \* 60`
 set half_win_time  = `expr $cycle_intv_min \/ 2`
 set half_win_hr    = `expr $half_win_time \/ 60`
 set half_win_min   = `expr $half_win_time - $half_win_hr \* 60 `

 # --- create namelist_step?
 # --- check date usage 
 #set if_ago      = 'ago'
 #set machine     = `/bin/uname -a | awk '{print $2}'`
 #if( $machine == 'a330' || $machine == 'a3700' ) then
 #    set if_ago = ' ' 
 #endif
 #
 set date_check = ` date +%Y%m%d%H%M --date "20100101 00 1 hour ago 30 min ago" `
 if( $date_check == '200912312230' ) then
   set if_ago = 'ago'
 endif
 if( $date_check == '201001010030' ) then
   set if_ago = ' '
 endif
 #
 set num = 1
 while( $num <= $cycle_end_num )
   # --- analysis time
   set num_hr = `expr $num - 1`
   set hr = `expr $num_hr \* $cycle_intv_hr`
   set analysis_date_cycle = `date +%{Y}-%{m}-%{d}_%{H}:00:00.0000 --date "$date_beg $hour_beg $hr hours"`   
   # --- windows (min and max)
   set  analysis_date  = `echo $analysis_date_cycle | awk '{print substr($1,1,10)}'`
   set  analysis_hour  = `echo $analysis_date_cycle | awk '{print substr($1,12,2)}'`
   set time_window_min = `date +%{Y}-%{m}-%{d}_%{H}:%{M}:00.0000 --date "$analysis_date $analysis_hour \
                          $half_win_hr hours $if_ago $half_win_min min ago"`
   set time_window_max = `date +%{Y}-%{m}-%{d}_%{H}:%{M}:00.0000 --date "$analysis_date $analysis_hour \
                          $half_win_hr hours $half_win_min min "`
   # --- YY, MM, DD and HH
   set cycle_beg = `date +%{Y}' '%{m}' '%{d}' '%{H} --date "$date_beg $hour_beg $hr hours"`
   set beg1 = `echo $cycle_beg | awk '{print $1}'`
   set beg2 = `echo $cycle_beg | awk '{print $2}'`
   set beg3 = `echo $cycle_beg | awk '{print $3}'`
   set beg4 = `echo $cycle_beg | awk '{print $4}'`
   set end1 = ${beg1}
   set end2 = ${beg2}
   set end3 = ${beg3}
   set end4 = ${beg4}

   # --- namelist.input
   sed "s/analysis_date_cycle/"${analysis_date_cycle}"/g" namelist.input_temp | \
   sed "s/time_min_cycle/"${time_window_min}"/g" | \
   sed "s/time_max_cycle/"${time_window_max}"/g" | \
   sed "s/beg1/"${beg1}"/g" | \
   sed "s/beg2/"${beg2}"/g" | \
   sed "s/beg3/"${beg3}"/g" | \
   sed "s/beg4/"${beg4}"/g" | \
   sed "s/end1/"${end1}"/g" | \
   sed "s/end2/"${end2}"/g" | \
   sed "s/end3/"${end3}"/g" | \
   sed "s/end4/"${end4}"/g" | \
   sed "s/mps/"${mps}"/g"   | \
   sed "s/lays/"${lays}"/g" | \
   sed "s/sfcs/"${sfcs}"/g" | \
   sed "s/nsol/"${nsol}"/g" | \
   sed "s/pbls/"${pbls}"/g" | \
   sed "s/cups/"${cups}"/g" | \
   sed "s/cutt/"${cutt}"/g" | \
   sed "s/rass/"${rass}"/g" | \
   sed "s/rals/"${rals}"/g" | \
   sed "s/ra_dt/"${radt}"/g"| \
   sed "s/cv_number/"${cv_number}"/g"              | \
   sed "s/je_factor_value/"${je_factor}"/g"        | \
   sed "s/if_alpha_vertloc/"${alpha_vertloc}"/g"   | \
   sed "s/alpha_corr_scale_value/"${alpha_corr_scale}"/g"  \
   > namelist.input_step${num}

   #
   # --- numtiles 
   sed "s/num_tiles/"${num_tiles}"/g"  namelist.input_step${num} > tmp_namelist
   mv -f tmp_namelist namelist.input_step${num}
   #
   set num = ` expr $num + 1 `
 end


  # --- echo information 
  echo ''
  echo ' -----------------------------------------------------------'
  echo ' -----------  create_da_namelists.csh   --------------------'
  echo ' -----------------------------------------------------------'
  echo ''
  echo '  Are the settings of namelist.input_base OK ?'
  echo '  Please modify &domain and &physics in namelist.input_base '
  echo '  before you run this script !'
  echo ''
  echo ' -----------------------------------------------------------'
  echo ''

# ===================== End of File ======================

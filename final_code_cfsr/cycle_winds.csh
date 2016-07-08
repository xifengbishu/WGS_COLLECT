#!/bin/csh
#  ==================== README for data of Wind ==========================
#  ===                                                                 ===
#  ===         Based on the tutor Gao's source program                 ===
#  ===         Wang Guosong, 20 Feb 2012.                              ===
#  ===                                                                 ===
#  =======================================================================

# ===
# === Step-1: Check  variables, echo history and usage
# ===
  if (${#} == 0) then
    echo 'Usage '
    echo ' run.csh year '
    echo ' For example '
    echo ' run.csh 2010'
  endif

  # --- settings
  set year = 2013
  while ( ${year} <= 2015 )
  #set year = $1
  set yy = `echo ${year} | cut -c3-4`
  set month_day = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
  set hour_time = ( "00" "06" "12" "18" )
  set left = `expr ${year} % 4`
  if( ${left} == 0 ) then
      set month_day[2] = 29
  endif


  set month = 1
  while ( ${month} <= 12 )
    set month_ok = ${month}
    if( ${month} < 10 ) then
      set month_ok = '0'${month}
    endif

 # ==================== Begin of File ========================
  set cfsr_root = "./DATA"
  ln -s $cfsr_root/wnd10m.cdas1.${year}${month_ok}.grb2
  set wgrib2_file = wnd10m.cdas1.${year}${month_ok}.grb2
 # ==================== Begin of File ========================

    set day = 1
    while ( ${day} <= ${month_day[${month}]} )
      set day_ok = ${day}
      if( ${day} < 10 ) then
        set day_ok = '0'${day}
      endif
      set hour = 1
      while ( ${hour} <= 4 )

 # ==================== Begin of File ========================
        
  set fdate = `echo ${year}${month_ok}${day_ok}`
  set ftime = `echo ${hour_time[$hour]}`
  
        set int = 1
        while ( ${int} <= 6 )
            echo $wgrib2_file $fdate$ftime ${int} hour fcst
            ./get_WND10m_D3.sh $wgrib2_file $fdate$ftime ${int}
#            wgrib2 $wgrib2_file | grep $fdate$ftime | grep "${int} hour fcst" | wgrib2 -i $wgrib2_file -grib_out temp_file.grib2 > msg
 # ==================== Begin of File ========================

        set int = `expr $int + 1`
      end
        set hour = `expr $hour + 1`
      end
      set day = `expr $day + 1`
    end
    set month = `expr $month + 1`
  end
    set year = `expr $year + 1`
  end

# ======= End of FIle =============

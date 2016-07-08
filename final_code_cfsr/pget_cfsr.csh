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
  set year = 2011
  while ( ${year} <= 2015 )
  #set year = $1
  set yy = `echo ${year} | cut -c3-4`
  set month_day = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
  set hour_time = ( "00" "06" "12" "18" )
  set left = `expr ${year} % 4`
  if( ${left} == 0 ) then
      set month_day[2] = 29
  endif

  set cfsr_root = "/data/data_tansfer/cfsr"
  rm -f lftp
  set month = 1
  while ( ${month} <= 12 )
    set month_ok = ${month}
    if( ${month} < 10 ) then
      set month_ok = '0'${month}
    endif
    set day = 1
    while ( ${day} <= ${month_day[${month}]} )
      set day_ok = ${day}
      if( ${day} < 10 ) then
        set day_ok = '0'${day}
      endif
      set hour = 1
      while ( ${hour} <= 4 )
        echo 'pget -n 100 http://soostrc.comet.ucar.edu/data/grib/cfsrr/'${year}'/'${month_ok}'/'${yy}${month_ok}${day_ok}${hour_time[$hour]}'.cfsrr.t'${hour_time[$hour]}'z.pgrb2f00' >> lftp
        set hour = `expr $hour + 1`
      end
      set day = `expr $day + 1`
    end
    set month = `expr $month + 1`
  end
    set year = `expr $year + 1`
  end

    lftp -f lftp
# ======= End of FIle =============

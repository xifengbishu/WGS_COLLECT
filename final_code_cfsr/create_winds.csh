#!/bin/csh
  if (${#} == 0) then
    echo 'Usage '
    echo ' run.csh year '
    echo ' For example '
    echo ' run.csh 2010'
  exit
  endif

  # --- settings
  set year = $1
  set maxspd = 0

  set wnd10m_root = "/data/share/WGS/wgs_CFSR_forcast_wnd10m"

  set month = 1
  while ( ${month} <= 12 )
    set month_ok = ${month}
    if( ${month} < 10 ) then
      set month_ok = '0'${month}
    endif
    if ( ${year} >= 2011 && ${month} >= 4 ) then
       set middle = cdas1
    else
       set middle = gdas
    endif
    if ( ${year} >= 2012 ) then
       set middle = cdas1
    endif
        set grib2_path = ${wnd10m_root}/${year}
        set grib2_file = ${grib2_path}/wnd10m.${middle}.${year}${month_ok}.grb2
        if ( ! -e $grib2_file ) then
           echo "No this file "$grib2_file  >> ${year}.msg
        else
           ln -s $grib2_file .
           get_WND10m.sh wnd10m.${middle}.${year}${month_ok}.grb2
        endif
    set month = `expr $month + 1`
  end
  rm -f *.grb2
  if ( maxspd = 1 ) then
  if ( -e maxspd_${year} ) then      
    pgf90 functions/pick_spd.f90 -o functions/pick_spd.exe
    functions/pick_spd.exe maxspd_${year} > ${year}_casetime
    pgf90 functions/combine_repick.f90 -o functions/combine_repick.exe
    functions/combine_repick.exe ${year}
    if (! -e MAXspd_msg ) then
       mkdir MAXspd_msg
    endif
       mv maxspd_${year} ${year}_casetime  MAXspd_msg 
  endif
  rm -f temp_${year} 
  #${year}_casetime
 
  pick_WND10m.sh recom_${year}_case 
  endif
        
# ======= End of FIle =============

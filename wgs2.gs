'reinit'
'open per_p_d02_all_list_1h.ctl'

  lon_domain   = 'lon 117 122'
  lat_domain   = 'lat  37  41'
  z_domain='z 1 23'
     t_beg=8
     t_end=8
     title='add_sta'
     color_set = 9 
     plot_nice = 0
     sta_num = 3
     if_add = 0
***************************************************************************
*********************the loop of time**************************************
t=t_beg
*'set vpage 0.2 8.5 0 11'
*'set parea 0.4 8 0.4 10.5'
while(t<=t_end)

* --- output name
  outname = title'_t_'t

*

'set grads off'
'set grid 2 1'
'set font 2'
'set mpdset hires'
'set map 1 1 6'
*'set clab forced'
'set xlopts 1 6 0.15'
'set ylopts 1 6 0.15'
'set clopts 1 6 0.15'
'set strsiz 0.25'
'set xlint 2'
'set ylint 2'
'set ccolor rainbow'
***************************************************************************

'set 'lon_domain
'set 'lat_domain
'set t 't
* -----------------------------
      do_color_set ( color_set )
      'set clevs  '_nheight
      'set rbcols '_ncolor
*     --- plot fog top
      'set gxout shaded'
      'd mag(u10m,v10m)'

'! rm -rf add_obs_station'

    i=1
    while ( i<=sta_num )
     ww = read (obs.txt)
     ww2= sublin(ww,2)
     sta_name = subwrd(ww2,1)
     sta_lon = subwrd(ww2,2)
     sta_lat = subwrd(ww2,3)
*     sta_rain = subwrd(ww2,4)
     'q w2xy 'sta_lon' 'sta_lat
     x1=subwrd(result,3)
     y1=subwrd(result,6)
     say '-----------'
     say x1' ' y1
   
     'set line 4'
     'draw mark 3 'x1' 'y1' 0.13'
     'set strsiz 0.15'
     'set string 4'
     'set cthick 5'
     'set line 2 1 4'
     'draw string 'x1-0.8' 'y1-0.2' 'sta_name
   i=i+1
   endwhile
     ss=close(obs.txt)
*
* ======== Stop ploting variabels ========

*********************************@@@time@@@********************************
'q time'
b=subwrd(result,3)
hour=substr(b,1,2)
day=substr(b,4,2)
month=substr(b,6,3)
year=substr(b,9,4)
datatime=hour%'UTC '%day%month%' '%year
********************************@@@print@@@*******************************

'draw title 'title'_t='datatime
*'cbar'

* -------------
  'enable print ./'outname'.gm'
  'print'
  'disable print'

* --- convert gm to eps
  '! gxeps -R -c -i 'outname'.gm -o 'outname'.eps'
  '! rm -f 'outname'.gm'
if ( plot_nice = 0 )
* --- convert eps to gif
  '! convert -density 144 -antialias -trim 'outname'.eps 'outname'.bmp'
  '! convert -density 144 -antialias -trim 'outname'.bmp 'outname'.jpg'
else
* --- imagick software needed
  '! convert -density 1200 -resize 25% -trim 'outname'.eps tmp.jpg'
  '! convert -density 300  tmp.jpg 'outname'.jpg'
  '! convert -resize 50% 'outname'.jpg 'outname'.gif'
  '! rm -f    tmp.jpg'
endif

  '! rm -f 'outname'.bmp'
  '! rm -f 'outname'.eps'
  '! rm -f 'outname'.gif'
*  '! display 'outname'.gif'

*********************************loop of time****************************
  t=t+1
  'c'
  endwhile
  'reinit'
  'quit'

function do_color_set(args)
  color_num = subwrd(args,1) 
* --- 9: white and red 
  if( color_num = 9 )
     'set rgb 29 237  138  138'
     'set rgb 28 202   71   71'
     'set rgb 30 88   36   31'
     'set rgb 31 223   50   17'
     'set rgb 32 255   73    0'
     'set rgb 33 252 75 45'
     'set rgb 34 253 118 52'
     'set rgb 35 252 154 38'
     'set rgb 36 248 205 89'
     'set rgb 37 250 235 110'
     'set rgb 38 238 251 132'
     'set rgb 39 197 248 136'
     'set rgb 40 168 247 155'
     'set rgb 41 139 250 189'
     _ncolor = '0  41 40 39 38 37 36 35 34 33 31 30 29'
     _nheight ='10 11 12 13 14 15 16 17 18 19 20 22 '
  endif
return

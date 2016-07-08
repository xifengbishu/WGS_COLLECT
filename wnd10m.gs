*'open 201101/ww.ctl'
'open sfc_wind_2011.ctl'
'set fwrite sfc.dat'
'set gxout fwrite'

tt = 1
while ( tt <= 360 )
'set t 'tt
'set lon 118.4167'
'set lat 38.45'
'd mag(u,v)'
*'d mag(UGRDhy1,VGRDhy1)'
ww = subwrd(result,4)
say 't='tt'   'ww

tt = tt+1
endwhile

'disable fwrite'
quit


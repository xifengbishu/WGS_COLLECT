'reinit'
'open ../nice.ctl'

lon_domain='lon 117 125'
lat_domain='lat 15 20'
  z_domain='z 1 23'
     t_beg=2
     t_end=8
     title='hdivg'
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
'set grid off'
*'set mpdset hires'
'set map 1 1 6'
*'set clab forced'
'set font 5'
'set xlopts 1 6 0.15'
'set ylopts 1 6 0.15'
'set clopts 1 6 0.15'
'set strsiz 0.25'
'set ccolor rainbow'
***************************************************************************

'set 'lon_domain
'set 'lat_domain
'set t 't
* -----------------------------
'set black 0 0'
'set cthick 6'
'd hdivg(u,v)*100000'

* -----------------------------

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
*  '! convert -resize 50% 'outname'.jpg 'outname'.gif'
  '! rm -f    tmp.jpg'
endif

  '! rm -f 'outname'.bmp'
  '! rm -f 'outname'.eps'
*  '! rm -f 'outname'.gif'
*********************************loop of time****************************
  t=t+1
  'c'
  endwhile
if ( t_beg < t_end ) 
  '!rm -rf 'title
  '!mkdir 'title
  '!mv 'title'*gif 'title
endif

*     --- shaded color 
      do_color_set ( color_set )
      'set clevs  '_nheight
      'set rbcols '_ncolor

function do_color_set(args)
  color_num = subwrd(args,1) 
* --- 4: blue and red ( for difference)
  if( color_num = 4 ) 
'set rgb  16  255  47  0'
'set rgb  17  254  64  0'
'set rgb  18  254  78  0'
'set rgb  19  254  88  0'
'set rgb  20  254  97  0'
'set rgb  21  254  105  0'
'set rgb  22  254  113  0'
'set rgb  23  253  119  0'
'set rgb  24  253  125  0'
'set rgb  25  253  131  0'
'set rgb  26  252  137  0'
'set rgb  27  252  142  0'
'set rgb  28  251  147  0'
'set rgb  29  251  151  0'
'set rgb  30  250  156  0'
'set rgb  31  250  160  0'
'set rgb  32  249  164  0'
'set rgb  33  249  167  0'
'set rgb  34  248  171  0'
'set rgb  35  247  175  0'
'set rgb  36  246  178  0'
'set rgb  37  246  181  0'
'set rgb  38  245  184  0'
'set rgb  39  244  187  0'
'set rgb  40  243  190  0'
'set rgb  41  242  193  0'
'set rgb  42  241  196  0'
'set rgb  43  240  198  0'
'set rgb  44  239  201  0'
'set rgb  45  237  203  0'
'set rgb  46  236  205  0'
'set rgb  47  235  208  0'
'set rgb  48  234  210  0'
'set rgb  49  232  212  0'
'set rgb  50  231  214  0'
'set rgb  51  230  216  0'
'set rgb  52  228  218  0'
'set rgb  53  226  220  0'
'set rgb  54  225  221  0'
'set rgb  55  223  223  0'
'set rgb  56  221  225  0'
'set rgb  57  220  226  0'
'set rgb  58  218  228  0'
'set rgb  59  216  230  0'
'set rgb  60  214  231  0'
'set rgb  61  212  232  0'
'set rgb  62  210  234  0'
'set rgb  63  208  235  0'
'set rgb  64  205  236  0'
'set rgb  65  203  237  0'
'set rgb  66  201  239  0'
'set rgb  67  198  240  0'
'set rgb  68  196  241  0'
'set rgb  69  193  242  0'
'set rgb  70  190  243  0'
'set rgb  71  187  244  0'
'set rgb  72  184  245  0'
'set rgb  73  181  246  0'
'set rgb  74  178  246  0'
'set rgb  75  175  247  0'
'set rgb  76  171  248  0'
'set rgb  77  167  249  0'
'set rgb  78  164  249  0'
'set rgb  79  160  250  0'
'set rgb  80  156  250  0'
'set rgb  81  151  251  0'
'set rgb  82  147  251  0'
'set rgb  83  142  252  0'
'set rgb  84  137  252  0'
'set rgb  85  131  253  0'
'set rgb  86  125  253  0'
'set rgb  87  119  253  0'
'set rgb  88  113  254  0'
'set rgb  89  105  254  0'
'set rgb  90  97  254  0'
'set rgb  91  88  254  0'
'set rgb  92  78  254  0'
'set rgb  93  64  254  0'
'set rgb  94  47  255  0'
'set rgb  95  0  255  0'
    _ncolor  = '16   17  18  19  20  0  21  22 23 24 25 26'
    _nheight = '-2.5 -2 -1.5 -1 -0.5 0  0.5 1  1.5 2 2.5'
  endif
return
  'reinit'
  'quit'

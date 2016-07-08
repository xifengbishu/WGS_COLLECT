#!/bin/csh

  set num = 1
  while ( ${num} < 100 )
    set ww = `date +%Y%m%d -d '20051231 '$num' days'`
    #wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120725.splgrbanl.tar
  set num = `expr $num + 1`
  end

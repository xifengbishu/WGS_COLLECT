#!/bin/csh
lftp <<EOF
mget http://soostrc.comet.ucar.edu/data/grib/cfsrr/2011/*/*
mget http://soostrc.comet.ucar.edu/data/grib/cfsrr/2012/*/*
mget http://soostrc.comet.ucar.edu/data/grib/cfsrr/2013/*/*
mget http://soostrc.comet.ucar.edu/data/grib/cfsrr/2014/*/*
mget http://soostrc.comet.ucar.edu/data/grib/cfsrr/2015/*/*
quit
EOF
# http://222.195.136.24/chart/kma/data_keep/2012/2012-07/20120706/sfc3_2012070606.png

#!/bin/bash
#sftp copy file
#date:2012-12-25
#datetime=`date +%Y%m%d`
lftp -u flow,flow sftp://115.236.180.212 << EOF
mput /public/wind_flow/flow/cost_time ./shenzhen
quit
EOF


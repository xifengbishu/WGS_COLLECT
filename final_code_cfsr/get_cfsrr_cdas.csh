#! /bin/csh -f
#
# c-shell script to download selected files from rda.ucar.edu using Wget
# NOTE: if you want to run under a different shell, make sure you change
#       the 'set' commands according to your shell's syntax
# after you save the file, don't forget to make it executable
#   i.e. - "chmod 755 <name_of_script>"
#
# Experienced Wget Users: add additional command-line flags here
#   Use the -r (--recursive) option with care
#   Do NOT use the -b (--background) option - simultaneous file downloads
#       can cause your data access to be blocked
set opts = "-N"
#
# Replace "xxxxxx" with your rda.ucar.edu password on the next uncommented line
# IMPORTANT NOTE:  If your password uses a special character that has special
#                  meaning to csh, you should escape it with a backslash
#                  Example:  set passwd = "my\!password"
set passwd = 'wang314159'
set num_chars = `echo "$passwd" |awk '{print length($0)}'`
if ($num_chars == 0) then
  echo "You need to set your password before you can continue"
  echo "  see the documentation in the script"
  exit
endif
@ num = 1
set newpass = ""
while ($num <= $num_chars)
  set c = `echo "$passwd" |cut -b{$num}-{$num}`
  if ("$c" == "&") then
    set c = "%26";
  else
    if ("$c" == "?") then
      set c = "%3F"
    else
      if ("$c" == "=") then
        set c = "%3D"
      endif
    endif
  endif
  set newpass = "$newpass$c"
  @ num ++
end
set passwd = "$newpass"
#
set cert_opt = ""
# If you get a certificate verification error (version 1.10 or higher),
# uncomment the following line:
#set cert_opt = "--no-check-certificate"
#
if ("$passwd" == "xxxxxx") then
  echo "You need to set your password before you can continue"
  echo "  see the documentation in the script"
  exit
endif
#
# authenticate - NOTE: You should only execute this command ONE TIME.
# Executing this command for every data file you download may cause
# your download privileges to be suspended.
wget $cert_opt -O auth_status.rda.ucar.edu --save-cookies auth.rda.ucar.edu.$$ --post-data="email=liangxiao693@gmail.com&passwd=$passwd&action=login" https://rda.ucar.edu/cgi-bin/login
#
# download the file(s)
# NOTE:  if you get 403 Forbidden errors when downloading the data files, check
#        the contents of the file 'auth_status.rda.ucar.edu'
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110101-20110105.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110106-20110110.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110111-20110115.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110116-20110120.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110121-20110125.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110126-20110131.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110201-20110205.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110206-20110210.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110211-20110215.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110216-20110220.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110221-20110225.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110226-20110228.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110301-20110305.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110306-20110310.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110311-20110315.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110316-20110320.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110321-20110325.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/splanl.gdas.20110326-20110331.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110401.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110402.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110403.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110404.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110405.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110406.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110407.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110408.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110409.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110410.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110411.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110412.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110413.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110414.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110415.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110416.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110417.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110418.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110419.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110420.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110421.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110422.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110423.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110424.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110425.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110426.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110427.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110428.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110429.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110430.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110501.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110502.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110503.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110504.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110505.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110506.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110507.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110508.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110509.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110510.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110511.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110512.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110513.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110514.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110515.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110516.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110517.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110518.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110519.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110520.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110521.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110522.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110523.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110524.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110525.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110526.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110527.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110528.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110529.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110530.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110531.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110601.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110602.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110603.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110604.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110605.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110606.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110607.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110608.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110609.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110610.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110611.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110612.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110613.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110614.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110615.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110616.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110617.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110618.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110619.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110620.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110621.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110622.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110623.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110624.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110625.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110626.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110627.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110628.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110629.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110630.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110701.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110702.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110703.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110704.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110705.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110706.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110707.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110708.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110709.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110710.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110711.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110712.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110713.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110714.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110715.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110716.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110717.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110718.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110719.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110720.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110721.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110722.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110723.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110724.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110725.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110726.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110727.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110728.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110729.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110730.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110731.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110801.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110802.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110803.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110804.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110805.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110806.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110807.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110808.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110809.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110810.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110811.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110812.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110813.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110814.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110815.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110816.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110817.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110818.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110819.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110820.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110821.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110822.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110823.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110824.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110825.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110826.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110827.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110828.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110829.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110830.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110831.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110901.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110902.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110903.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110904.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110905.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110906.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110907.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110908.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110909.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110910.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110911.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110912.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110913.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110914.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110915.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110916.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110917.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110918.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110919.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110920.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110921.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110922.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110923.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110924.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110925.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110926.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110927.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110928.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110929.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20110930.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111001.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111002.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111003.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111004.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111005.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111006.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111007.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111008.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111009.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111010.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111011.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111012.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111013.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111014.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111015.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111016.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111017.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111018.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111019.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111020.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111021.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111022.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111023.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111024.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111025.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111026.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111027.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111028.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111029.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111030.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111031.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111101.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111102.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111103.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111104.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111105.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111106.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111107.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111108.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111109.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111110.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111111.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111112.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111113.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111114.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111115.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111116.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111117.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111118.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111119.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111120.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111121.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111122.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111123.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111124.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111125.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111126.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111127.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111128.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111129.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111130.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111201.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111202.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111203.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111204.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111205.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111206.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111207.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111208.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111209.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111210.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111211.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111212.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111213.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111214.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111215.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111216.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111217.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111218.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111219.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111220.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111221.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111222.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111223.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111224.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111225.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111226.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111227.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111228.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111229.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111230.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2011/cdas1.20111231.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120101.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120102.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120103.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120104.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120105.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120106.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120107.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120108.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120109.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120110.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120111.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120112.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120113.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120114.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120115.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120116.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120117.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120118.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120119.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120120.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120121.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120122.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120123.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120124.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120125.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120126.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120127.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120128.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120129.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120130.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120131.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120201.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120202.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120203.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120204.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120205.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120206.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120207.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120208.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120209.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120210.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120211.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120212.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120213.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120214.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120215.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120216.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120217.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120218.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120219.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120220.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120221.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120222.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120223.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120224.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120225.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120226.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120227.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120228.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120229.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120301.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120302.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120303.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120304.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120305.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120306.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120307.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120308.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120309.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120310.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120311.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120312.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120313.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120314.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120315.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120316.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120317.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120318.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120319.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120320.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120321.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120322.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120323.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120324.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120325.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120326.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120327.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120328.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120329.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120330.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120331.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120401.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120402.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120403.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120404.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120405.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120406.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120407.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120408.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120409.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120410.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120411.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120412.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120413.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120414.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120415.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120416.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120417.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120418.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120419.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120420.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120421.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120422.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120423.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120424.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120425.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120426.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120427.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120428.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120429.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120430.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120501.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120502.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120503.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120504.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120505.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120506.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120507.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120508.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120509.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120510.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120511.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120512.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120513.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120514.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120515.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120516.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120517.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120518.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120519.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120520.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120521.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120522.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120523.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120524.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120525.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120526.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120527.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120528.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120529.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120530.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120531.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120601.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120602.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120603.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120604.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120605.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120606.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120607.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120608.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120609.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120610.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120611.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120612.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120613.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120614.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120615.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120616.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120617.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120618.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120619.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120620.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120621.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120622.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120623.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120624.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120625.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120626.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120627.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120628.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120629.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120630.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120701.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120702.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120703.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120704.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120705.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120706.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120707.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120708.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120709.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120710.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120711.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120712.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120713.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120714.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120715.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120716.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120717.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120718.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120719.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120720.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120721.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120722.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120723.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120724.splgrbanl.tar
wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds094.0/2012/cdas1.20120725.splgrbanl.tar
#
# clean up
rm auth.rda.ucar.edu.$$ auth_status.rda.ucar.edu

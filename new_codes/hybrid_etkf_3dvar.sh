#!/bin/sh
# 
# --- Purpose: 
# ---   Run Hybrid-Etkf-3dvar !
# ----------------------------------------------------------------
# --- History:
# ---    1: 07-08 Jul 2010, GAO Shanhong
# ---       originally created
# ---
# ---       hybrid-3dvar at single time
# ---
# ---    2: 09-11 Aug 2010, GAO Shanhong
# ---       cycling hybrid-3dvar, WRFDA-V3.2
# ---
# ---    3: 20-21 Aug 2010, GAO Shanhong
# ---       cycling hybrid-3dvar, WRFDA-V3.2.1
# ---
# ---    4: 07-09 Sep 2010, GAO Shanhong
# ---       cycling etkf-hybrid-3dvar
# ---
# ---    5: 10-11 Sep 2010, Laoshan campus.
# ---       radar assimilation.
# ---
# ---    6: 13-14 Sep 2010, Laoshan-Yushan.
# ---       use randomcv to produce ensembles for
# ---       the first cycle instead of time-lagged
# ---       forecasts (prepared-ensemble).
# ---
# ---    7: 16 Sep 2010, Yushan campus.
# ---       produce ensemble wrfbdy_d01 files!
# ---
# ---    8: 17 Sep 2010, Yushan campus.
# ---       Use filtered-obs instead of ob.ascii
# ---
# ---    9: 18 Sep 2010, Yushan campus.    
# ---       The result from Hybrid-3DVAR should be
# ---       rewritten by wrf.exe before it is used
# ---        by ETKF !                     
# ---       I do not know the real reason, but it
# ---       must be done for cycling Hybrid-ETKF-3DVAR!
# ---
# ---   10: 22-23 Sep 2010, Yushan campus. 
# ---       add choice to update ensemble member by hybrid
# ---       instead of ETKF !
# ---       This is called cycling-hybrid-3dvar by me.
# ---
# ---   11: 20 Nov 2010, Yushan campus.
# ---       Understand the meaning of nout, naccumt1 and naccumt2.
# ---       add anal_type!
# ---
# ---   12: 23 Nov 2010, Yushan campus.
# ---       add ics_from_previous and ini_etkf_way
# ---
# ---   13: 17 Apr 2011,  Yushan campus.
# ---       for forecast_type='all_fcst'
# ---       add the following line:
# ---       "mv etkf_hybrid_result_${out_time} etkf_hybrid_result_${out_time}_ensemble"
# ---
# ---   14: 29 May 2011, Yushan campus.
# ---       We can tune the len_scales of CV5.
# ---
# ---   15: 21 Jul 2011, Yushan campus.
# ---       Modify the global variable "START_DATE" and "SIMULATION_START_DATE"
# ---       in the files etkf_output.e?? for WRF run of the next cycle.
# ---       NCO should be installed.
# ---       24 Jul 2011, Yushan campus.
# ---       if_put_seed=.true. / .false. manually?
# ---
# ---   16: 03 Jan 2012, Yushan campus.
# ---       add mpi_opt and maxcpu_node options.
# ---
# ---   17: 29 Jan 2012, Yushan campus.
# ---       convert this script from csh to sh.
# ---
# ---   18: 02 Feb 2012, Yushan campus.
# ---       a) re-run da_wrfvar.exe is needed for machine with multiple-nodes
# ---       b) add function choose_obs_type to close some obs_types in namelist.input
# ---          according to the informaion in ob.ascii file
# ---
# ---   19: 05 Feb 2012, Yushan campus.
# ---       a) check again, please use ifort compiler if ens_member >= 64.
# ---       b) print more information for checking
# ---       c) if analysis_type=randomcv, gen_be_etkf.exe is not needed to run, 
# ---          because error will happen if it runs without any obsvervation for intel compiler. 
# ---     
# ---   20: 19 Feb 2012, Yushan campus.
# ---       correct a potential big bug on defining "e_num" during generating ob_etkf.e0*
# ---
# ---   21: 03 Jul 2012, Yushan campus.
# ---        change maxcpu_node to ncpu_ob_in
# ---
# ---   22: 25 Jul 2012, Yushan campus.
# ---       correct a bug on updating wrfbdy_d01 for members.
# ---       See lines beginning with the line of "25 Jul 2012"
# ---
# ---   23: 11 Sep 2012, Yushan campus.
# ---       force max_ext_its = 1, if ramdomcv and verify are used. 
# ---
# ---   24: 23 Dec 2012, Yushan campus.
# ---       add the option "alpha_vertloc"
# ---
# ---   25: 13 Jan 2013, Yushan campus.
# ---       add options "if_speedup_obetkf"
# -------------------------------------------------------------------------------------

 # --- increase the default limit
 ulimit -s unlimited
 #ulimit -l unlimited

 # --- function
 function choose_obs_type ( )
 {
   # --- Purpose:
   # ---   Read information from ob.ascii, then close obs_type in namlist.input.
   # ---
   # --- History:
   # ---  1) created by GAO Shanhong, 02 Feb 2012.
   # ---
   # ---
   namelist_file=$1
   step_number=$2
   #
   if [ ! -e namelist.input ] || [ ! -e ob.ascii ] ; then
      echo ''
      echo ' No this file : namelist.input / ob.ascii.'
      echo ' No choose_obs_type will be done!'
      echo ''
      return
   fi
   #
   # --- number from 0-22
   obs_val=( 0 0 0 0 0 0 0 0 0 0 0 0 \
             0 0 0 0 0 0 0 0 0 0 0   )
   #  
   # --- obs_type is extrated from the namelist.input file
   # ---         1          2         3        4         5             6      7
   obs_type=( synopobs    metarobs  shipsobs buoyobs  bogusobs     soundobs amdarobs    \
              airepobs    tamdarobs pilotobs satemobs geoamvobs    gpspwobs gpsztdobs   \
              gpsrefobs   gpsepobs  ssmt1obs ssmt2obs polaramvobs  qscatobs profilerobs \
              airsretobs  other )
   #
   # --- get values of obs_val from the ob.ascii file
   # --- for example:
   # ---   1               2               3               4               5               6
   # --- 1 SYNOP =   1501, METAR =      0, SHIP  =     34, BUOY  =      0, BOGUS =      0, TEMP  =     99,
   # --- 2 AMDAR =    112, AIREP =   1988, TAMDAR=      0, PILOT =      0, SATEM =      0, SATOB =     54,
   # --- 3 GPSPW =      0, GPSZD =      0, GPSRF =      0, GPSEP =      0, SSMT1 =      0, SSMT2 =      0,
   # --- 4 TOVS  =      0, QSCAT =      0, PROFL =     31, AIRSR =      0, OTHER =      0,
   # --------------------------
   # --- (4 rows) X (6 columns)
   # ---
   rows_num=4
   cols_num=6
   onum=1
   obs_onum=0
   while [ $onum -le $rows_num ]
   do
      onum_line=`expr $onum + 1`
      if [ $onum -lt $rows_num ] ; then
        col_num_t=$cols_num
      else
        col_num_t=`expr $cols_num - 1`
      fi
      col_num=1
      while [ $col_num -le $col_num_t ]
      do
        #echo `sed -n ${onum_line}p ob.ascii | awk -F, '{print $'${col_num}'}'`
        temp_obs_val=`sed -n ${onum_line}p ob.ascii | awk -F, '{print $'${col_num}'}' | awk '{print $NF}'`
        obs_val[$obs_onum]=$temp_obs_val
        obs_onum=`expr $obs_onum + 1`
        #
        col_num=`expr $col_num + 1`
      done
      #
      onum=`expr $onum + 1`
   done
   #
   # --- do close of "obs_type" in the namelist.input
   cp -f ${namelist_file} namelist.input.obstmp
   obs_onum=-1
   while [ $obs_onum -le 21 ]
   do
     obs_onum=`expr $obs_onum + 1`
     #echo $obs_onum'  '${obs_type[$obs_onum]}
     if [ ${obs_val[$obs_onum]} -eq 0 ] ; then
        # --- buoyobs
        if [ $obs_onum -eq 3 ] ; then
           sed 's/use_'${obs_type[$obs_onum]}'/use_'${obs_type[$obs_onum]}'     = .F.,    \!/g' \
                namelist.input.obstmp > .obstmp
           mv -f .obstmp namelist.input.obstmp
           continue
        fi
        # --- psrefobs
        if [ $obs_onum -eq 14 ] ; then
           sed 's/use_'${obs_type[$obs_onum]}'/use_'${obs_type[$obs_onum]}'   = .F.,    \!/g' \
                namelist.input.obstmp > .obstmp
           mv -f .obstmp namelist.input.obstmp
           continue
        fi
        # --- polaramvobs, profilerobs
        if [ $obs_onum -eq 18 ] || [ $obs_onum -eq 20 ] ; then
           sed 's/use_'${obs_type[$obs_onum]}'/use_'${obs_type[$obs_onum]}' = .F.,    \!/g' \
                namelist.input.obstmp > .obstmp
           mv -f .obstmp namelist.input.obstmp
           continue
        fi
        # --- airsretobs
        if [ $obs_onum -eq 21 ] ; then
           sed 's/use_'${obs_type[$obs_onum]}'/use_'${obs_type[$obs_onum]}'       = .F.,    \!/g' \
                namelist.input.obstmp > .obstmp
           mv -f .obstmp namelist.input.obstmp
           continue
        fi
        sed 's/use_'${obs_type[$obs_onum]}'/use_'${obs_type[$obs_onum]}'    = .F.,    \!/g' \
            namelist.input.obstmp > .obstmp
        mv -f .obstmp namelist.input.obstmp
     fi
   done
   #
   # --- rename namelist.input.obstmp
   #
   rm -f namelist.input
   mv -f namelist.input.obstmp namelist.input
   cp -f namelist.input namelist.input_${step_number}
   #
   return
 }

 echo ''
 echo ' ========================================='
 echo ' === Welcome to use Hybrid-ETKF-3DVAR! ==='
 echo ' ===                                   ==='
 echo ' === GAO Shanhong, 08 Jul 2010.        ==='
 echo ' === Thanks to Xuguang WANG!           ==='
 echo ' ========================================='

 # ==== Step 1: settings
 echo ' --- Step-1: settings ' 

 # --- Where is ensemble forecast result ?
 # --- They are like YYYYMMDDHH.e00x 
 # ---
 ensemble_dir=${1}
 #
 # --- how many members ?
 # ---
 num_members=${2}

 # --- When is the analysis time ?
 # --- It is like YYYYMMDDHH
 # ---
 #set analysis_time=2006030512
 analysis_time=${3}

 # --- Where are the be, obs and boundary files ?
 # ---
 be_file=${4}

 # --- assimilation satellite radiance data?
 # --- if_radiance  [ yes, no )
 if_radiance=${5}
 #
 if_assimilate=${6}


 # --- Which mpich software ?
 # --- How many numtiles ?
 # --- For machine Typhoon: mpich2  (mpd needed)
 # --- For SGI machine    : openmpi (mpd not needed)
 # ---   Penryn  CPU (8 cores) : numtiles=8
 # ---   Nehalem CPU (8 cores) : numtiles=2-4 ?
 # ---   SGI CPU(...)          : numtiles=1
 # ---
 which_mpi=${7}
 numtiles=${8}
 ncpu_wrfda=${9}

 # --- which cycling step ?
 cycle_step=${10} 

 # --- where is wrfbdy_d01 ?
 bdy_dir=${11}

 # --- mark of final step !
 # --- 0: not final ; 1: final
 mark=${12}

 # --- control ETKF-Hybrid
 nv=${13}
 cv=${14}
 naccumt1=${15}
 naccumt2=${16}
 nout=${17}
 tainflatinput=${18}
 rhoinput=${19}
 if_radar=${21}
 if_gts=${22}
 update_ens_mean=${20}
 update_mean_way=${23}
 cv_number=${24}
 produce_ens=${25}
 ens_method=${26}
 filtered_obs=${27}
 cycle_intv=${28}
 rewrite_mean=${29}
 update_anal_way=${30}
 run_hour=${31}
 max_dom=${32}
 anal_type=${33}
 ics_from_previous=${34}
 ini_etkf_way=${35}
 len_scale_cv5=${36}
 if_put_seed=${37}
 pert_init_ens=${38}
 gts_obs=${39}
 mpi_opt_new=${40}
 ncpu_ob_in=${41}
 alpha_vertloc=${42}
 if_speedup_obetkf=${43}

 # ================================================
 # ====    Here, End of Your Modifications!    ====
 # ================================================
 

 # ==== Step 2: calculate ensemble mean and perturbations 
 echo ' --- Step-2: calculate ensemble mean and perturbations ' 
 
 # --- 2.0 re-value mpi_opt
 echo ''
 echo ' --- step-2.0  re-value mpi_opt'
 mpi_opt=`echo ${mpi_opt_new} | sed 's/#/ /g'`

 # --- permission
 # --- the following *_ip and if_check_rights will
 # --- be replaced by prepare_my_case.sh.
 # ---
 # ---  Do not touch this part.
 # ---
 machine_typhoon="typhoon_ip"
 machine_tornado="tornado_ip"
 machine_seafog="seafog_ip"
 machine_other="other_ip"
 machine_other1="other_ip1"
 machine_other2="other_ip2"
 machine_other3="other_ip3"
 machine_other4="other_ip4"
 machine_other5="other_ip5"
 #
 check_rights=if_check_rights
 if [ ${check_rights} == 'yes' ] ; then
    #
    # --- Dawning machine
    #ip_adr=`ssh node12 /sbin/ifconfig | sed -n 1p | awk '{print $NF}'`
    #
    #ip_adr=`/sbin/ifconfig | sed -n 1p | awk '{print $NF}'`
    if [ -e ../run_wps/.ip_mac ] ; then
      ip_adr=`sed -n 1p ../run_wps/.ip_mac | awk '{print $NF}'`
    else
      ip_adr=`/sbin/ifconfig | sed -n 1p | awk '{print $NF}'`
    fi
    #
    if [ ${ip_adr} != ${machine_typhoon} ] && \
       [ ${ip_adr} != ${machine_tornado} ] && \
       [ ${ip_adr} != ${machine_seafog}  ] && \
       [ ${ip_adr} != ${machine_other1}  ] && \
       [ ${ip_adr} != ${machine_other2}  ] && \
       [ ${ip_adr} != ${machine_other3}  ] && \
       [ ${ip_adr} != ${machine_other4}  ] && \
       [ ${ip_adr} != ${machine_other5}  ] && \
       [ ${ip_adr} != ${machine_other}   ] ; then
       echo ''
       echo ' Error: '
       echo '   This script is NOT permitted run on this machine!'
       echo ' ======================================================'
       echo ''
       exit
    fi
 fi

 # --- 2.1 get yy, mm, dd and hh
 echo ''
 echo ' --- step-2.1  Date-time settings'
 yy=`echo ${analysis_time} | awk '{print substr($1,1,4)}'`
 mm=`echo ${analysis_time} | awk '{print substr($1,5,2)}'`
 dd=`echo ${analysis_time} | awk '{print substr($1,7,2)}'`
 hh=`echo ${analysis_time} | awk '{print substr($1,9,2)}'`
 out_time=${yy}-${mm}-${dd}_${hh}

 # --- 2.2 link ensemble members
 # --- ensemble_prepared for first step or since the second step
 echo ''
 echo ' --- step-2.2  link ensemble members'
 temp_dir=${analysis_time}
 if [ -d ${temp_dir} ] ; then
   rm -rf ${temp_dir}
 fi
 mkdir ${temp_dir}
 #
 if [ ${produce_ens} == no ] ; then
   mkdir -p ${temp_dir}/ep
   cd ${temp_dir}/ep
   num=1
   while [ ${num} -le ${num_members} ]
   do
     if [ ${num} -lt 10 ] ; then
       e_num=00${num}
     elif [ ${num} -lt 100 ] ; then
       e_num=0${num}
     else
       e_num=${num}
     fi
     member_file=${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00
     ln -sf ../../${member_file} wrfout_d01_${out_time}:00:00.e${e_num}
     # --- next member
     num=`expr ${num} + 1 `
   done
   # --- go back
   cd ../..
 fi
 
 # --- 2.3 randomcv for the first step or single-etkf_3dvar 
 # ---     3DVAR with analysis_type='randomcv', seed_array1 and seed_array2
 #
 # --- 2.3.1 link observations: ob.ascii, ob.ssmi and *.bufr
 # ---       for some next steps which require obsvervations
 echo ''
 echo ' --- step-2.3  randomcv for the first step'
 #
 if [ -e ob.ascii ] ; then
   rm -f ob.ascii
 fi
 if [ -e ob.ssmi ] ; then
   rm -f ob.ssmi
 fi
 #
 if [ ${if_gts} == yes ] ; then
   if_ssmi=0
   for obs in `ls ../obs_be_files/${gts_obs}/3dvar_step${cycle_step}_obs_out/obs_*`
   do
     obs_type=`basename  ${obs} | sed 's/_/ /g' | awk '{print $2}'`
     if [ ${obs_type} == 'gts' ] ; then
       ln -sf ${obs} ob.ascii
     else
       ln -sf ${obs} ob.${obs_type}
       if_ssmi=1
     fi
   done
 else
   if_ssmi=0
 fi
 # --- do not assimilate any observations!
 if [ ${if_assimilate} == 0 ] ; then
   if [ -e ob.ascii ] ; then
     rm -f ob.ascii
   fi
   if [ -e ob.ssmi ] ; then
     rm -f ob.ssmi
   fi
   #
   if_ssmi=0
   if_radiance=no
 fi
 # --- link radiance obs bufr data
 # --- do clean at first
 rm -f *.bufr > bufr.msg
 rm -f bufr.msg
 # --- then link
 if [ ${if_radiance} == yes ] ; then
   for bufr_obs in `ls ../obs_be_files/radiance_obs/step${cycle_step}/*.bufr`
   do
     ln -fs ${bufr_obs} .
   done
 fi
 #
 # --- link radar obs
 # --- do clean at first
 rm -f ob.radar > radar.msg
 rm -f radar.msg
 # --- then do link
 if [ ${if_radar} == yes ] ; then
   ln -fs ${RADAR_obs}/step${cycle_step}/* ob.radar
 fi
 #
 # ---link be.dat
 if [ ${cv_number} -eq 3 ] ; then
   ln -sf be.dat.cv3 be.dat
 else
   ln -sf ../obs_be_files/${be_file} be.dat
 fi
 #
 # --- 2.3.2 procude ensemble for the first cycle
 if [ ${produce_ens} == yes ] ; then
   time1=`date +%s`
   #
   if [ -d ${ensemble_dir} ] ; then
     rm -rf ${ensemble_dir}
   fi
   mkdir ${ensemble_dir}
   #
   num=1
   while  [ ${num} -le ${num_members} ]
   do
     if [ ${num} -lt 10 ] ; then
       e_num=00${num}
     elif [ $num -lt 100 ] ; then
       e_num=0${num}
     else
       e_num=${num}
     fi
     #
     cycle_date=${out_time}:00:00  
     #
     # --- They are too large for integer limit with kind=4 !
     # --- However, the generated random ensemble is OK. I do not know why.
     SEED_ARRAY1_value=`./da_advance_time.exe ${cycle_date} 0 -f hhddmmyycc` 
     SEED_ARRAY2_value=`echo ${num} \* 100000 | bc -l`
     #
     # ---
     # --- Notice: 
     # ---         25-26 Jul 2011, Home. Here, big BUG in this scritpt!
     # ---         WRFDA/var/da/da_define_structures/da_random_seed.inc
     # --- (1)
     # ---     seed_array(1)=seed_array1
     # ---     seed_array(2)=seed_array2 * seed_array1 + myproc*10000000
     # ---     seed_array1 <--- SEED_ARRAY1_value
     # ---     seed_array2 <--- SEED_ARRAY2_value
     # ---     pgf90 -i4 da_random_seed.f90 -o ....
     # ---     We should keep seed_array(1) and seed_array(2) < 1,000,000,000
     # ---
     # --- (2) I modified the code of da_random_seed.inc, let:
     # ---     seed_array(1)=seed_array1
     # ---     seed_array(2)=seed_array2
     # ---
     #set random_hr=`expr $num \* 1000`
     #set SEED_ARRAY1_value=`./da_advance_time.exe $cycle_date $random_hr -f ccyymmddhh`
     #set SEED_ARRAY2_value=`./da_advance_time.exe $cycle_date $random_hr -f hhddmmyycc`
     #set SEED_ARRAY1_value=2007071812
     #set SEED_ARRAY2_value=83383040
     #
     ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01 fg
     cp -f cycling_hybrid_3dvar_namelists/namelist.input_step${cycle_step} namelist.input
     #
     # --- num_member=0, analysis_type=randomcv
     sed 's/num_members/0/g'  namelist.input             | \
     sed 's/'${anal_type}'/randomcv/g'                   | \
     sed 's/len_scale/'${len_scale_cv5}'/g'              | \
     sed 's/PUT_RAND_SEED_value/'${if_put_seed}'/g'      | \
     sed 's/SEED_ARRAY1_value/'${SEED_ARRAY1_value}'/g'  | \
     sed 's/SEED_ARRAY2_value/'${SEED_ARRAY2_value}'/g'  | \
     sed 's/max_ext_its/max_ext_its = 1, \! /g' > namelist.input_randomcv
     mv namelist.input_randomcv  namelist.input
     #
     # --- $if_ssmi == 0 and ${if_radiance} == no
     if [ $if_ssmi == 0 ] ; then
       sed "s/truE/falsE/g" namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
     fi
     if [ ${if_radiance} == no ] ; then
       sed 's/TRUE/FALSE/g' namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
     fi
     # 
     # --- clean
     if [ -e wrfvar_output ] ; then
       rm -f wrfvar_output
     fi
     if [ -e rsl.out.0000 ] ; then
       rm -f rsl.*
     fi
     # --- run da_wrfvar.exe
     ncpu_perb=${ncpu_wrfda}
     #if [ ${ncpu_perb} -ge ${maxcpu_node} ] ; then
     #  ncpu_perb= ${maxcpu_node}
     #fi
     if [ ${which_mpi} == 'openmpi' ] ; then
       mpirun -np ${ncpu_perb} ${mpi_opt} da_wrfvar.exe
     fi
     if [ ${which_mpi} == 'mpich2' ] ; then
       mpirun -l -n ${ncpu_perb} da_wrfvar.exe < /dev/null 
     fi
     #
     # --- check if da_wrfvar.exe run ok or not
     # --- 03 Feb 2012, Home.
     # ---
     rerun_num=0
     while [ ${rerun_num} -lt 10 ]
     do
       if [ -e wrfvar_output ] ; then
         break
       else
         # --- rerun da_wrfvar.exe
         echo '  I have to re-run da_wrfvar.exe! '
         echo '  re-run number is '${rerun_num}
         if [ ${which_mpi} == 'openmpi' ] ; then
           mpirun -np ${ncpu_wrfda} ${mpi_opt} da_wrfvar.exe
         fi
         if [ ${which_mpi} == 'mpich2' ] ; then
           mpirun -l -n ${ncpu_wrfda} da_wrfvar.exe < /dev/null
         fi
       fi
       rerun_num=`expr ${rerun_num} + 1`
     done
     #
     # --- keep rsl.out.0000 which including random ensemble information
     if [ -e rsl.out.0000 ] ; then
       mv rsl.out.0000 random_ensemble_no${num}.msg
     fi
     #
     # --- keep the result under ${ensemble_dir}
     mkdir ${ensemble_dir}/${analysis_time}.e${e_num}  
     mv wrfvar_output ${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00
     #
     # --- do link under ${temp_dir}
     mkdir -p ${temp_dir}/ep
     cd ${temp_dir}/ep
     member_file=${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00
     ln -sf ../../${member_file} wrfout_d01_${out_time}:00:00.e${e_num}
     cd ../..
     #
     # --- next member
     num=`expr ${num} + 1 `
   done
   time2=`date +%s`
   time_used=`expr ${time2} - ${time1}`
   echo '            . procude ensemble for the first cycle ('${time_used}'s)' >> ../my_cost_time.msg
   if [ ${pert_init_ens} == yes ] ; then
     mkdir random_ensemble_msg
     mv random_ensemble_no*.msg random_ensemble_msg
     mv random_ensemble_msg ${ensemble_dir} 
     exit
   fi
   if [ ${ics_from_previous} == yes ] ; then
     echo '              (ICs from previous fcst/3DVAR result)' >> ../my_cost_time.msg
   fi
 fi
 #
 # --- 2.3.3 produce boundary conditions of the ensemble 
 # ---       No matter "ensemble" or "randomcv", then Boundary Conditions
 # ---       of ensembles should be updated !
 # ---
 num=1
 while  [ ${num} -le ${num_members} ]
 do
   if [ ${num} -lt 10 ] ; then
     e_num=00${num}
   elif [ ${num} -lt 100 ] ; then
     e_num=0${num}
   else
     e_num=${num}
   fi
   #
   # --- clean first
   if [ -e wrfvar_output ] ; then
     rm -f wrfvar_output
   fi
   if [ -e fg ] ; then
     rm -f fg
   fi
   if [ -e wrfbdy_d01 ] ; then
     rm -f wrfbdy_d01
   fi
   # --- do link and copy
   ln -sf ${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00 wrfvar_output
   if [ -e ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc ] ; then
     ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc fg
   else
     ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01 fg
   fi
   cp -f  ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfbdy_d01   wrfbdy_d01
   if [ ${ens_method} == 'ensemble' ] ; then
     cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling       parame.in
   fi
   if [ ${ens_method} == 'randomcv' ] ; then
     if [ ${produce_ens} == yes ] ; then
       cp -f  cycling_hybrid_3dvar_namelists/parame.in_no_cycling  parame.in
       if [ ${ics_from_previous} == yes ] ; then
         cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling   parame.in
       fi
     else
       cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling     parame.in
     fi
   fi
   #
   # --- run ./da_update_bc.exe
   ./da_update_bc.exe > update_bc.msg
   mv -f wrfbdy_d01 ${ensemble_dir}/${analysis_time}.e${e_num}/
   rm -f update_bc.msg
   rm -f parame.in wrfbdy_d01 fg wrfvar_output
   #
   # --- next member
   num=`expr ${num} + 1 `
 done
 #
 # --- 2.3.4 initialize ensemble mean and variance with first member
 cp -r ${ensemble_dir}/${analysis_time}.e001/* ${temp_dir}/
 cd ${temp_dir}
 cp wrfout_d01_${out_time}:00:00 wrfout_d01_${out_time}:00:00.vari
 cd ..

 # --- 2.4 generate gen_be_ensmean_nl.nl
 # ---
 # ---     Enter {temp_dir}/ep
 echo ''
 echo ' --- step-2.4 create gen_be_ensmean_nl.nl'
 time1=`date +%s`
 cd ${temp_dir}/ep
 cat > gen_be_ensmean_nl.nl << EOF
 &gen_be_ensmean_nl
  directory='../',
  filename='wrfout_d01_${out_time}:00:00',
  num_members=${num_members},
  nv=${nv}
  cv=${cv}
 /
EOF

 # --- 2.5 run gen_be_ensmean.exe
 echo ''
 echo ' --- step-2.5 run ./gen_be_ensmean.exe'
 ln -sf ../../gen_be_ensmean.exe .
 ./gen_be_ensmean.exe

 # --- 2.6 run gen_be_ep2.exe
 echo ''
 echo ' --- step-2.6 run ./gen_be_ep2.exe'
 ln -sf ../../gen_be_ep2.exe .
 ./gen_be_ep2.exe ${num_members} wrfout_d01_${out_time}:00:00
 #
 # --- 23 Dec 2012.
 #
 if [ ${alpha_vertloc} == ".true." ] ; then
    ln -sf ../../gen_be_vertloc.exe  .
    #
    # --- get vertical layers
    ln -sf ../wrfout_d01_${out_time}:00:00 .wrf_vertical
    vertical_num=`ncdump -h .wrf_vertical | grep -i "bottom_top_stag = " | awk '{print $3}'` 
    #
    # --- do clean : delete the previous be.vertloc.dat
    if [ -e be.vertloc.dat ] ; then
       rm -f be.vertloc.dat
    fi
    ./gen_be_vertloc.exe  ${vertical_num}
    # 
    # --- copy be.vertloc.dat under run_hybrid
    cp be.vertloc.dat ../../
 fi
 #
 time2=`date +%s`
 time_used=`expr ${time2} - ${time1}`
 if [ ${ens_method} == ensemble ] && [ ${cycle_step} == 1 ] ; then
   echo '            . ensemble from ensemble fcst result' >> ../../../my_cost_time.msg
 fi
 echo '            . ensemble mean and perturbations ('${time_used}'s)' >> ../../../my_cost_time.msg
 cd ../..


 # === Which way to update ensemble member analysis ? 
 if [ ${update_anal_way} == hybrid ] ; then
   #
   # --- for update_anal_way = hybrid, bad method!
   echo '  updating member analysis by hybrid instead of etkf!'
   #
   time1=`date +%s`
   # --- run da_wrfvar.exe in hybrid mode
   # --- start LOOP for every member
   # --- mark=1 means the final step
   if [ ${mark} == 1 ] ; then
     num_members=${mark}
   fi
   #
   if [ -e ep ] ; then
     rm -f ep
   fi
   if [ ${update_mean_way} == 'hybrid' ] ; then
     ln -sf ${temp_dir}/ep .
     ens_num=${num_members}
   fi
   if [ ${update_mean_way} == '3dvar' ] ; then
     ens_num=0
   fi
   #
   if [ -d etkf ] ; then
     rm -rf etkf
   fi
   mkdir etkf
   #
   num=1
   while  [ ${num} -le ${num_members} ]
   do
     echo '   --- run wrfda.exe in hybrid mode, Member No. '${num}
     if [ ${num} -lt 10 ] ; then
       e_num=00${num}
     elif [ ${num} -lt 100 ] ; then
       e_num=0${num}
     else
       e_num=${num}
     fi
     # --- $mark=1 means the final step
     if [ ${mark} == 1 ] ; then
       ln -sf ${temp_dir}/wrfout_d01_${out_time}:00:00 fg
     else
       ln -sf ${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00 fg
     fi
     cp -f cycling_hybrid_3dvar_namelists/namelist.input_step${cycle_step} namelist.input
     #
     # --- choose obs_type
     # --- 02 Feb 2012, Yushan campus.
     choose_obs_type  namelist.input step${cycle_step}
     #
     # --- num_member
     sed 's/num_members/'${ens_num}'/g' namelist.input | \
     sed 's/PUT_RAND_SEED_value/.false./g'             | \
     sed 's/len_scale/'${len_scale_cv5}'/g'            | \
     sed 's/SEED_ARRAY1_value/0/g'                     | \
     sed 's/SEED_ARRAY2_value/0/g'    > namelist.input_hybrid
     mv namelist.input_hybrid  namelist.input
     #
     # --- $if_ssmi == 0 and ${if_radiance} == no
     if [ ${if_ssmi} == 0 ] ; then
       sed "s/truE/false/g" namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
     fi
     if [ ${if_radiance} == no ] ; then
       sed 's/TRUE/false/g' namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
     fi
     #
     # --- clean
     if [ -e wrfvar_output ] ; then
       rm -f wrfvar_output
     fi
     # --- run da_wrfvar.exe
     if [ ${which_mpi} == 'openmpi' ] ; then
       mpirun -np ${ncpu_wrfda} ${mpi_opt} da_wrfvar.exe
     fi
     if [ ${which_mpi} == 'mpich2' ] ; then
       mpirun -l -n ${ncpu_wrfda} da_wrfvar.exe < /dev/null
     fi
     #
     # --- check if da_wrfvar.exe run ok or not
     # --- 03 Feb 2012, Home.
     # ---
     rerun_num=0
     while [ ${rerun_num} -lt 10 ]
     do
       if [ -e wrfvar_output ] ; then
         break
       else
         # --- rerun da_wrfvar.exe
         echo '  I have to re-run da_wrfvar.exe! '
         echo '  re-run number is '${rerun_num}
         if [ ${which_mpi} == 'openmpi' ] ; then
           mpirun -np ${ncpu_wrfda} ${mpi_opt} da_wrfvar.exe
         fi
         if [ ${which_mpi} == 'mpich2' ] ; then
           mpirun -l -n ${ncpu_wrfda} da_wrfvar.exe < /dev/null
         fi
       fi
       rerun_num=`expr ${rerun_num} + 1`
     done
     #
     # --- save the result
     if [ -e wrfvar_output ] ; then
       if [ ${mark} == 1 ] ; then
         mv -f wrfvar_output ${temp_dir}/wrfout_d01_${out_time}:00:00_update
       else
         mv -f wrfvar_output  etkf/etkf_output.e${e_num}
       fi
     else
       echo '    '
       echo '    Error in running wrfda.exe in hybrid mode !'
       echo '    '
       exit
     fi
     # --- next member
     num=`expr ${num} + 1 `
     #
     # --- end LOOP for every member
   done
   # --- let output be with analysis time
   if [ -d etkf_${analysis_time} ] ; then
     rm -rf etkf_${analysis_time}
   fi
   mv etkf etkf_${analysis_time}
   #
   # -- skip etkf process
   time2=`date +%s`
   time_used=`expr ${time2} - ${time1}`
   echo '            . update ensemble member by hybrid-3dvar ('${time_used}'s)' >> ../my_cost_time.msg
 fi

 # ==== update_anal_way = etkf
 # ---
 # --- The content of "update_anal_way = etkf" is divieded into 3 Parts,
 # --- because it is too big, and includes too many if-else-fi blocks.
 # ---
 # --- Part-1
 if [ ${update_anal_way} == 'etkf' ] ; then 
 echo ''
 echo ' --- step-3-Part-1: '
 #
 # ==== Step 3: To perform an Ensemble Transform Kalman Filter (ETKF)
 # ---          rescaling of ensemble forecast perturbations.
 echo ' --- Step-3: rescaling of ensemble forecast perturbations '
 echo '            . run etkf-3dvar '     >> ../my_cost_time.msg

 # --- 3.1 link observations: ob.ascii, ob.ssmi and *.bufr
 # ---     this step is already done by the step 2.4.1

 # --- 3.2 Do Hybrid-3DVAR  [ analysis_type=${anal_type} ] ; with ens_mean
 # ---     ens_mean will be updated by 3DVAR !
 # ---     According to Xuguang Wang, this step should be Hybrid-3DVAR!
 # ---    -----
 # ---     Use filtered_obs instead of ob.ascii. (17 Sep 2010)
 # ---
 time1=`date +%s`
 if [ -e ep ] ; then
   rm -f ep
 fi
 if [ ${update_mean_way} == 'hybrid' ] ; then
   ln -sf ${temp_dir}/ep .  
   ens_num=${num_members}
 fi
 if [ ${update_mean_way} == '3dvar' ] ; then
   ens_num=0
 fi
 # --- the ensemble mean as fg
 ln -sf ${temp_dir}/wrfout_d01_${out_time}:00:00 fg
 cp -f  ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfbdy_d01 .
 cp -f cycling_hybrid_3dvar_namelists/namelist.input_step${cycle_step} namelist.input
 #
 # --- choose obs_type
 # --- 02 Feb 2012, Yushan campus.
 choose_obs_type  namelist.input  step${cycle_step}
 #
 #
 # --- num_member
 sed 's/num_members/'${ens_num}'/g' namelist.input | \
 sed 's/PUT_RAND_SEED_value/.false./g'             | \
 sed 's/len_scale/'${len_scale_cv5}'/g'            | \
 sed 's/SEED_ARRAY1_value/0/g'                     | \
 sed 's/SEED_ARRAY2_value/0/g'    > namelist.input_hybrid
 mv namelist.input_hybrid  namelist.input
 #
 # --- $if_ssmi == 0 and ${if_radiance} == no 
 if [ ${if_ssmi} == 0 ] ; then
   sed "s/truE/false/g" namelist.input > namelist.input.tmp
   mv -f namelist.input.tmp namelist.input
 fi
 if [ ${if_radiance} == no ] ; then
   sed 's/TRUE/false/g' namelist.input > namelist.input.tmp
   mv -f namelist.input.tmp namelist.input
 fi
 #
 # --- clean
 if [ -e wrfvar_output ] ; then
   rm -f wrfvar_output
 fi
 # --- run da_wrfvar.exe
 if [ ${which_mpi} == 'openmpi' ] ; then
   mpirun -np ${ncpu_wrfda} ${mpi_opt} da_wrfvar.exe
 fi
 if [ ${which_mpi} == 'mpich2' ] ; then
   mpirun -l -n ${ncpu_wrfda} da_wrfvar.exe < /dev/null
 fi
 #
 # --- check if da_wrfvar.exe run ok or not
 # --- 02 Feb 2012, Yushan campus.
 # ---
 rerun_num=0
 while [ ${rerun_num} -lt 10 ]
 do
   if [ -e wrfvar_output ] ; then
     break
   else
     # --- rerun da_wrfvar.exe
     echo '  I have to re-run da_wrfvar.exe! '
     echo '  re-run number is '${rerun_num}
     if [ ${which_mpi} == 'openmpi' ] ; then
       mpirun -np ${ncpu_wrfda} ${mpi_opt} da_wrfvar.exe
     fi
     if [ ${which_mpi} == 'mpich2' ] ; then
       mpirun -l -n ${ncpu_wrfda} da_wrfvar.exe < /dev/null
     fi
   fi
   rerun_num=`expr ${rerun_num} + 1`
 done
 #
 mv cost_fn cost_fn_step${cycle_step}
 mv grad_fn grad_fn_step${cycle_step}
 #
 # --- keep the ens_mean for later updating use
 mv -f wrfvar_output ${temp_dir}/wrfout_d01_${out_time}:00:00_update
 #
 # --- Use filtered_obs instead of ob.ascii. (17 Sep 2010)
 if [ ${filtered_obs} == yes ] ; then
   if [ -e ob.ascii ] ; then
     rm -f ob.ascii
     cp -f filtered_obs_01 ob.ascii 
     cp ob.ascii ob.ascii_step${cycle_step}
   fi
 fi
 time2=`date +%s`
 time_used=`expr ${time2} - ${time1}`
 echo '               . hybrid-3dvar ('${anal_type}')   ('${time_used}'s)'     >> ../my_cost_time.msg
 #
 # --- End of Part-1 for "update_anal_way = etkf"
 fi

 # --- 3.3 Create observation files for ETKF
 # ---     This step needs running da_wrfvar.exe with
 # ---     &wrfvar17
 # ---      analysis_type='VERIFY'
 # ---      /
 # ---------------------------------
 #
 # --- Part-2
 #
 if [ ${update_anal_way} == 'etkf' ] ; then
 time1=`date +%s`
 echo ''
 echo ' --- step-3-Part-2: '

 # --- for create an initial random ensemble
 if [ ${gts_obs} == gts_ens ] ; then
    num=1
    while  [ ${num} -le ${num_members} ]
    do
      #
      if [ ${num} -lt 10 ] ; then
        e_num=00${num}
      elif [ ${num} -lt 100 ] ; then
        e_num=0${num}
      else
        e_num=${num}
      fi
      echo 0 > ob.etkf.e${e_num}
      #
      num=`expr $num + 1`
    done
    time2=`date +%s`
    time_used=`expr ${time2} - ${time1}`
    echo '               . ob_etkf.e[num] files    ('${time_used}'s)'   >> ../my_cost_time.msg
 fi    

 # --- for processing ob.etkf.e* in hybrid-etkf-3dvar
 if [ ${gts_obs} != gts_ens ] ; then
    #
    # --- do clean
    #
    if [ -d ep ] ; then
      rm -f ep
    fi
    if [ -e fg ] ; then
      rm -f fg
    fi
    if [ -e wrfbdy_d01 ] ; then
      rm -f wrfbdy_d01
    fi
    if [ -e be.dat ] ; then
      rm -f be.dat
    fi
    if [ ${cv_number} == 3 ] ; then
      ln -sf be.dat.cv3 be.dat
    else
      ln -sf ../obs_be_files/${be_file} be.dat
    fi
    if [ -d .speedup_obetkf ] ; then
       rm -rf .speedup_obetkf
    fi
    if [ -e namelist.input ] ; then
     rm -f namelist.input
    fi
    #
    # --- generate namelist.input
    #
    cp  -f cycling_hybrid_3dvar_namelists/namelist.input_step${cycle_step} namelist.input
    #
    # --- modify analysis_type from ${anal_type} to 'VERIFY' !
    #
    #sed 's/num_members/'${num_members}'/g'    > namelist.input_ob_etkf
    #
    sed 's/'${anal_type}'/VERIFY/g' namelist.input | \
    sed 's/num_members/0/g'                | \
    sed 's/PUT_RAND_SEED_value/.false./g'  | \
    sed 's/len_scale/'${len_scale_cv5}'/g' | \
    sed 's/SEED_ARRAY1_value/0/g'          | \
    sed 's/SEED_ARRAY2_value/0/g'          | \
    sed 's/max_ext_its/max_ext_its = 1, \! /g' > namelist.input_ob_etkf
    mv -f namelist.input_ob_etkf namelist.input
    #
    # --- $if_ssmi == 0 and ${if_radiance} == no
    if [ ${if_ssmi} == 0 ] ; then
       sed "s/use_ssmiretrievalobs/\!use_ssmiretrievalobs/g" namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
    fi
    if [ ${if_radiance} == no ] ; then
       sed "s/TRUE/false/g" namelist.input > namelist.input.tmp
       mv -f namelist.input.tmp namelist.input
    fi
    #
    # --- divide the ensemble into two groups
    # 
    if [ ${if_speedup_obetkf} == yes ] ; then
    #
    half_member=`expr ${num_members} \/ 2` 
    #
    # --- the second-half of .nodefile is used
    total_cpus=`wc -l ../.nodefile | awk '{print $1}'`
    half_cpus=`expr ${total_cpus} \/ 2 + 1`
    sed -n ${half_cpus}','${total_cpus}'p' .nodefile > .nodefile_etkf
    #
    cat > speedup_obetkf.sh << EOF
#!/bin/sh
#    
    mem_beg=`expr ${half_member} + 1`
    mem_end=${num_members}
    g_num=\${mem_beg}
    while [ \${g_num} -le \${mem_end} ]
    do
       if [ \${g_num} -lt 10 ] ; then
          e_num=00\${g_num}
       elif [ \${g_num} -lt 100 ] ; then
          e_num=0\${g_num}
       else
          e_num=\${g_num}
       fi
       #
       if [ \${g_num} -eq \${mem_beg} ] ; then
          ln -s ../namelist.input .
          ln -s ../ob.ascii       .
          ln -s ../da_wrfvar.exe  .
          if [ -e ../ob.ssmi ] ; then
             ln -s ../ob.ssmi     .
          fi
       fi
       ln -sf ../${ensemble_dir}/${analysis_time}.e\${e_num}/wrfout_d01_${out_time}:00:00 fg
       #
       mpirun -np 1 ${mpi_opt} da_wrfvar.exe    
       #
       if [ -e ob.etkf.000 ] ; then
          etkf_file=ob.etkf.000
       fi
       if [ -e ob.etkf.0000 ] ; then
          etkf_file=ob.etkf.0000
       fi
       obs_num=\`wc -l \${etkf_file} | sed -n 1p | awk '{print \$1}'\`
       sed "1 i\\\\\${obs_num}" \${etkf_file} > ob.etkf.e\${e_num}
       rm -f ob.etkf.0*
       #
       g_num=\`expr \${g_num} + 1\`
    done
    #
EOF
    #
    mkdir .speedup_obetkf
    cd    .speedup_obetkf
    if [ -e speedup_obetkf.sh ] ; then
       rm -f speedup_obetkf.sh
    fi
    if [ -e .nodefile ] ; then
       rm -f .nodefile
    fi
    mv ../.nodefile_etkf        .nodefile
    mv ../speedup_obetkf.sh     .
    ln -sf ../LANDUSE.TBL       .
    chmod u+x speedup_obetkf.sh
    ./speedup_obetkf.sh &
    cd ..
    #
    else
      half_member=${num_members}
    fi
    #
    # --- run the member from 1 to ${half_member}
    #
    g_num=1
    while [ ${g_num} -le ${half_member} ]
    do
       if [ ${g_num} -lt 10 ] ; then
          e_num=00${g_num}
       elif [ ${g_num} -lt 100 ] ; then
          e_num=0${g_num}
       else
          e_num=${g_num}
       fi
       ln -sf ${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00 fg
       #
       ncpu_ob=${ncpu_ob_in}
       if [ ${ncpu_ob} -gt ${ncpu_wrfda} ] ; then
          ncpu_ob=${ncpu_wrfda}
       fi
       if [ ${which_mpi} == 'openmpi' ] ; then
          mpirun -np ${ncpu_ob} ${mpi_opt} da_wrfvar.exe
       fi
       #
       if [ ${ncpu_ob} -eq 1 ] ; then
          if [ -e ob.etkf.000 ] ; then
             etkf_file=ob.etkf.000
          fi
          if [ -e ob.etkf.0000 ] ; then
             etkf_file=ob.etkf.0000
          fi
          obs_num=`wc -l ${etkf_file} | sed -n 1p | awk '{print $1}'`
          sed "1 i\\${obs_num}" ${etkf_file} > ob.etkf.e${e_num}
       else
          obs_num=`wc -l ob.etkf.0* | sed -n '$p' | awk '{print $1}'`
          cat ob.etkf.0* | sed "1 i\\${obs_num}"  > ob.etkf.e${e_num}
       fi
       rm -f ob.etkf.0*
       #
       g_num=`expr ${g_num} + 1`
    done
    #
    # --- next, wait and judge if ob.etkf.e* for all members OK ?
    #
    if [ ${if_speedup_obetkf} == yes ] ; then
      wait_num=0
      while [ ${wait_num} -le 3600 ]
      do
         if [ -e ob.etkf.e*${half_member} ] && [ -e .speedup_obetkf/ob.etkf.e*${num_members} ] ; then
            sleep 2s
            cp .speedup_obetkf/ob.etkf.e* ./
            break
         else
            sleep 2s
         fi
         wait_num=`expr ${wait_num} + 1`
      done
    fi
    # 
    time2=`date +%s`
    time_used=`expr ${time2} - ${time1}`
    echo '               . ob_etkf.e[num] files    ('${time_used}'s)'   >> ../my_cost_time.msg
 fi 
 #
 fi
 # --- End of Part-2 for "update_anal_way = etkf"


 # --- 3.4 Run Ensemble Transform Kalman Filter 
 # ---
 # --- Part-3
 if [ ${update_anal_way} == 'etkf' ] ; then
 #
 echo ''
 echo ' --- step-3-Part-3: '
 time1=`date +%s`
 if [ -d etkf ] ; then
   rm -rf etkf
 fi
 mkdir etkf
 cd etkf
 # --- get ob_etkf.e???
 mv ../ob.etkf.e* ./
 #
 # --- Prepare ETKF input/output files 
 #
 # --- the mean file
 # --- it is already updated by Hybrid-3DVAR in the step-3.2
 #
 # --- Since the second step, wrfout_d01_${out_time}:00:00_update
 # --- does not match with the wrfout_d01_${out_time}:00:00 under
 # --- ${ensemble_dir}/${analysis_time}.e${e_num}
 # --- their size and variable do not agree !
 # ---
 # --- How to match them ? My idea is to run wrf starting with
 # --- wrfout_d01_${out_time}:00:00_update, then the initial output
 # --- wrfout_d01 is used instead of wrfout_d01_${out_time}:00:00_update
 # ---
 # --- It is testd OK. 18 Sep 2010, Yushan campus.
 # --- correct a bug on namelist.input, 25 Sep 2010, Yushan campus.
 # ---
 cd ..
 if [ ${rewrite_mean}    == yes ] ; then
 if [ ${update_ens_mean} == yes ] ; then
 if [ ${produce_ens}   == no  ] ; then
   time1=`date +%s`
   cp -f ${temp_dir}/wrfout_d01_${out_time}:00:00_update ../run_wrfv3/wrfinput_d01 
   cd ../run_wrfv3
   cp -f hybrid_3dvar_wrf_namelists/namelist.input_step${cycle_step}   ./
   cp -f ${bdy_dir}/3dvar_step${cycle_step}/wrfbdy_d01 ./    
   # --- namelist
   if [ $mark == 1 ] ; then
     sed 's/run_seconds=0/run_seconds=30/g'                \
         namelist.input_step${cycle_step}                                      | \
     sed 's/run_hours='${run_hour}'/run_hours=0/g'   | \
     sed 's/max_dom='${max_dom}'/max_dom=1/g'    | \
     sed 's/time_step_second/30/g'   > namelist.input
   else
     sed 's/run_seconds=0/run_seconds=30/g'                \
         namelist.input_step${cycle_step}                                      | \
     sed 's/run_hours='${cycle_intv}'/run_hours=0/g' | \
     sed 's/time_step_second/30/g'   > namelist.input
   fi
   # --- run wrf.exe
   if [ ${mark} == 1 ] ; then
     wrfout_file=wrfout_d01
   else
     wrfout_file=wrfout_d01_${out_time}:00:00
   fi
   if [ -e ${wrfout_file} ] ; then
     rm -f ${wrfout_file}
   fi
   if [ ${which_mpi} == 'openmpi' ] ; then
       mpirun -np 1 ${mpi_opt} wrf.exe 
   fi
   if [ ${which_mpi} == 'mpich2' ] ; then
       mpirun  -n 1 wrf.exe < /dev/null
   fi
   total_wait_num=30
   wait_num=0
   while [ ${wait_num} -le ${total_wait_num} ]
   do
     if [ -e ${wrfout_file} ] ; then
       mv ${wrfout_file} ../run_hybrid/${temp_dir}/wrfout_d01_${out_time}:00:00_update
       break
     else
       sleep 2
     fi
     wait_num=`expr ${wait_num} + 1`
   done

   # --- clean
   rm -f namelist.input namelist.input_step${cycle_step} rsl.*
   rm -f wrfbdy_d01     wrfinput_d01
   # --- go back
   cd ../run_hybrid
   #
   time2=`date +%s`
   time_used=`expr ${time2} - ${time1}`
   echo '               . rewrite updated ens-mean('${time_used}'s)'  >> ../my_cost_time.msg
 fi
 fi
 fi
 #
 # --- 
 cd etkf
 if [ ${update_ens_mean} == yes ] ; then
   ln -sf ../${temp_dir}/wrfout_d01_${out_time}:00:00_update  etkf_input
 else
   ln -sf ../${temp_dir}/wrfout_d01_${out_time}:00:00  etkf_input
 fi
 #
 # --- LOOP for every member
 num=1
 while  [ ${num} -le ${num_members} ]
 do
   #
   if [ ${num} -lt 10 ] ; then
     e_num=00${num}
   elif [ ${num} -lt 100 ] ; then
     e_num=0${num}
   else
     e_num=${num}
   fi
   #
   # --- etkf_input.e??? and etkf_output.e???
   ln -sf ../${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00 \
          etkf_input.e${e_num}
   # --- keep the same dimension between etkf_output.* and etkf_input
   # --- 22 Nov 2010, solve the MU problem on WRF-CFL error
   # --- old way: cp etkf_input.e${e_num} etkf_output.e${e_num}
   #
   if [ ${ini_etkf_way} == way1 ] ; then
     cp -f etkf_input etkf_output.e${e_num}    
   fi
   if [ ${ini_etkf_way} == way2 ] ; then
     cp -f etkf_input.e${e_num} etkf_output.e${e_num}
   fi
   #
   # --- next member
   num=`expr ${num} + 1 `
   #
 done
 #
 # --- create namelist and run ETKF
 cat > gen_be_etkf_nl.nl << EOF
&gen_be_etkf_nl
  num_members=${num_members},
  nv=${nv}
  cv=${cv}
  naccumt1=${naccumt1}
  naccumt2=${naccumt2}
  nout=${nout}
  tainflatinput=${tainflatinput}
  rhoinput=${rhoinput}
/
EOF
 #
 # --- run gen_be_etkf.exe
 #
 ln -sf ../gen_be_etkf.exe .
 if [ ${nout} -ge 2 ] ; then
   # --- use the previous etkf_data.txt
   mv -f ../etkf_data.txt ./
 fi
 #
 if [ ${ens_method} == 'randomcv' ] ; then
    # ---
    # --- 03 Feb 2012, Home.
    # --- Not needed to run gen_be_etkf.exe,
    # --- directly copy input-file to output-file. Because
    # --- "run gen_be_etkf.exe" without any obs will meet
    # --- trouble using ifort compiler, as well as pgi sometimes.
    # ---
    echo 'Not needed to run ./gen_be_etkf.exe here.'
 else
   ./gen_be_etkf.exe
 fi
 #
 if [ -e ../etkf_data.txt ] ; then
   rm -f ../etkf_data.txt
 fi
 cp -f etkf_data.txt ../etkf_data.txt
 #
 cd ..
 if [ -d etkf_${analysis_time} ] ; then
   rm -rf etkf_${analysis_time}
 fi
 # --- Modify the global variable "START_DATE" and "SIMULATION_START_DATE" 
 # --- by using NCO command "ncatted"
 # --- 21 Jul 2011.
 cd etkf
 #
 if [ ${ens_method} == 'randomcv' ] ; then
    # ---
    # --- 03 Feb 2012, Home.
    # --- No etkf.output from gen_be_etkf.exe, because it does not run.
    # --- Directly copy input-file to output-file.
    # ---
    for etkf_out in `ls etkf_input.e*`
    do
      out_file=`echo ${etkf_out} | sed 's/input/output/g'`
      cp -f ${etkf_out} ${out_file}
    done
 fi
 #
 etkf_out_time=${out_time}:00:00
 for etkf_out in `ls etkf_output.e*`
 do
   ncatted -h -a TITLE,global,m,c,"OUTPUT FROM Hybrid-ETKF:"${etkf_out} ${etkf_out}
   ncatted -h -a START_DATE,global,m,c,${etkf_out_time}                 ${etkf_out}
   ncatted -h -a SIMULATION_START_DATE,global,m,c,${etkf_out_time}      ${etkf_out}
 done
 cd ..
 #
 mv etkf etkf_${analysis_time}
 time2=`date +%s`
 time_used=`expr ${time2} - ${time1}`
 echo '               . run gen_be_etkf.exe     ('${time_used}'s)'   >> ../my_cost_time.msg
 #
 # --- End of Part-3 for "update_anal_way = etkf"
 fi

 # ==== Step 4: Update boundary conditions
 if [ ${update_anal_way} == hybrid ] ; then
   echo '  updating member analysis by hybrid instead of etkf!'
 fi
 #
 echo ''
 echo ' --- Step-4: Update boundary conditions'
 time1=`date +%s`
 #
 # --- get parame.in
 if [ ${ens_method} == 'ensemble' ] ; then
   cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling       parame.in
 fi
 if [ ${ens_method} == 'randomcv' ] ; then
   if [ ${produce_ens} == yes ] ; then
     cp -f  cycling_hybrid_3dvar_namelists/parame.in_no_cycling  parame.in
     if [ ${ics_from_previous} == yes ] ; then
       cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling   parame.in
     fi
   else
     cp -f  cycling_hybrid_3dvar_namelists/parame.in_cycling     parame.in
   fi
 fi
 #
 # ---  LOOP for every member
 num=1
 while  [ ${num} -le ${num_members} ]
 do
   #
   if [ ${num} -lt 10 ] ; then
     e_num=00${num}
   elif [ ${num} -lt 100 ] ; then
     e_num=0${num}
   else
     e_num=${num}
   fi
   # --- fg
   if [ -e fg ] ; then
     rm -f fg
   fi
   # --- wrfbdy_d01
   if [ -e wrfbdy_d01 ] ; then
     rm -f wrfbdy_d01
   fi
   # --- wrfvar_output
   if [ -e wrfvar_output ] ; then
     rm -f wrfvar_output
   fi
   #
   if [ ${update_anal_way} == etkf ] ; then
     #
     # --- 25 Jul 2012, Yushan campus.
     #ln -sf ${ensemble_dir}/${analysis_time}.e${e_num}/wrfout_d01_${out_time}:00:00 fg
     if [ -e ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc ] ; then
       ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc fg
     else
       ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01 fg
     fi
     #
     ln -sf etkf_${analysis_time}/etkf_output.e${e_num}            wrfvar_output  
     cp  -f ${ensemble_dir}/${analysis_time}.e${e_num}/wrfbdy_d01  wrfbdy_d01
     #
     # --- run ./da_update_bc.exe
     ./da_update_bc.exe >> etkf_hybird.msg
   fi
   #
   # --- save result for next cycle
   # --- $mark == 1 means the final step, only do Hybrid-3DVAR!
   if [ ${mark} == 1 ] ; then
     if [ ! -e etkf_hybrid_result ] ; then
       mkdir -p etkf_hybrid_result
     fi
     hybrid_domain2=../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d02
     if [ ${max_dom} == 3 ] ; then
       hybrid_domain3=../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d03
     fi
     # -------------- Start to update the boundary conditions for ens_mean ----- 
     # --- fg
     if [ -e fg ] ; then
       rm -f fg
     fi
     # --- wrfbdy_d01
     if [ -e wrfbdy_d01 ] ; then
       rm -f wrfbdy_d01
     fi
     # --- wrfvar_output
     if [ -e wrfvar_output ] ; then
       rm -f wrfvar_output
     fi
     #
     if [ -e ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc ] ; then
       ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01_bc fg
     else
       ln -sf ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfinput_d01 fg
     fi
     ln -sf ${temp_dir}/wrfout_d01_${out_time}:00:00_update          wrfvar_output
     cp -f  ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/wrfbdy_d01   wrfbdy_d01
     ./da_update_bc.exe >> etkf_hybird.msg
     mv wrfbdy_d01       etkf_hybrid_result/
     # -------------- End of updation of boundary conditions for ens_mean ------
     if [ -e ${hybrid_domain2} ] ; then
	cp ${hybrid_domain2} etkf_hybrid_result/
     fi
     if [ ${max_dom} == 3 ] ; then
     if [ -e ${hybrid_domain3} ] ; then
        mv ${hybrid_domain3} etkf_hybrid_result/
     fi
     fi
     cp -f ${temp_dir}/wrfout_d01_${out_time}:00:00_update  etkf_hybrid_result/wrfinput_d01
     mv -f etkf_hybird.msg  etkf_hybrid_result/etkf_hybird.msg
     cp -f  ../run_wrfv3/${bdy_dir}/3dvar_step${cycle_step}/3dvar_result/namelist.input_time_step \
            etkf_hybrid_result/namelist.input
   else
     if [ ! -e etkf_hybrid_result/e${e_num} ] ; then
       mkdir -p etkf_hybrid_result/e${e_num}
     fi
     mv wrfbdy_d01       etkf_hybrid_result/e${e_num}/
     mv etkf_hybird.msg  etkf_hybrid_result/etkf_hybird.msg.e${e_num}
     # --- do link only to save disk space
     cd etkf_hybrid_result/e${e_num}
     ln -sf ../../etkf_${analysis_time}/etkf_output.e${e_num} wrfinput_d01
     cd ../..
   fi
   #
   # --- next member
   num=`expr ${num} + 1 `
   #
 done
 time2=`date +%s`
 time_used=`expr ${time2} - ${time1}`
 echo '            . update boundary conditions ('${time_used}'s)' >> ../my_cost_time.msg


 # ==== Step 5: do clean and save result
 echo ''
 echo ' --- Step-5: do clean and save result'
 time1=`date +%s`
 if [ -d etkf_hybrid_result_${out_time} ] ; then
   mv etkf_hybrid_result_${out_time} etkf_hybrid_result_${out_time}_ensemble
 fi
 mv etkf_hybrid_result   etkf_hybrid_result_${out_time} 
 #
 # --- save some information for the last member
 out_msg=etkf_hybrid_msg/step${cycle_step}.da_wrfvar_msg
 if [ -d ${out_msg} ] ; then
   rm -rf ${out_msg}
 fi
 mkdir -p ${out_msg} 
 mv *oma* gts_omb* *qcstat* rej* unpert_obs* statistics filter* \
    grad_fn cost_fn  check_max_iv buddy_check random_ensemble*.msg ${out_msg} >& tmp_msg
 cp rsl.out.*  ${out_msg} >& tmp_msg
 rm -f tmp_msg
 #
 time2=`date +%s`
 time_used=`expr ${time2} - ${time1}`
 echo '            . do clean and save messages ('${time_used}'s)' >> ../my_cost_time.msg


# ============================= End of File ============================

#!/bin/csh
# ---------------------------------------------------------------------- 
# --- Purpose:                                                       --- 
# ---   do cycling hybrid_etkf_3dvar                                 ---
# ---------------------------------------------------------------------- 
# --- Author: Dr. GAO Shanhong, Ocean University of China.           --- 
# ---                                                                --- 
# --- History:                                                       --- 
# --- (1) 09-11 Aug 2010, V3.2, Yushan campus.                       ---
# ---     based on cycling_3dvar_wrf_run.csh.                        --- 
# ---     Only one domain is tested OK !                             --- 
# ---                                                                --- 
# --- (2) 19 Aug 2010, Yushan campus.                                --- 
# ---     During cycling-Hybrid-3DVAR process, if two domians run    --- 
# ---     stimulously, a lot of computation cost will need. I do not --- 
# ---     want to do this. However, the final step will produce      --- 
# ---     wrfinput_d02 for the next WRF run with a nest domain !     --- 
# ---                                                                --- 
# ---     This idea is realized by wrfv3/hybrid_3dvar_wrf_namelists/ --- 
# ---     create_wrf_namelists.csh !                                 --- 
# ---                                                                --- 
# --- (3) 21-23 Aug 2010, Yushan campus.                             --- 
# ---     Tested OK for WRF-V3.2.1.                                  --- 
# ---     It has the capbility to do single hybrid-3DVAR.            --- 
# ---                                                                --- 
# --- (4) 29 Aug 2010, Yushan campus.                                --- 
# ---     do check of be_cv5.dat, gts_obs and radiance_obs !         --- 
# ---                                                                --- 
# --- (5) 31 Aug 2010, Yushan campus.                                --- 
# ---     collect settings information and print them out for check! --- 
# ---                                                                --- 
# --- (6) 07 Sep 2010, Yushan campus.                                --- 
# ---     Do test of Hybrid-ETKF-3DVAR !                             --- 
# ---                                                                --- 
# --- (7) 10 Sep 2010, Laoshan campus. ( Gao and Wang Yongming )     ---
# ---     add capability to do radar assimilation.                   ---
# ---                                                                --- 
# --- (8) 11 Sep 2010, Yushan campus.                                --- 
# ---     set different time step to let wrf.exe run OK !            --- 
# ---                                                                --- 
# --- (9) 13-14 Sep 2010, Laoshan and Yushan campus.                 --- 
# ---     Use anayise_type='randomcv' in wrf-3dvar to produce        --- 
# ---     ensemble of perturbed  wrfinput_d01 files.                 --- 
# ---                                                                --- 
# --- (10) 16 Sep 2010, Yushan campus.                               ---
# ---      Correct a bug on updating BC !                            ---
# ---                                                                --- 
# --- (11) 18 Sep 2010, Yushan campus.                               --- 
# ---      The result from Hybrid-3DVAR should be rewritten by       --- 
# ---      wrf.exe before it is used by ETKF !                       --- 
# ---      I do not know the real reason, but it is very important   --- 
# ---      for cycling Hybrid ETKF-3DVAR !                           --- 
# ---                                                                --- 
# --- (12) 23 Sep 2010, Yushan campus.                               ---
# ---      gmao_airs_bufr.tbl:     before 12Z Aug 14 2007.           ---
# ---      gmao_airs_bufr.tbl_new: starting at 12Z Aug 14 2007.      ---
# ---      control assimilation of airsretobs.                       ---
# ---                                                                ---
# --- (13) 29 Sep 2010, Yushan campus.                               ---
# ---      If 'MU' is contained in cv variable list, then we must    ---
# ---      force " rewrite_ens_mean = yes "!                         ---
# ---      MU: perturbation dry air mass in column                   ---
# ---                                                                ---
# --- (14) 14 oct 2010, Yushan campus.                               ---
# ---      control the details of check_max_iv=.true.                ---
# ---      the default values will remove strong inversion obs.      ---
# ---                                                                ---
# --- (15) 04-14 Nov 2010, Yushan campus.                            ---
# ---      add check_rh_opt and sfc_assi_opt.                        ---
# ---      add varbc_factor for radiance assimilation.               ---
# ---      check cost_fn and grad_fn!                                ---
# ---      prepare for ensemble forecasts!                           ---
# ---                                                                ---
# --- (16) 20-22 Nov 2010, Yushan campus.                            ---   
# ---      Understand the meaning of nout, naccumt1 and naccumt2.    ---
# ---      ICs of randomcv can be from 3DVAR result.                 ---
# ---      Re-check MU problem!                                      ---
# ---                                                                ---
# --- (17) 24-28 Nov 2010, Yushan campus.                            ---   
# ---      Add write_input = t for 3DVAR use!                        ---
# ---      Is is just this bug which causes MU problem!              ---
# ---                                                                ---
# --- (18) 27 Dec 2010, Yushan campus.                               ---
# ---      Add capability to do hot-start for cycle-3dvar!           ---
# ---                                                                ---
# --- (19) 17 Feb 2011, Yushan campus.                               ---
# ---      Control num_metgrid_soil_levels                           ---
# ---      correct a bug for the last cycle.( 09 Mar 2011)           ---
# ---                                                                ---
# --- (20) 24 Feb 2011, Yushan campus.                               ---
# ---      Use DFI for the first cycle wrfinput_d01!                 ---
# ---                                                                ---
# --- (21) 07-09 Apr 2011, Yushan campus.                            ---
# ---      V3.3 test. Judge WRFDA ver to decide if crtm_atmosphere   ---
# ---      will be used in namelist.input of 3DVAR!                  ---
# ---                                                                ---
# ---      12-17 Apr 2011, Yushan campus and home.                   ---
# ---      Check ETKF code again. New method to create initial ens.  ---
# ---      Correct a bug when using both QSUB and time-lagged.       ---
# ---      Three important things:                                   ---
# ---        (a) use adaptive time step.                             ---
# ---        (b) call multiple schemes including MP, CUP and PBL.    ---
# ---        (c) add 'all_fcst' for the option of forecast_type.     ---
# ---            output can be for both det_fcst and ens_fcst.       ---
# ---                                                                ---
# ---      22-22 Apr 2011, Yushan campus.                            ---
# ---      control the option "cycling" in namelist.input, this is   ---
# ---      especially for Tompson scheme.                            ---
# ---      Let create_wrf_namelists.csh do this thing.               ---
# ---                                                                ---
# ---      01 May 2011. Changes following run_wps modifications.     ---
# ---                                                                ---
# --- (22) 27-29 May 2011, Laoshan campus and home.                  ---
# ---      correct bugs on "set fixed_time_step = no".               ---
# ---      need not check_cfl_file any longer.                       ---
# ---      let num_soil_layers be multiple.                          ---
# ---      judge if physical options mismatch happens.               ---
# ---      We can tune the scale_length of cv5.                      ---
# ---                                                                ---
# --- (23) 19-24 Jun 2011, Yushan campus.                            ---
# ---      check_namelist.csh is called to run and write its message ---
# ---      into my_settings.msg.                                     ---
# ---      add option "run" to control this script run.              ---
# ---      correct a bug in prodcuing ICs and BCs if ifort is used.  ---
# ---                                                                ---
# --- (24) 10 Jul 2011, At home.                                     ---
# ---      Use "grep -h -c " instead of "test -s"                    ---
# ---      Avoid writing output frequently.                          ---
# ---      If my reported bugs are accepted, use adaptive time-step! --- 
# ---                                                                ---
# --- (25) 21 Jul 2011, Yushan campus.                               ---
# ---      Modify global variables START_DATE & SIMULATION_START_DATE --
# ---      in the files etkf_output.e?? for WRF run of the next cycle.--
# ---      By using NCO command "ncatted". NCO must be installed!    ---
# ---      24 Jul 2011. If put_rand_seed manuually ?                 ---
# ---      05 Aug 2011. Change time-lagged to "ensemble".            ---
# ---                                                                ---
# --- (26) 25 Sep 2011, Home.                                        ---
# ---      add option use_input_w for V3.3.1, but DFI dislike it.    ---
# ---                                                                ---
# --- (27) 11 Oct 2011, Yushan campus.                               ---
# ---      let WRF output be wrfvar-dX, thanks to Wang Yongming.     ---
# ---                                                                ---
# --- (28) 03 Nov 2011, Yushan campus.                               ---
# ---      add option for ndown run.                                 ---
# ---                                                                ---
# --- (29) 23 Nov 2011, Yushan campus.                               ---
# ---      add option=if_use_DFI_result for PBL=MYNN.                ---
# ---                                                                ---
# --- (30) 03 Jan 2012, Yushan campus.                               ---
# ---      Let this code run on Dawning Cluster by using PBS!        ---
# ---                                                                ---
# --- (31) 01 Feb 2012, Yushan campus.                               ---
# ---      Add codes for restart use.                                ---
# ---                                                                ---
# --- (32) 08 Feb 2012, Yushan campus.                               ---
# ---      Do DFI before the WRF run of every ensemble member!       ---
# ---      Because after ETKF, the result may be in unlalance.       ---
# ---                                                                ---
# --- (33) 20 Feb 2012, Yushan campus.                               ---
# ---      Much more easy to control if_multi_schemes=yes.           ---
# ---                                                                ---
# --- (34) 24 Feb 2012, Yushan campus. with a time mark.             ---
# ---      Get rid of the final step run in ETKF-LOOP to save time.  ---
# ---      It does not effect the result, because it will be done in ---
# ---      the final "Especial" part and I also carefully check and  ---
# ---      compare the result with code with "final step run". OK!   ---
# ---      It is for "forecast_type = det_fcst" only!                ---
# ---                                                                ---
# --- (35) 14 Jun 2012, Yushan campus.                               ---
# ---      check domian settings again.                              ---
# ---                                                                ---
# --- (36) 03 Jul 2012, Yushan campus.                               ---
# ---      add option ncpu_etkf_ob.                                  ---
# ---                                                                ---
# --- (37) 22-23 Jul 2012, Yushan campus.                            ---
# ---      add the capability to create perturbated BCs.             ---
# ---                                                                ---
# --- (38) 03 Sep 2012, Yushan campus.                               ---
# ---      Calculate the real time for Cluster-system.               ---
# ---                                                                ---
# --- (39) 18 Sep 2012, Yushan campus.                               ---
# ---      Divide ensemble-wrf-runs into two groups to speed up!     ---
# ---                                                                ---
# --- (40) 23 Dec 2012, Yushan campus.                               ---
# ---      test for V3.4.1, add alpha_vertloc = .true.               ---
# ---      Please see WRFDA/var/gen_be/gen_be_vertloc.f90.           ---
# ---                                                                ---
# --- (41) 13 Jan 2013, Yushan campus.                               ---
# ---      add option " if_speedup_obetkf "                          ---
# ----------------------------------------------------------------------

 # ===
 # === Step-0: Check input variables, echo history and usage
 # ===
 clear
 echo '  ============================================================'
 echo '  === Cycling Hybrid-ETKF-3DVAR will be done!              ==='
 echo '  === All Copyrights Reserved, 2010-2012.                  ==='
 echo '  === ---------------------------------------------------- ==='
 echo '  === Author: Dr. GAO Shanhong.                            ==='
 echo '  === 1: 09-11, 19-31 Aug 2010, V3.2, V3.2.1               ==='
 echo '  === 2: 07-08 Sep 2010, Hybrid-ETKF-3DVAR                 ==='
 echo '  ===    13-23 Sep 2010, analysis_type=randomcv            ==='
 echo '  ===    24-29 Sep 2010, lots of modifications             ==='
 echo '  ===    03-14 Oct 2010, carefully check all codes again   ==='
 echo '  === 3: 02-22 Nov 2010, add some control options          ==='
 echo '  ===                    prepare for ensemble forecasts    ==='
 echo '  ===                    Really understand nout,naccumt1,2 ==='
 echo '  ===                    ICs of randomcv from 3DVAR result ==='
 echo '  ===    24-28 Nov 2010, add write_input=t for 3DVAR use   ==='
 echo '  === 4: 24-25 Feb 2011, DFI for 1st cycle wrfinput_d01    ==='
 echo '  ===    07-22 Apr 2011, 27-29 May, Jun-Sep 2011, V3.3_3.1 ==='
 echo '  === 5: Jan-Jul,  2012, add restart use and optimization  ==='
 echo '  ============================================================'
 #
 # --- check input variabels
 set input_num  = ${#}
 #
 if( ${input_num} <= 1 ) then
   set job_type = "PBS-no"
   if( ${input_num} == 0 ) then
     set input_num  = 1
     set input_var1 = 'help'
   endif
   if( ${input_num} == 1 ) then
     set input_var1 = ${1}
   endif
   if( ${input_var1} == 'check' || \
       ${input_var1} == 'clean' || ${input_var1} == 'run' ) then
     if( ${input_var1} == 'run' && ! -e my_settings.msg ) then
        echo ''
        echo '  Suggestion: '
        echo '    Please always do the two steps at first!'
        echo '    step-1: type "hybrid_etkf_3dvar.csh check"; '
        echo '    step-2: "less my_settings.msg" to check your settings.'
        echo '  '
        echo '    Please type "hybrid_etkf_3dvar.csh help" to see usage!'
        echo '  '
        echo '  ============================================================'
        exit
     endif
   else
     echo '  Usage:'
     echo '    1. see help: hybrid_etkf_3dvar.csh        '
     echo '             or  hybrid_etkf_3dvar.csh  help  '
     echo '    2. do check: hybrid_etkf_3dvar.csh  check  (always do it)'
     echo '    3. do clean: hybrid_etkf_3dvar.csh  clean  (important)'
     echo '                 Must do it before a new run!'
     echo '    4. do run:   hybrid_etkf_3dvar.csh  run    (not recommended)'
     echo '       recommend:'
     echo '         nohup hybrid_etkf_3dvar.csh run > my_final.msg 2>&1 &'
     echo ''
     echo '    5. Strongly recommend you use PBS to submit this task!'
     echo ''
     echo '  ============================================================'
     echo ''
     exit
   endif
 else
   # --- PBS run
   set in_cap = `echo $2 | tr "[a-z]" "[A-Z]"`
   if( $2 == $in_cap ) then
     set job_type = "PBS-yes"
     echo '  You are using qsub to submit your job.'
   else
     echo '  Please check your PBS job shell-script!'
     exit
   endif
 endif

 # === 
 # === Step-1: create structure and do settings
 # === 

 # --- 1.1 set PATHs of WRFV3/run and WRFDA/var/seafog
 # ---     need not change them !
 # ---------------------------------------------------
 set current_path = `pwd`
 set wrf_run_path = ${current_path}/run_wrfv3
 set wrf_da_path  = ${current_path}/run_hybrid
 set wrf_cost_msg = ${current_path}/my_cost_time.msg

 # --- 1.2 da-type and bg type ?
 # ---------------------------------
 # --- da_type : cycling_hybrid_etkf
 # --- da_type : single_hybrid_etkf
 # ---
 # ---
 set da_type  = cycling_hybrid_etkf
 #set da_type  = single_hybrid_etkf
 #
 # --- for the purpose of testing the codes ?
 # --- yes or no, usually no !
 # ---
 set test_prepare_ini_ens  = no
 set test_run_hybrid_3dvar = no
 #
 # ---
 # --- Only want to get wrfndi_d02 ?
 # --- if_ndown = yes / no
 # ---
 #set if_ndown = yes
 set if_ndown = no
 #
 # --- bg type ? (CFS, GFS, FNL etc )
 # --- its interval in time? (FNL, CFS: 6hr; GFS: 3hr)
 set bg_type = FNL
 set bg_intv = 6
 #
 # --- How many domains?
 # --- domain_num=1 means no nesting.
 # --- Only up to 2 domains now !
 # ---
 # --- (19 Aug 2010)
 # --- domain_num = 2 means wrf run with two domains, but
 # --- during cycling-hybrid-3dvar will use only 1 domain!
 # --- Only up to 3 domains now! It means domain_num <= 3.
 # ---
 set domain_num = 2

 # --- 1.3 WRF case name?
 # ----------------------
 # --- 
 set case_name = seafog
 # --- 
 # ---    WPS case name?
 set wps_case_name = seafog

 # --- 1.4 do Date-Time, SST settings
 # --------------------------------------------
 # --- a) if DFI for 1st cycle wrfinput_d01?
 # ---    if_DFI        : yes/no, normally yes
 # ---    dfi_time_step : seconds, <=3*dx
 # ---
 # ---    if_DFI=yes, if_hot_start reset to no!
 # ---
 set if_DFI        = yes
 set dfi_time_step = 90
 # ---
 # --- DFI will fail when MYNN is used
 # --- use DFI-result from YSU under run_wrfv3
 set if_use_DFI_result = no
 set DFI_result_file   = wrfinput_initialized_d01_YSU
 #
 # --- b) if using hot start to force cycle-3dvar?
 # ---    if_hot_start = yes / no
 # ---    ahead_hours  = 6 (unit: hours)
 # ---
 set if_hot_start   = no
 set ihot_start_beg = 2006-03-05_06
 set ahead_hours    = 6
 #
 # --- c) periods of cycle-3dvar and simulation
 set cycle_date_beg = 2006-03-05_12
 set cycle_date_end = 2006-03-06_00
 set model_date_end = 2006-03-08_00

 # --- d) how many hours is the cycle interval ?
 set cycle_intv   = 3

 # --- e) how many hours is the cycle output ?
 # ---    cycle_output should be <= cycle_intv 
 # ---    normally let cycle_output = cycle_intv 
 # ---
 set cycle_output = 3

 # --- f) preparation for creating random BCs
 # ---     i) wrfinput_ and wrfbdy_ files for
 # ---        perturb_bc_prepare = yes / no
 # ---    ii) Let this script be called
 # ---        perturb_bc_create  = yes / no
 # --- Note: Modification is needed for testing only!
 # ---       Otherwise, keep them be "no" !
 # ---       It is called by perturb_bc_prepare/perturb_bc.sh.
 # ---
 set perturb_bc_prepare = no
 set perturb_bc_create  = no

 # --- 1.5 set MPI parallel run and CPU number
 # -------------------------------------------
 # --- a)
 # --- Which mpich software ? ( mpich2 / openmpi )
 # --- How many numtiles ?
 # ---
 # --- For machine SGI    : openmpi, numtiles = 1
 # ---      8-core typhoon: mpich2,  numtiles = 8, maxcpu_node=8
 # ---      8-core tornado: openmpi, numtiles = 4, maxcpu_node=8
 # ---     12-core seafog : openmpi, numtiles = 6, maxcpu_node=12
 # ---
 # --- Only "which_mpi = openmpi" is carefully tested. 
 # ---
 #set which_mpi  = mpich2
 set which_mpi   = openmpi 
 set numtiles    = 1
 #
 # --- maxcpu_node : control real.exe run (faster on one node)
 # --- ncpu_etkf_ob: control da_wrfvar.exe run to produce ob.etkf.e??
 # ---               2--4 is better. However please try other values,
 # ---               because it is machine-dependent.
 # ---               Lots of time is cost due to producing ob.etkf.e??.
 # --- maxcpu_wrfda: how many CPUs (or cores) are used for da_wrfvar.exe?
 # ---               if = 0, determined by the PBS script
 # --- 
 set maxcpu_node  = 12
 set ncpu_etkf_ob = 1
 set maxcpu_wrfda = 0
 #
 # --- speedup producing ob.etkf.e* ?
 # --- maxcpu_node should be 2 at least !
 # ---
 set if_speedup_obetkf  = yes
 #set if_speedup_obetkf  = no
 #
 #
 # --- MPI options
 # --- on a single node machine without PBS software
 #set mpi_opt = ""
 #
 # --- on a single node machine with PBS software 
 # --- on a cluster system with PBS software
 set mpi_opt = " -hostfile .nodefile "
 #
 # --- on a cluster of Dawning Company with bad openmpi installation
 #set mpi_opt = " --mca btl self,sm,openib -hostfile .nodefile "
 # ---
 # -------------------------------------------------------------
 # --- Others
 # --- for ether net
 #set mpi_opt = " --mca btl self,sm,tcp -hostfile .nodefile "
 # --- for Infiniband net
 #set mpi_opt = " --mca btl self,sm,openib -hostfile .nodefile "
 # --- for IPoIB
 #set mpi_opt = " --mca btl self,sm,tcp \
 #    --mca btl_tcp_if_exclude lo,eth0 -hostfile .nodefile "
 # -------------------------------------------------------------
 # ---
 # --- b) For those machines without PBS
 # ---
 # --- If run on SGI or other machine using PBS, please
 # --- ignore the CPU setting below. Because, for example,
 # --- on SGI it is from the input variable "$2",
 # --- which is given in sgi_run_wrf_wrfda.sh by 
 # --- the setting of "#PBS -l select=*:ncpus=2".
 # ---
 set ncpu_real   = 8
 set ncpu_wrf    = 8
 set ncpu_wrfda  = 8
 # ---
 # --- c) 
 # --- The ensemble-wrf-runs are divided into two groups, that
 # --- can speed up the intergrating process. It means the half of 
 # --- ${ncpu_wrf} will be used for each group. 
 # --- If if_speedup=yes, adaptive time-step is forcedly used to ensure
 # --  every member wrf run successfully.
 # --- if_speedup  = yes / no
 # ---
 # --- Due to the time inconsistence between nodes, calcuate real time
 # --- of WRF-run according to the elapsed time in rsl.error.0000
 # --- if_rsl_time = yes / no
 # ---
 set if_speedup  = no
 set if_rsl_time = no

 # --- 1.6 Control assmilation 
 # -------------------------------------------------------
 # ---
 # --- a) Do you want to control assmilation every step ?
 # --- Normally no! If yes, give values to if_assimilate!
 # ----
 # --- 1: yes ; 0: no for values of if_assimilate.
 # --- e.g. if_assmilate = ( 1 1 1 1 1 1 1 1 1 1  1  1  1 )   
 # ---       which step ?    1 2 3 4 5 6 7 8 9 10 11 12 13
 # ---  ( yes or no )  
 set if_control_da = no
 #
 if( $if_control_da == yes ) then
   set if_assimilate = ( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
 else
   set if_assimilate = ( 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 )
 endif

 # --- b) Do you want to do GTS assimilation ?
 # --- ( yes or no )
 set if_gts         = yes
 #
 # --- If yes above, then
 # --- do you want to do airsretobs assimilation ?
 # --- ( yes or no )
 set use_airsretobs = yes

 # --- c) Do you want to do radiance assimilation ?
 # --- if_radiance  = yes or no
 # --- varbc_factor = 1.0 ( default value )
 # ---
 set if_radiance    = no
 set varbc_factor   = 1.0
 #
 # --- Notice: If if_radiance = yes, then ...
 # ---  gmao_airs_bufr.tbl:     before 12Z Aug 14 2007.
 # ---  gmao_airs_bufr.tbl_new: from   12Z Aug 14 2007.
 # ---  ( auto, new or old ) (auto: automatically!)
 # ---
 set airs_bufr_tbl = auto

 # --- d) Do you want to do radar assimilation ?
 # --- ( yes or no )
 set if_radar    = no
 #
 # --- If no above, ignore the settings below.
 # --- because they will be reset to .false.
 # --- If yes, please do set !
 set RADAR_W     = .true.
 set RADAR_OBS   = .true.
 set RADAR_RV    = .true.
 set RADAR_RF    = .true.

 # --- 1.7 Control Hybrid-ETKF-3DVAR processes
 # ---------------------------------------------

 # --- a) ensemble number ?
 # ---    which method to produce the ensemble ?
 # ---    'ensemble' / 'randomcv'
 # ---
 # ---    ensemble:  we have prepared an initial ensemble
 # ---    randomcv:  let this code to create an new one
 # ---
 set ens_members = 24
 #set ens_method  = 'randomcv'
 set ens_method  = 'ensemble'
 # ---
 # --- If ens_method='randomcv', put random seeds manually?
 # ---  .true.  : ramdom ensemble can be repeatable, please see 
 # ---            run_hybrid/hybrid_etkf_3dvar.sh to get how to set 
 # ---            SEED_ARRAY1_value and SEED_ARRAY2_value 
 # ---            You can re-set then if neccessary. 
 # ---
 # ---  .false. : randomly ensemble which are not repeatable case by case
 # ---
 set if_put_seed = .true.
 #set if_put_seed = .false.
 #
 # --- create ensemble members at the initial time?
 # --- yes / no  (More CPUs, much better)
 # ---
 set pert_init_ens = no 
 #
 # --- create ensemble members at the time of #hours ahead
 # ---   and then forecast to the initial time ?
 # --- pert_fcst_ens    : yes / no (More CPUs, much better)
 # --- pert_ahead_hours : hours ahead
 # ---
 set pert_fcst_ens    = no
 set pert_ahead_hours = 6
 #
 # ---
 # --- If the previous initial and boundary conditions are used for this case?
 # --- IC_BC is like ./run_wrfv3/seafog_cycling_hybrid_etkf.
 # ---   yes: will be used.
 # ---   no : will not be used, a new one will be created instead.
 # ---
 set if_previous_IC_BC = yes
 # 
 # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 # --- Multiple PBL, SFC and MP schemes for Ensemble Members 
 # --- if_multi_schemes = yes / no     
 # --- yes: multiple collumns are used. Needs to be carefully tested.
 # --- no:  the first column is used.   It is the old fixed-schemes way.
 # ------------------------
 # --- Notice: 
 # ---   sf_surface_physics in wrfinput.d01 and namelist.input should be the same!
 # ---   In this script, the first collum is used for creating wrfinput.d01, 
 # ---   i.e., sf_surface_physics=2 is used. However, bl_pbl_physics=6 needs 
 # ---   sf_surface_physics=5. So, we could not use bl_pbl_physics=6!
 # ---
 # ---   For my 06-Mar-2006 seafog case:
 # ---     ra_sw_physics=4 and ra_lw_physics=4 will give better result.
 # ---     sf_surface_physics=1 and num_soil_layers=5 will give much better result
 # ---                                                for fog over land.
 # ---   On settings of radt and cudt (radiation_delt_t and cumulus_delt_t )
 # ---   1) radt:  (RAMS: 10-20 minutes enough)
 # ---             minute per km, recommend using same value on all 2-way nests         
 # ---             Please set it <=20 minutes
 # ---             More shorter, more accuracy, and more computional cost.
 # ---   2) cudt:  (RAMS: a short cudt, for example 5 minutes, will kill original 
 # ---              convection in its early stages. time scale comparable to the
 # ---              length of the life cycle, such as 1200-1800 seconds.)
 # ---             Please set it 5-10 minutes.
 # ---
 # ---             Please you had better let mod(radt, time_step)=0 !
 # ---             Please you had better let mod(cudt, time_step)=0 !               
 # ------------------------------------------------------------------------------
 set if_multi_schemes = no 
 #set if_multi_schemes = yes  
 #
 # --- Notice: If if_multi_schemes = no and ens_members > 24, do not add more 
 # ---         elements into the following arrays. I will do this for you later.
 # ---
 # --- Ensemble-Member-No:  1 2 3 4 5 6 7 8 9 X 1 2 3 4 5 6 7 8 9 XX 1 2 3 4
 # ------------------------------------------------------------------------------
 #
 set multi_cycle_num    = 6
 #
 set mp_physics         = ( 2 2 2 2 2 2 2 2 2 2 2 2 )
 set cu_physics         = ( 1 1 1 1 1 1 1 1 1 1 1 1 )
 #
 set bl_pbl_physics     = ( 1 5 1 5 1 5 1 5 1 5 1 5 )
 #
 # --- According to Rao Lijuan's case study, MYNN with sf_sfclay_physics=1
 # --- is better than with sf_sfclay_physics=5. (19 Jun 2012, Gao)
 # --- Pay more attention to grav_settling=1 !
 # ---
 set sf_sfclay_physics  = ( 1 1 1 1 1 1 1 1 1 1 1 1 )
 set grav_settling      = ( 0 1 0 1 0 1 0 1 0 1 0 1 )
 #
 # --- we have to use the same Land Model options for all members.
 set sf_surface_physics = ( 2 2 2 2 2 2 2 2 2 2 2 2 )
 set num_soil_layers    = ( 4 4 4 4 4 4 4 4 4 4 4 4 )
 #
 set ra_sw_physics      = ( 4 4 4 4 4 4 4 4 4 4 4 4 )
 set ra_lw_physics      = ( 4 4 4 4 4 4 4 4 4 4 4 4 )
 #
 set cumulus_delt_t     = 6
 set radiation_delt_t   = 9 
 set sst_update         = 1
 #
 # --- If use the vertical speed in wrfinput file ?
 # --- Do not use if WRF version is not V3.3.1 and above
 #set if_use_input_w     = no
 set if_use_input_w     = yes
 #
 # --- 
 # --- Do DFI before the WRF run of every ensemble member?
 # --- Because after ETKF, the result may be in unbalance.
 # --- backward_minutes and forward_minutes are used to control DFI.
 # --- Usually, backward_minutes is typically between 20 and 60 minutes,
 # --- and forward_minutes is the half of backward_minutes.
 # --- Note boundary conditions must be updated.
 # --- 
 #set DFI_WRF = yes
 set DFI_WRF = no
 # 
 set backward_minutes = 20 
 set forward_minutes  = 10
 #
 # ------------------------------------------------------------------------------
 # --------------------------- Descriptions -------------------------------------
 # ------------------------------------------------------------------------------
 # --- mp_physics : 2-lin, 3-WSM3, 4-WSM5, 5-Ferrier(New Eta),6-WSM56, 8-Thompson, 
 # ---              1-Kessler     14-WDM5, 13-SBU-yLin,       16-WDM6
 # ---
 # --- cu_physics : 1-KF,  2-BMJ,  3-Grell,4-SAS,   5-Grell-3D,    6-Tiedtke,
 # ---              7-Zhang-McFarlane(works with MYJ and UW PBL), 14-New-SAS
 # ---              (SAS is not for adpative time-step)
 # ---
 # --- ra_sw_phys : 1-Duhia, 2-Goddard, 3-CAM, 4-RRTMG, 5-New-Goddard
 # --- ra_lw_phys : 1-RRTM,  2-Goddard, 3-CAM, 4-RRTMG, 5-New-Goddard
 # --- lay_physics: 1-MM5, 2-Mellor-TKE,   4-QNSE,  5-MYNN 
 # ---
 # --- sfc_physics: 1-5layer thermal diffusion, 2-Unified Noah land-surface model
 # --- num_soil_layers : number of soil layers in land surface model
 # ---              5-thermal diffusion scheme, 4-Noah landsurface model
 # ---              6-RUC landsurface model   , 2-Pleim-Xu landsurface model
 # ---
 # --- pbl_physics: 1-YSU, 2-Mellor-TKE, 4-Quasi-Normal Scale Elimination PBL
 # ---              5-MYNN2.5(lay_physics=1,2 or 5),  6-MYNN3(lay_physics=5 only)
 # ---              8-Bougeault TKE(lay_physics=1,2), 9-Bretherton TKE scheme
 # ---              7-ACM2(lay_physics=1,7),          10-TEMF
 # ---
 # --- grav_settling : =1 for MYNN PBL only, =0 for the other PBLs.
 # --- Update SST    : =1 yes, =0 no.
 # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 # --- If 'ensemble' is given, you should prepare the ensemble initial conditions,
 # --- and put or link them under ./run_wrfv3/ !
 #
 set ensemble_dir = pert_fcst_2006030512.ens
 #set ensemble_dir = pert_init_2006030512.ens 
 #set ensemble_dir = time_lagged_2006030512.ens 
 #
 # --- if ens_method  = 'randomcv'
 # --- initial conditions (ICs)
 # --- ICs from the previous forecast/3DVAR result ?
 # --- ics_from_previous     : yes/no 
 # --- where_previous_result : link it under run_wrfv3
 # ---                            it includes wrfinput_d01/fcst_ics
 # --- wrfinput_d01 is often under 3dvar_result_step1 
 # --- fcst_ics can be extracted from wrfout_d01            
 # --- See "4: How to get fcst_ics from wrfout_d01" in README
 # ---
 # --- from previous 3DVAR result                         
 set ics_from_previous     = no
 #
 set where_previous_result = 3dvar_result_step1 
 set previous_file_name    = wrfinput_d01
 #
 # --- from previous forecast result
 #set where_previous_result = previous_fcst
 #set previous_file_name    = fcst_ics
 #
 # --- b) hybrid
 # ---    ensemble covariance weighting factor
 # ---    ( 1./jb_factor + 1./je_factor = 1 )
 # ---    1/beta1 + 1/beta2 = 1, je_factor=beta2
 # ---
 # ---    jb_factor = je_factor/(je_factor - 1)
 # ---    alpha_corr_scale with the unit "km"   
 # ---
 # ---    From Xuguang WANG, 09 Nov 2010.
 # ---    1./je_factor is used by ETKF-3DVAR
 # ---------------------------------------------
 # --- control minimization process.
 # --- print_cost_grad: print cost-/grad- fn ?
 # ---    ( .true. or .false. )
 # --- eps values ? ( default = 0.01 )
 # --- alpha_vertloc : .true. / .false.
 # ---
 set je_factor        = 2.00
 set alpha_corr_scale = 600
 #set alpha_vertloc    = .true.
 set alpha_vertloc    = .false.
 #
 set print_cost_grad  = .false.
 set eps_value        = 0.01
 set inner_loop_num   = 300
 set outer_loop_num   = 3

 # --- c) Which CV (backgroud error) for 3DVAR ?
 # ---    ( 3: default, 5,6: created by us )
 # ---    we can tune the len_scales for CV5.
 # ---
 set cv_number     = 5
 set len_scale_cv5 = 1.0
 #
 # --- d) Which be.dat file ?
 # ---    Please put be and obs files under ./obs_be_files 
 #
 set be_file     = be_cv5.dat
 #set be_file     = be_cv6.dat

 # --- e) Control variabels for ETKF
 # -------------------------------------------------------------
 # --- example options (you can put more variables!)
 #set nv = 13
 #set cv = "'U','V','W','MU','PH','T','QVAPOR','QCLOUD','PSFC'"
 #          'U10','V10','T2','Q2'
 # -------------------------------------------------------------
 #
 # --- for gen_be_etkf_nl.nl 
 set nv = 9
 set cv1 = "'U','V','W','MU','PH','T','QVAPOR','QCLOUD','PSFC',"
 set cv2 = "'U10','V10','T2','Q2'"
 #set cv  = ${cv1}${cv2}
 set cv  = ${cv1}
 #
 set naccumt1      = 3
 set naccumt2      = 3
 set nout          = 0
 set tainflatinput = 0.0
 set rhoinput      = 0.0 

 # --- f) control time step
 # ------------------------------------------------------
 # --- Since 18 Sep 2010, Hybrid-ETKF-3DVAR seems OK !
 # --- time step for WRF ensemble runs (seconds)
 # --- we can use fixed ${time_step[1]} only !
 # --- fixed_time_step = yes :  fixed   time-step
 # --- fixed_time_step = no  :  varying time-step
 # --- ( yes or no )
 # ---
 set fixed_time_step = no
 set wrf_time_step   = 180
 #
 # ---    ${time_step[1]} is used for normal way !
 # ---    So yo should change it according to your needs.
 # ------------------------------------------------------
 # ---
 # ---    avoiding CFL unstable things for wrf.exe run
 # ---    unit: seconds
 # ---    If rsl.out.0000 does not increase size in 10 seconds,
 # ---    I think CFL is bad, then use shorter time-step !
 # ---
 # ---    If "cfl=" appear in rsl.out.000, then use shorter
 # ---    time-step! It is done by "cfl_error = yes"!
 # ---    If cfl_error = no, ignore it!
 # ---
 set time_step_num = 6
 set time_step     = ( ${wrf_time_step} 120 80 60 40 30 )
 #set time_step     = ( ${wrf_time_step} 120 90 60 30 10 )
 # ---
 # --- Normally do no change the following settings
 # --- One wrf run should be finished during:
 # --- total_wait_num * (second_number1 + second_number2 ) seconds.
 # --- second_number1 > one-step-cost-time
 # --- 
 # --- If second_number1 = 10 and second_number2 = 5, then 
 # --- 720*(10+5)=10800s=3h, it is enough for one WRF run !
 # ---
 set total_wait_num = 720
 set second_number1 = 1
 set second_number2 = 1
 set cfl_error      = yes
 set kill_all       = no
 #
 # --- 14 Apr 2011, adaptive time-step scheme is better
 # --- than "fixed_time_step=no" scheme. However, if errors
 # --- happen in using adaptive_time_step, please try to use
 # --- fixed_time_step=no! Especially for PBL=6, MP=8, CP=SAS!
 # -----------------------------------------------------------
 # --- If if_adaptive_time_step=yes, then fixed_time_step=yes.
 # --- If fixed_time_step=no, then if_adaptive_time_step=no.
 # --- if_adaptive_time_step : yes / no
 # --- beg_time_step         : 3- 6 dx, seconds (for Domain-1)
 # --- max_time_step         : 8-12 dx, seconds (for Domain-1)
 # ---
 set if_adaptive_time_step = yes
 set beg_time_step         = '120,  40'
 set max_time_step         = '240,  80'
 #
 # --- Important below !
 # --- Do you want to do ensemble/determistic forecast ?
 # --- ( ens_fcst, det_fcst, all_fcst )
 set forecast_type = det_fcst
 #set forecast_type = ens_fcst
 #set forecast_type = all_fcst

 # ============================================================
 # === Notice:                                              ===
 # ===   Normally, you need't change the following options! ===
 # ===                                                      ===
 # ============================================================

 # --- update ensemble mean for etkf_input ?
 # --- ( yes or no ) 
 set if_update_ens_mean = yes
 #
 # --- which way to update the ens-mean ?
 # --- ( '3dvar' or 'hybrid' )
 # --- From Xuguang WANG's PPT, it should be 'hybrid'!
 # ---
 set update_ens_mean_way = 'hybrid'
 #
 # --- rewrite updated ensemble mean by wrf.exe ?
 # --- If no, please fixed_time_step = no .
 # --- It should be yes normally. 
 # --- However, if no 'MU' in cv, then it can be no!
 # --- Since 01 Oct 2010, please set it no without MU in cv !
 # --- Since 23 Nov 2010, please always set it no !
 # --- since 28 Nov 2010, MU problem is solved !
 # --- ( yes or no )
 set rewrite_ens_mean   = no
 #
 # --- Which analysis_type for Hybird-3DVAR ?
 # --- anal_type = 3DVAR / QC-OBS
 set anal_type = QC-OBS 
 #
 # --- Use filtered_obs for etkf ?
 # --- if anal_type = 3DVAR, it will be reset to no! 
 # --- ( yes or no )
 set use_filtered_obs = yes
 #
 # --- Which way to update ensemble member analysis ?
 # --- ( update_anal_way = etkf or hybrid )
 # --- hybrid : cycling-hybrid-3dvar mode
 # --- etkf   : cycling-hybird-etkf-3dvar mode
 set update_anal_way = 'etkf'
 #
 # --- Which way to give initial etkf_output.e# ?
 # --- way1: using etkf_input    (the updated mean)
 # --- way2: using etlf_input.e# (WRF forecast ensemble)
 # ---       way2 is a correct way!
 # --- ( way1 / way2 )
 # ---
 set ini_etkf_way = way2

 # --- f) control the details of check_max_iv=.true.
 # ---    the default values will remove strong inversion observation
 # ---    this is very bad for sea fog simulation
 # ---    ( this problem is found on 14 Oct 2010, Yushan campus )
 # ---   max_check = .true. / .false.
 # ---
 set max_check = .true.
 set max_T     =  10.0
 set max_UV    =  10.0
 set max_PW    =   5.0
 set max_REF   =   5.0
 set max_RH    =  20.0
 set max_Q     =  10.0
 set max_P     =  10.0
 set max_TB    =   5.0
 set max_TN    =   5.0
 set max_RV    =   5.0
 set max_RF    =   5.0
 set max_BUV   = 500.0
 set max_BT    = 500.0
 set max_BQ    = 500.0
 set max_SLP   = 500.0

 # --- g) control check_rh and sfc_assi_opt
 # --- sfc_assi_opt = 1 (height_diff < 100m. some obs are removed!)
 # --- sfc_assi_opt = 2 (U10, T2m, similarity theory)
 # ---
 # --- check_rh_opt = 0 (No supersaturation check after minimization)
 # --- check_rh_opt = 1 (10-100%, local adjustment of q)
 # --- check_rh_opt = 2 (11-95%,  multi-level q adjustment)
 # ---
 # --- Note: Please use this option with caution, since the results
 # ---       could be very sensitive (sfc_assi_opt)! Default settings:
 # ---       sfc_assi_opt=1 and check_rh_opt=0
 # ---
 set sfc_assi_opt = 1
 set check_rh_opt = 0

 # --- 1.8 Is it a restart run ?
 # ---     Be carefull to use it!   
 # ---     03 Feb 2012, It is OK!
 # ------------------------------
 # ---    ( yes/no, number )
 # ---    ( if no, ${from_step} will be ignored! )
 set restart   = no
 set from_step = 4

 # ====================================================
 # ====      Here, End of Your Modifications!      ====
 # ====      Do not touch anything below !         ====
 # ====================================================

 # ===
 # === Step-2: create neccessary things based on the settings of Step-1
 # ===

 # --- increase the default limit
 limit memorylocked unlimited

 # --- do special thing for testing the codes
 # --- 30 Sep 2012, Yushan campus. Mid-autumn Festival.
 # ---
 if( ${test_prepare_ini_ens} == yes || ${test_run_hybrid_3dvar} == yes ) then
   if( ${test_prepare_ini_ens} == yes && ${test_run_hybrid_3dvar} == yes ) then
       echo '  '
       echo '  Error:'
       echo '    test_prepare_ini_ens and test_run_hybrid_3dvar can be "yes"'
       echo '    at the same time!'
       echo ''
       exit
   endif
   #
   set domain_num       = 1
   set model_date_end   = 2006-03-06_06
   set cycle_intv       = 6
   set cycle_output     = 6
   set wps_case_name    = test
   set ens_members      = 6
   set if_multi_schemes = no
   #
   if( ${test_prepare_ini_ens} == yes && ${test_run_hybrid_3dvar} == no  ) then
     set pert_init_ens = yes
     set ens_method    = 'randomcv'
   endif
   if( ${test_prepare_ini_ens} == no  && ${test_run_hybrid_3dvar} == yes ) then
     set pert_init_ens = no
     set ens_method    = 'ensemble'
     set ensemble_dir  = pert_init_2006030512.ens
   endif
 endif

 # --- Perturbating boundary conditions.
 # --- 22-23 Jul 2012, Yushan campus.
 if( $perturb_bc_prepare == yes && $perturb_bc_create == yes ) then
     echo ' ---- '
     echo ' ---- Warning:'
     echo ' ----   perturb_bc_prepare and perturb_bc_create '
     echo ' ----   can not be yes at the same time !'
     echo ' ----   perturb_bc_prepare is forced to be no !'
     echo ''
     set  perturb_bc_prepare  = no
 endif
 #
 if( $perturb_bc_prepare == yes ) then
    set if_DFI = no
    set pert_init_ens = no
    set pert_fcst_ens = no
    set if_previous_IC_BC = no
    #
    #
    set cycle_intv     = $bg_intv
    set case_name      = ${case_name}_pbc
    set cycle_date_beg = ${cycle_date_end}
    set cycle_date_end = ${model_date_end}
    set date_beg = `echo $model_date_end | cut -c1-10`
    set hour_beg = `echo $model_date_end | cut -c12-13`
    set model_date_end = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $bg_intv hours"`
    #
    set bg_intv_2 = `expr $bg_intv + $bg_intv `
    set met_date1 = ${model_date_end}
    set met_date2 = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $bg_intv_2 hours"`
    #
    # ---      Domain 1 2 3
    set met_file0 = ( 0 0 0 ) # --- the last date-time file
    set met_file1 = ( 0 0 0 ) # --- ${bg_intv} behind
    set met_file2 = ( 0 0 0 ) # --- 2*${bg_intv} behind
    set mnum = 1
    while( $mnum <= 3 )
      set met_file0[$mnum] = met_em.d0${mnum}.${cycle_date_end}:00:00.nc
      set met_file1[$mnum] = met_em.d0${mnum}.${met_date1}:00:00.nc
      set met_file2[$mnum] = met_em.d0${mnum}.${met_date2}:00:00.nc
      set mnum = `expr $mnum + 1`
    end
    #
    set met_dir = ${current_path}/run_wps/RESULT_${wps_case_name}_${bg_type}
    if( -d .add_met_files ) then
        rm -rf .add_met_files
    endif
    mkdir .add_met_files
    if( ! -e ${met_dir}/${met_file1[1]} ) then
      set dnum = 1
      while( $dnum <= $domain_num )
        ncdump ${met_dir}/${met_file0[$dnum]} | sed 's/'${cycle_date_end}'/'${met_date1}'/g' | \
        ncgen -o ${met_file1[$dnum]}
        set dnum = `expr $dnum + 1`
      end
      mv met_em.d0*.nc .add_met_files/
    endif
    #
    if( ! -e ${met_dir}/${met_file2[1]} ) then
      set dnum = 1
      while( $dnum <= $domain_num )
        ncdump ${met_dir}/${met_file0[$dnum]} | sed 's/'${cycle_date_end}'/'${met_date2}'/g' | \
        ncgen -o ${met_file2[$dnum]}
        set dnum = `expr $dnum + 1`
      end
      mv met_em.d0*.nc .add_met_files/
    endif
    #
    # --- do links
    cd ${met_dir}
    ln -sf ../../.add_met_files/* .
    cd  ${current_path}
 endif
 #
 if( $perturb_bc_create == yes ) then
    set cycle_date_beg = pert_beg
    set cycle_date_end = pert_end
    set model_date_end = pert_mod
    #
    set if_DFI            = no
    set ens_method        = 'randomcv'
    set pert_init_ens     = yes
    set pert_fcst_ens     = no
    set if_previous_IC_BC = no
    set cycle_intv        = $bg_intv
    set case_name         = ${case_name}_rbc
    #
    # --- test aim
    #set cycle_date_beg = 2012-03-29_00
    #set cycle_date_end = 2012-03-29_03
    #set model_date_end = 2012-03-29_06
    #
 endif

 # --- 2.0 do check be_cv5.dat, gts_obs and radiance_obs
 # ---      collect all setttings 
 #
 # --- check if NCO is installed or not.
 set if_nco = `which ncatted | grep -c "not found"`
 if( $if_nco > 0 ) then
   echo ''
   echo '  Error:'
   echo '    NCO command "ncatted" is not found.'
   echo '    NCO must be installed!'
   echo ''
   exit
 endif
 # --- check input $1
 if ( $# == 1 && $1 == clean ) then
   if( -e my_settings.msg ) then
     rm -f *.msg *.out .nodefile 
   endif
   if( -e .nodefile ) then
     rm -f .nodefile
   endif
   set date_beg = `echo $cycle_date_beg | cut -c1-10`
   set hour_beg = `echo $cycle_date_beg | cut -c12-13`
   set cycle_num = 1
   set cycle_end_num = 99
   while( $cycle_num <= $cycle_end_num )
     set hr = `expr $cycle_num \* $cycle_intv - $cycle_intv`
     set date_string_1 = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $hr hours"`
     set date_string_2 = `date +%{Y}%{m}%{d}%{H} --date "$date_beg $hour_beg $hr hours"`
     if( $cycle_num == 1 ) then
       echo -n '  Cleaning for Date-Time: '${date_string_1}' '
     else
       echo -n '               Date-Time: '${date_string_1}' '
     endif
     # --- clean
     if( -e .hybrid_etkf_3dvar_pbc.csh ) then
        rm -f .hybrid_etkf_3dvar_pbc.csh
     endif
     if( -e .hybrid_etkf_3dvar_rbc_1.csh ) then
        rm -f .hybrid_etkf_3dvar_rbc*.csh
     endif
     if( -d message_rbc ) then
       rm -rf message_rbc
     endif
     if( -d message_pbc ) then
       rm -rf message_pbc
     endif
     #
     if( $hr >= 0 ) then      
     if( -d run_wrfv3 ) then
       cd run_wrfv3
       if( -d DFI_rsl ) then
         echo -n '.'
         rm -rf DFI_rsl
       endif
       if( -d  ${date_string_2}_ensemble ) then
         echo -n '.'
         rm -rf ${date_string_2}_ensemble
       endif
       if( -e rsl.out.0000 || -e rsl.error.0000 ) then
         echo -n '.'
         foreach rsl_file (`ls rsl.*`)
           rm -f $rsl_file
         end
       endif
       # --- other things
       echo -n '.'
       rm -f .nodefile >& other.msg
       rm -rf *_d0? wrfout_* wrfvar_* fort.* namelist.input* >& other.msg
       rm -f  other.msg
       #
       cd ..
     endif
     #
     if( -d .run_wrfv3_speedup ) then
       cd .run_wrfv3_speedup
       rm -f .nodefile >& other.msg
       rm -rf *_ensemble namelist* *_d0? wrfout_* wrfvar_* >& other.msg
       rm -f  other.msg
       cd ..
     endif
     #
     endif
     #
     if( -d run_hybrid ) then
       cd run_hybrid
       set del_file = (  ${date_string_2} ${date_string_2}_ensemble etkf_hybrid_msg  \
                         etkf_hybrid_result_${date_string_1} VARBC.out wrfvar_output \
                         etkf_${date_string_2} fg fort.11 fort.12 fort.501 )
       set del_num = 1
       while( $del_num <= 11 )
         if( -d ${del_file[$del_num]} || -l ${del_file[$del_num]} || -e ${del_file[$del_num]} ) then        
           echo -n '.'
           rm -rf ${del_file[$del_num]}
         endif
         set del_num = `expr $del_num + 1`
       end
       if( -e rsl.out.0000 || -e rsl.error.0000 ) then
         echo -n '.'
         foreach rsl_file (`ls rsl.*`)
           rm -f $rsl_file
         end
       endif
       # --- other things
       echo -n '.'
       rm -f  .nodefile >& other.msg
       rm -rf ??????????_ensemble etkf_?????????? etkf_hybrid_result_* >& other.msg      
       rm -f fort.* filtered_obs* rej_* unpert* random_*.msg >& other.msg
       rm -f ob.ascii* *_fn_* jo VARBC.out_* statistics      >& other.msg
       rm -f ob.etkf* gts_* *_conv_* *_fn check_* *_check    >& other.msg
       rm -f ep etkf_data.txt ../PBS_run.msg  namelist.*     >& other.msg
       set year_beg = 2000
       set year_end = 2020
       set year = $year_beg
       echo -n '.'
       while( $year <= $year_end )
          rm -rf *${year}* >& other.msg
          set year = `expr $year + 1`
       end
       echo '. OK.'
       rm -f other.msg
       #
       cd ..
     endif
     # --- end of cleaning
     if( $date_string_1 == $cycle_date_end ) then
       echo ''
       break
     endif
     set cycle_num = `expr $cycle_num + 1`
   end
   echo '  --- OK, Cleaning is finished !'
   echo '  ============================================================'
   exit
 endif
 #
 # --- reset if_DFI and if_hot_start
 if( $ics_from_previous == yes ) then
   set if_DFI         = no
   set if_hot_start   = no
 endif
 if( $if_DFI == yes ) then
   set if_hot_start   = no
 endif
 # --- reset Radar settings
 if( $if_radar == no ) then
   set RADAR_W     = .false.
   set RADAR_OBS   = .false.
   set RADAR_RV    = .false.
   set RADAR_RF    = .false.
 endif
 # --- reset use_filtered_obs
 if( $anal_type == 3DVAR ) then
   set use_filtered_obs = no 
 endif
 # --- reset ics_from_previous
 # --- reset if_hot_start
 # --- reset if_DFI
 if( $ens_method == ensemble ) then
   set ics_from_previous = no
   set if_hot_start      = no
   set if_DFI            = no
   set pert_init_ens     = no
   set pert_fcst_ens     = no
 endif
 #
 # --- if_speedup = yes
 if( ${if_speedup} == yes ) then 
   set if_adaptive_time_step = yes
 endif
 #
 # --- reset fixed_time_step
 if( $if_adaptive_time_step == yes ) then
   set fixed_time_step = yes
   set if_adaptive     = .true.
 else
   set if_adaptive     = .false.
 endif
 # --- re-foramt beg_time_step and max_time_step
 set beg_time_step = `echo $beg_time_step | sed 's/ //g'`
 set max_time_step = `echo $max_time_step | sed 's/ //g'`
 set min_step_time = `echo $beg_time_step | sed 's/,/ /g' | awk '{print $1 * 0.5}'`
 set max_step_time = `echo $max_time_step | sed 's/,/ /g' | awk '{print $1}'`
 # --- airsretobs
 if( $use_airsretobs == yes ) then
   set airsret = trUe
 else
   set airsret = falSe
 endif
 # --- airs_bufr_tbl type
 if( $airs_bufr_tbl == auto ) then
   set num1=`date +%s --date 2007-08-14`
   set date_check = `echo $cycle_date_beg | cut -c1-10`
   set num2=`date +%s --date $date_check`
   if( $num2 >= $num1 ) then
     set airs_bufr_tbl = new
   else
     set airs_bufr_tbl = old
   endif
 endif
 # --- hours of wrfda-run and wrf-run
 set date_beg   = `echo $cycle_date_beg | cut -c1-10`
 set hour_beg   = `echo $cycle_date_beg | cut -c12-13`
 set second_beg = `date +%s --date "$date_beg $hour_beg"`
 #
 set date_end   = `echo $cycle_date_end | cut -c1-10`
 set hour_end   = `echo $cycle_date_end | cut -c12-13`
 set second_end = `date +%s --date "$date_end $hour_end"`
 #
 set date_mod   = `echo $model_date_end | cut -c1-10`
 set hour_mod   = `echo $model_date_end | cut -c12-13`
 set second_mod = `date +%s --date "$date_mod $hour_mod"`
 #
 set wrfda_hours  = `expr \( $second_end - $second_beg \) \/ 3600`
 set wrf_hours    = `expr \( $second_mod - $second_end \) \/ 3600`
 #
 # --- give values to physics options if if_multi_schemes=yes
 if( $if_multi_schemes == yes ) then
   #
   # --- check
   #
   set phy_array_element_num = `echo ${#mp_physics}`
   set tot_array_element_num = `expr $phy_array_element_num \* $multi_cycle_num`
   if( $tot_array_element_num != $ens_members ) then
       echo '  Bad News!'
       echo '  You have set if_multi_schemes=yes, but'
       echo '    ens_members           = '${ens_members}
       echo '    phy_array_element_num = '${phy_array_element_num}
       echo '    multi_cycle_num       = '${multi_cycle_num}
       echo '    phy_array_element_num * multi_cycle_num = '${tot_array_element_num}' /= '${ens_members}'!'
       echo '  Please check!'
       echo '  ============================================================'
       exit
   endif
   #
   set mp_physics_tmp         = ( $mp_physics )
   set cu_physics_tmp         = ( $cu_physics )
   set bl_pbl_physics_tmp     = ( $bl_pbl_physics )
   set sf_sfclay_physics_tmp  = ( $sf_sfclay_physics )
   set grav_settling_tmp      = ( $grav_settling )
   set sf_surface_physics_tmp = ( $sf_surface_physics )
   set num_soil_layers_tmp    = ( $num_soil_layers )
   set ra_sw_physics_tmp      = ( $ra_sw_physics )
   set ra_lw_physics_tmp      = ( $ra_lw_physics )
   #
   set multi_cy = 1
   set multi_cycle_num = `expr $multi_cycle_num - 1`
   while ( $multi_cy <= $multi_cycle_num )
      set mp_physics         = ( ${mp_physics_tmp}         ${mp_physics} )
      set cu_physics         = ( ${cu_physics_tmp}         ${cu_physics} )
      set bl_pbl_physics     = ( ${bl_pbl_physics_tmp}     ${bl_pbl_physics} )
      set sf_sfclay_physics  = ( ${sf_sfclay_physics_tmp}  ${sf_sfclay_physics} )
      set grav_settling      = ( ${grav_settling_tmp}      ${grav_settling} )
      set sf_surface_physics = ( ${sf_surface_physics_tmp} ${sf_surface_physics} )
      set num_soil_layers    = ( ${num_soil_layers_tmp}    ${num_soil_layers} )
      set ra_sw_physics      = ( ${ra_sw_physics_tmp}      ${ra_sw_physics} )
      set ra_lw_physics      = ( ${ra_lw_physics_tmp}      ${ra_lw_physics} )
      #
      set multi_cy = `expr $multi_cy + 1`
   end
 endif
 #
 # --- reset physics options if if_multi_schemes = no
 if( $if_multi_schemes == no ) then
   set array_name  = ( mp_physics cu_physics bl_pbl_physics sf_sfclay_physics grav_settling \
                       sf_surface_physics num_soil_layers ra_sw_physics ra_lw_physics )
   set ens_n = 1
   while( $ens_n <= $ens_members )
     if( $ens_n == 1 ) then
       set arr_ini = 'OA'
     else
       set arr_ini = ${arr_ini}'OA'
     endif
     set ens_n = `expr $ens_n + 1`
   end
   set arr_val = ( ${mp_physics[1]}         ${cu_physics[1]}      ${bl_pbl_physics[1]}     \
                   ${sf_sfclay_physics[1]}  ${grav_settling[1]}   ${sf_surface_physics[1]} \
                   ${num_soil_layers[1]}    ${ra_sw_physics[1]}   ${ra_lw_physics[1]} )
   set arr_n = 1
   while( $arr_n <= 9 )
     set brr_ini = `echo ${arr_ini} | sed 's/O/ /g' | sed 's/A/'${arr_val[$arr_n]}'/g'`
     set ${array_name[$arr_n]} = ( ${brr_ini} )
     set arr_n = `expr $arr_n + 1`
   end
   #
   # --- the following old part require a fixed array declaration.
   #set opt_num = 2
   #while ( $opt_num <= ${ens_members} )
   #  set mp_physics[$opt_num]         = ${mp_physics[1]}
   #  set cu_physics[$opt_num]         = ${cu_physics[1]}
   #  set bl_pbl_physics[$opt_num]     = ${bl_pbl_physics[1]}
   #  set sf_sfclay_physics[$opt_num]  = ${sf_sfclay_physics[1]}
   #  set grav_settling[$opt_num]      = ${grav_settling[1]}
   #  set sf_surface_physics[$opt_num] = ${sf_surface_physics[1]}
   #  set num_soil_layers[$opt_num]    = ${num_soil_layers[1]}
   #  set ra_sw_physics[$opt_num]      = ${ra_sw_physics[1]}
   #  set ra_lw_physics[$opt_num]      = ${ra_lw_physics[1]}
   #  # --- next option
   #  set opt_num = `expr $opt_num + 1`
   #end
 endif
 #
 set half_num1 = `expr ${#mp_physics} \/ 2`
 set half_num2 = `expr ${half_num1} + 1`
 #
 # --- reset CPU number if using PBS job
 set machine = `/bin/uname -a | awk '{print $2}'`
 set mpi_opt_check = `echo ${mpi_opt}`
 if( ${input_num} == 2 ) then
   set ncpu_real  = $2
   set ncpu_wrf   = $2
   set ncpu_wrfda = $2
   #
   # --- limit the maximal CPUs for real.exe
   if( $ncpu_real >= $maxcpu_node ) then
     set ncpu_real = $maxcpu_node
   endif
   #
   #
   # --- limit ncpu_wrfda
   if( $maxcpu_wrfda > 0 ) then
     if( $ncpu_wrfda >= $maxcpu_wrfda ) then
       set ncpu_wrfda = $maxcpu_wrfda
     endif
   endif
   #
   # --- put .nodefile for run_hybrid and run_wrfv3
   if( -e .nodefile ) then
     if( -e run_wrfv3/.nodefile ) then
       rm -f run_wrfv3/.nodefile
     endif
     if( -e .run_wrfv3_speedup/.nodefile ) then
       rm -f run_wrfv3/.nodefile
     endif
     if( -e run_hybrid/.nodefile ) then
       rm -f run_hybrid/.nodefile
     endif
     cp -f .nodefile run_wrfv3/
     cp -f .nodefile .run_wrfv3_speedup/
     cp -f .nodefile run_hybrid/
     set mpi_opt_new = `echo $mpi_opt | sed 's/ /#/g'`
     if( $mpi_opt_new == "" ) then
       set mpi_opt_new = "#"
     endif
   else
     set mpi_opt_new = "#"
   endif
 else
   set mpi_opt_new = "#"
   set mpi_opt     = ""
 endif
 #
 # --- check if_put_seed, pert_init_ens and if_previous_IC_BC
 if( $if_put_seed != .true. && $if_put_seed != .false. ) then
   set if_put_seed = .true.
 endif
 if( $pert_init_ens != yes && $pert_init_ens != no ) then
   set pert_init_ens = no
 endif
 if( $if_previous_IC_BC != yes && $if_previous_IC_BC != no ) then
   set if_previous_IC_BC = no
 endif
 #
 # --- if pert_fcst_ens == yes
 if( $pert_fcst_ens != yes && $pert_fcst_ens != no ) then
   set pert_fcst_ens = no
 endif
 if( $pert_fcst_ens == yes ) then
   set hours_ahead    = $pert_ahead_hours
   set cycle_intv     = $hours_ahead
   set cycle_output   = $hours_ahead
   set cycle_date_ens = `echo $cycle_date_beg | sed 's/_/ /g'`
   set cycle_date_beg = `date +%Y-%m-%d_%H --date="$cycle_date_ens $hours_ahead hours ago"`
   set cycle_date_end = `date +%Y-%m-%d_%H --date="$cycle_date_ens $hours_ahead hours" `
   set pert_init_ens     = no
   set if_previous_IC_BC = no
 endif
 #
 # --- make blank gts_obs for pert_init_ens and pert_fcst_ens = yes
 if( $pert_fcst_ens == yes || $pert_init_ens == yes ) then
   set gts_obs_dir = gts_ens
 else
   set gts_obs_dir = gts_obs
 endif
 #
 # --- if if_ndown = yes, then var_type = single_var
 if( $if_ndown == yes ) then
     set da_type       = single_hybrid_etkf
     set wps_case_name = ${wps_case_name}_ndown
     set if_DFI        = no
     set if_hot_start  = no
 endif
 #
 # --- if restart = yes, then if_previous_IC_BC = yes
 if( $restart == yes ) then
   set if_previous_IC_BC = yes
 endif
 # --- collect input information
 #
 cat > ${current_path}/my_setting.msg << EOF

  ==============================================
  ===                                        ===
  === Please check the following settings !  ===
  ===                                        ===
  === Date-Time: `date +%Y-%m-%d_%H:%M`            ===
  ==============================================

  1.1 Working directory:
      ${current_path}

  1.2 var_type       : ${da_type}
      bg_type        : ${bg_type}
      bg_intv        : ${bg_intv} hours
      test_prepare_ini_ens : ${test_prepare_ini_ens}
      test_run_hybrid_3dvar: ${test_run_hybrid_3dvar}

  1.3 case name      : ${case_name}
      wps case name  : ${wps_case_name}
      if_ndown       : ${if_ndown}

  1.4 modelling period
      if_DFI         : ${if_DFI}
      dfi_time_step  : ${dfi_time_step}
      ----------------
      if_hot_start   : ${if_hot_start}
      hot_start_beg  : ${ihot_start_beg}
      ahead_hours    : ${ahead_hours}
      ----------------
      cycle_date_beg : ${cycle_date_beg}
      cycle_date_end : ${cycle_date_end}
      model_date_end : ${model_date_end}
      ----------------
      assimi_window  : ${wrfda_hours} hours
      wrf_run_hours  : ${wrf_hours} hours
      cycle_intv     : ${cycle_intv} hours
      cycle_output   : ${cycle_output} hours
      perturb_bc_pre : ${perturb_bc_prepare}
      perturb_bc_cre : ${perturb_bc_create}

  1.5 mpi run
      machine_name   : ${machine}
      which_mpi      : ${which_mpi}
      job_type       : ${job_type}
      mpi_options    : ${mpi_opt_check}
      numtiles       : ${numtiles}
      ncpu_real      : ${ncpu_real}
      ncpu_wrf       : ${ncpu_wrf}
      ncpu_wrfda     : ${ncpu_wrfda}
      if_speedup     : ${if_speedup}
      if_rsl_time    : ${if_rsl_time}
      ----------------
      maxcpu_node    : ${maxcpu_node}
      ncpu_etkf_ob   : ${ncpu_etkf_ob}
      speedup_obetkf : ${if_speedup_obetkf}

  1.6 control assimilation
      if_control_da  : ${if_control_da}
      steps_detail   : ${if_assimilate}
      ----------------
      if_gts         : ${if_gts}
      use_airsretobs : ${use_airsretobs}
      if_radiance    : ${if_radiance}
      airs_bufr_tbl  : ${airs_bufr_tbl}
      varbc_factor   : ${varbc_factor}
      ----------------
      if_radar       : ${if_radar}
      RADAR_W        : ${RADAR_W}
      RADAR_OBS      : ${RADAR_OBS}
      RADAR_RV       : ${RADAR_RV}
      RADAR_RF       : ${RADAR_RF}

  1.7 control Hybrid-ETKF-3DVAR
      ens_members        : ${ens_members}
      ens_method         : ${ens_method}
      if_put_seed        : ${if_put_seed}
      pert_init_ens      : ${pert_init_ens}
      pert_fcst_ens      : ${pert_fcst_ens}
      pert_ahead_hours   : ${pert_ahead_hours}
      if_previous_IC_BC  : ${if_previous_IC_BC} 
      ensemble_dir       : ${ensemble_dir}
      restart            : ${restart}
      DFI_WRF            : ${DFI_WRF}
      backward_minutes   : ${backward_minutes} min
      forward_minutes    : ${forward_minutes} min
      --------------------
      if_multi_schemes   : ${if_multi_schemes}
      mp_physics         : ${mp_physics[1-${half_num1}]}
                           ${mp_physics[${half_num2}-]}
      cu_physics         : ${cu_physics[1-${half_num1}]}
                           ${cu_physics[${half_num2}-]}
      ---
      bl_pbl_physics     : ${bl_pbl_physics[1-${half_num1}]}
                           ${bl_pbl_physics[${half_num2}-]}
      sf_sfclay_physics  : ${sf_sfclay_physics[1-${half_num1}]}
                           ${sf_sfclay_physics[${half_num2}-]}
      grav_settling      : ${grav_settling[1-${half_num1}]}
                           ${grav_settling[${half_num2}-]}
      ---
      sf_surface_physics : ${sf_surface_physics[1-${half_num1}]}
                           ${sf_surface_physics[${half_num2}-]}
      num_soil_layers    : ${num_soil_layers[1-${half_num1}]}
                           ${num_soil_layers[${half_num2}-]}
      ---
      ra_sw_physics      : ${ra_sw_physics[1-${half_num1}]}
                           ${ra_sw_physics[${half_num2}-]}
      ra_lw_physics      : ${ra_lw_physics[1-${half_num1}]}
                           ${ra_lw_physics[${half_num2}-]}
      ---
      radiation_delt_t   : ${radiation_delt_t} min
      cumulus_delt_t     : ${cumulus_delt_t} min
      sst_update         : ${sst_update}
      if_use_input_w     : ${if_use_input_w}
      ----------------
      ics_from_prevs : ${ics_from_previous}
      prevs_result   : ${where_previous_result}
      prevs_file_name: ${previous_file_name}
      ----------------
      je_factor      : ${je_factor}
      alpha_cor_scale: ${alpha_corr_scale}
      alpha_vertloc  : ${alpha_vertloc}
      print_cost_grad: ${print_cost_grad}
      eps_value      : ${eps_value}
      outer_loop_num : ${outer_loop_num}
      inner_loop_num : ${inner_loop_num}
      ----------------
      cv_number      : ${cv_number}
      len_scale_cv5  : ${len_scale_cv5}
      be_file        : ${be_file}
      ----------------
      nv             : ${nv}
      cv             : `echo ${cv}`
      naccumt1       : ${naccumt1}
      naccumt2       : ${naccumt2}
      nout           : ${nout}
      tainflatinput  : ${tainflatinput}
      rhoinput       : ${rhoinput}
      ----------------
      fixed_time_step: ${fixed_time_step}
      wrf_time_step  : ${wrf_time_step}
      ----------------
      time_step_num  : ${time_step_num}
      time_step (s)  : ${time_step}
      cfl_error      : ${cfl_error}
      kill_all       : ${kill_all}
      total_wait_num : ${total_wait_num}
      second_number1 : ${second_number1}
      second_number2 : ${second_number2}
      ----------------
      if_adaptive    : ${if_adaptive_time_step}
      beg_time_step  : ${beg_time_step}
      max_time_step  : ${max_time_step}
      ----------------
      forecast_type  : ${forecast_type}
      ----------------
      ---------------- normal  | my choices
      ----------------         |
      update_ens_mean: yes     | ${if_update_ens_mean}
      update_mean_way: hybrid  | ${update_ens_mean_way}
      rewrite_mean   : no      | ${rewrite_ens_mean}
      analysis_type  : QC-OBS  | ${anal_type}
      use_filter_obs : yes     | ${use_filtered_obs}
      update_anal_way: etkf    | ${update_anal_way}
      ini_etkf_way   : way2    | ${ini_etkf_way}
      ----------------         
      ---------------- default | my values
      ----------------         |
      check_max_iv   : .true.  | ${max_check}     
      max_T          : 5.0     | ${max_T}
      max_UV         : 5.0     | ${max_UV}
      max_PW         : 5.0     | ${max_PW}
      max_REF        : 5.0     | ${max_REF}
      max_RH         : 5.0     | ${max_RH}
      max_Q          : 5.0     | ${max_Q}
      max_P          : 5.0     | ${max_P}
      max_TB         : 5.0     | ${max_TB}
      max_TN         : 5.0     | ${max_TN}
      max_RV         : 5.0     | ${max_RV}
      max_RF         : 5.0     | ${max_RF}
      max_BUV        : 500.0   | ${max_BUV}
      max_BT         : 500.0   | ${max_BT}
      max_BQ         : 500.0   | ${max_BQ}
      max_SLP        : 500.0   | ${max_SLP}
      ----------------
      sfc_assi_opt   : ${sfc_assi_opt}
      check_rh_opt   : ${check_rh_opt}
  ==============================================
EOF

 # --- check resolution and domain settings
 # --- 19 Jun 2011.
 cd ${current_path}/namelists_linked
 chmod u+x ./check_namelist.csh
 ./check_namelist.csh ${domain_num} ${if_ndown} > /dev/null
 cd ${current_path}
 #
 # --- check some key settings in namelists_linked/check_result.msg
 # --- 14 Jun 2012.
 echo ' ' > .check0
 echo '  --- Compare the following settings carefully! ' >> .check0
 echo '  ----------------------------------------------------' >> .check0
 grep -i e_we namelists_linked/check_result.msg > .check1
 grep -i e_sn namelists_linked/check_result.msg > .check2
 grep  NESTJX namelists_linked/check_result.msg > .check1a
 grep  NESTIX namelists_linked/check_result.msg > .check2a
 grep -i i_parent_start namelists_linked/check_result.msg > .check3
 grep -i j_parent_start namelists_linked/check_result.msg > .check4
 grep -i dx namelists_linked/check_result.msg > .check5
 grep -i dy namelists_linked/check_result.msg > .check6
 grep DIS   namelists_linked/check_result.msg > .check6a
 grep -i e_vert namelists_linked/check_result.msg > .check7
 grep -i ref_lat namelists_linked/check_result.msg > .check8a
 grep -i phic    namelists_linked/check_result.msg > .check8b
 grep -i ref_lon namelists_linked/check_result.msg > .check8c
 grep -i xlonc   namelists_linked/check_result.msg > .check8d
 echo "  ====================================================" > .check9
 cat .check* > hybrid.check
 #
 # --- combine my_settings.msg and check_result.msg
 cat my_setting.msg namelists_linked/check_result.msg hybrid.check \
 > ${current_path}/my_settings.msg
 rm -f my_setting.msg .check* hybrid.check
 #
 #
 set err_num = 0
 if( ! -d ${wrf_run_path} ) then
   echo ''
   echo '   Error:'
   echo '     No this dir : '${wrf_run_path}'!'
   echo '     Please check ${wrf_run_path}!'
   set err_num = `expr $err_num + 1`
 endif
 if( ! -d ${wrf_da_path} ) then
   echo ''
   echo '   Error:'
   echo '     No this dir : '${wrf_da_path}'!'
   echo '     Please check ${wrf_da_path}!'
   set err_num = `expr $err_num + 1`
 endif
 #
 if( $err_num >= 1 ) then
   echo ''
   echo '   Did you do "prepare_my_case.sh hybrid_etkf_3dvar" ?'
   echo ''
   echo '  ============================================================'
   echo ''
   exit
 endif
 #
 cd ${wrf_run_path}
 set err_num = 0
 if( ! -d ../run_wps/RESULT_${wps_case_name}_${bg_type} ) then
   echo ''
   echo '   Error:'
   echo '     ./run_wps/RESULT_'${wps_case_name}_${bg_type}' is not found !'
   echo '     Please check wps_case_name !'
   set err_num = `expr $err_num + 1`
 else
   # --- check if files of domain-1 exist or not
   set check_wps_path = ../run_wps/RESULT_${wps_case_name}_${bg_type}
   if( $if_hot_start == yes ) then
     set date_beg = `echo $ihot_start_beg | cut -c1-10`
     set hour_beg = `echo $ihot_start_beg | cut -c12-13`
   else
     set date_beg = `echo $cycle_date_beg | cut -c1-10`
     set hour_beg = `echo $cycle_date_beg | cut -c12-13`
     if( $da_type == single_hybrid_etkf ) then
       set date_beg = `echo $cycle_date_end | cut -c1-10`
       set hour_beg = `echo $cycle_date_end | cut -c12-13`
     endif
   endif
   # --- check ihot_start_beg setting
   if( $if_hot_start == yes ) then
     set chk_beg = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $ahead_hours hours"`
     if( $chk_beg != $cycle_date_beg ) then
       echo '   Error:'
       echo '     Neither "ihot_start_beg" nor "ahead_hours" is wrong !'
       echo '     Because '${ihot_start_beg}' + '${ahead_hours}' hours != '$cycle_date_beg' !'
       echo ''
       set err_num = `expr $err_num + 1`
     endif
   endif
   #
   set cycle_num     = 1
   set cycle_end_num = 999
   set file_err      = 0
   set wrf_sta       = 0
   set wps_end       = 0
   set date_string   = 0
   while( $cycle_num <= $cycle_end_num )
     if( $date_string == $cycle_date_end ) then
       set wps_end  = ` expr $cycle_num - 1`
       set wrf_sta  = 1
     endif
     if( $wrf_sta == 0 ) then
       set hr = `expr $cycle_num \* $cycle_intv - $cycle_intv`
     else
       set hr = `expr $hr + $bg_intv `
     endif
     set date_string = `date +%{Y}-%{m}-%{d}_%{H} --date "$date_beg $hour_beg $hr hours"`
     set check_wps_file = ${check_wps_path}/met_em.d01.${date_string}:00:00.nc
     if( ! -e $check_wps_file ) then
       if( $file_err == 0 ) then
       echo '   Error:'
       endif
       echo '   No this WPS input file = met_em.d01.'${date_string}:00:00.nc
       set file_err = `expr $file_err + 1`
     endif
     set cycle_num = `expr $cycle_num + 1`
     set cycle_now = `echo $date_string    | cut -c1-4,6-7,9-10,12-13`
     set model_end = `echo $model_date_end | cut -c1-4,6-7,9-10,12-13`
     if( $cycle_now >= $model_end ) then
       break
     endif
   end
   # --- check dimension
   if( $file_err == 0 ) then
     set dim_err = 0
     set d01_file = ${check_wps_path}/met_em.d01.${date_string}:00:00.nc
     set d02_file = ${check_wps_path}/met_em.d02.${date_string}:00:00.nc
     set d03_file = ${check_wps_path}/met_em.d03.${date_string}:00:00.nc
     set do_file = ( $d01_file $d02_file $d03_file )
     set max_dom = $domain_num
     set chk_num = 1
     while ( $chk_num <= $max_dom )
       set chk_file = ${do_file[${chk_num}]}
       set sn_num = `ncdump -h $chk_file | grep "_stag =" | sed -n 1p | awk '{print $3}'`
       set we_num = `ncdump -h $chk_file | grep "_stag =" | sed -n 2p | awk '{print $3}'`
       echo '     domain'$chk_num  $we_num  $sn_num >> .wps_dim
       set chk_num = `expr $chk_num + 1`
     end
     #
     set do_num = 1
     while ( $do_num <= $max_dom )
       if( $if_ndown == yes ) then
         set namelist_file = ../namelists_linked/namelist.input_wrf_ndown
       else
         set namelist_file = ../namelists_linked/namelist.input_wrf
       endif
       set chk_num = `expr $do_num + 2`
       set ok=\$${chk_num}
       set sn_num = `grep -i e_sn $namelist_file | awk "{print $ok }" | sed 's/,//g'`
       set we_num = `grep -i e_we $namelist_file | awk "{print $ok }" | sed 's/,//g'`
       echo '     domain'$do_num  $we_num  $sn_num >> .nam_dim
       set do_num = `expr $do_num + 1`
     end
     diff .wps_dim .nam_dim > .if_ok
     if( -s .if_ok ) then
       echo '   Error:'
       echo "     Dimensions of WPS-input and WRF-namelist don't match!"
       echo '     WPS:    we  sn'
       more .wps_dim
       echo '     WRF:    we  sn'
       more .nam_dim
       set dim_err = 1
     endif
     rm -f .if_ok .wps_dim .nam_dim
     if( $dim_err == 1 ) then
       set err_num = `expr $err_num + 1`
       echo ''
       echo '   Please check '$check_wps_path
       if( $if_ndown == yes ) then
         echo '   Please check settings of namelists_linked/namelist.input_wrf_ndown !'
       else
         echo '   Please check settings of namelists_linked/namelist.input_wrf !'
       endif
     endif
   endif
   #
   if( $file_err >= 1 ) then
     set err_num = `expr $err_num + 1`
     echo ''
     echo '   Check '$check_wps_path
     echo '   Check settings of "periods of cycle-3dvar and simulation"'
     echo '     and settings of "ihot_start_beg" if "if_hot_start=yes"'
   endif
   #
 endif
 #
 #
 # --- check if_put_seed
 if( $ens_method == 'randomcv' ) then
   if( $if_put_seed != '.true.' && $if_put_seed != '.false.' ) then
     echo ' '
     echo '   Error:  $if_put_seed = '${if_put_seed}' is wrong!'
     echo '           It should be .true. or .false.!'
     set err_num = `expr $err_num + 1`
   endif
 endif
 #
 if( ${cv_number} != 3 ) then
   if( ! -e ../obs_be_files/${be_file} ) then
     echo ' '
     echo '   Error: No this obs_be_files/'${be_file}' !'
     set err_num = `expr $err_num + 1`
   endif
 endif
 #
 if( ${if_gts} == "yes" ) then
   if( ! -d ../obs_be_files/${gts_obs_dir} ) then
     echo ' '
     echo '   Error: No this obs_be_files/'${gts_obs_dir}' !'
     echo '          "if_gts = '${if_gts}'" needs it.'
     set err_num = `expr $err_num + 1`
     if( $pert_fcst_ens == yes || $pert_init_ens == yes ) then
         echo '          But, it does not matter, because'
         echo '          $pert_fcst_ens == yes or $pert_init_ens == yes !'
         echo ''
         set err_num = `expr $err_num - 1`
   endif
 endif
 #
 if( ${if_radiance} == "yes" ) then
   if( ! -d ../obs_be_files/radiance_obs ) then
     echo ' '
     echo '   Error: No this obs_be_files/radiance_obs !'
     echo '          "if_radiance = '${if_radiance}'" needs it.'
     set err_num = `expr $err_num + 1`
   endif
 endif
 #
 if( ${if_radar} == "yes" ) then
   if( ! -d ../obs_be_files/radar_obs ) then
     echo ' '
     echo '   Error: No this obs_be_files/radar_obs !'
     echo '          "if_radar = '${if_radar}'" needs it.'
     set err_num = `expr $err_num + 1`
   endif
 endif
 #
 if( ${which_mpi} == 'mpich2' ) then
   set which_mpd = `which mpd | grep -c "not found"`
   if( $which_mpd > 0 ) then
     echo ' '
     echo '   Warning: No mpd for mpirun !'
     echo '            mpich2 version is >= V1.3 ? Check !'
     echo '            Or openmpi shoule be used ? Check !'
     echo ''
     set mpd = no
   else
     set mpd = yes
   endif
 else
   set mpd = no
   mpirun -V >& .mpi_msg
   set if_openmpi = `grep -c Open .mpi_msg`
   rm -f .mpi_msg
   if( $if_openmpi == 0 ) then
     echo ''
     echo '   Error: '
     echo '     you choose which_mpi = openmpi. However,'
     echo '     I can not find correct settings for you to use openmpi.'
     echo '     Please check MPI software settings!'
     echo ''
     set err_num = `expr $err_num + 1`
   endif
 endif
 #
 # --- check of ens_method, update_ens_mean_way and update_anal_way
 if( $ens_method != ensemble && $ens_method != randomcv ) then
     echo ' '
     echo '   Error: input of $ens_method is wrong!'
     echo '          It should be either "ensemble" or "randomcv". Check!'
     set err_num = `expr $err_num + 1`
 endif
 if( $update_ens_mean_way != 3dvar && $update_ens_mean_way != hybrid ) then
     echo ' '
     echo '   Error: input of $update_ens_mean_way is wrong!'
     echo '          It should be either "3dvar" or "hybrid". Check!'
     set err_num = `expr $err_num + 1`
 endif
 if( $update_anal_way != etkf && $update_anal_way != hybrid ) then
     echo ' '
     echo '   Error: input of $update_anal_way is wrong!'
     echo '          It should be either "etkf" or "hybrid". Check!'
     set err_num = `expr $err_num + 1`
 endif
 if( $ens_method  == 'randomcv' && $ics_from_previous == yes ) then
 if( ! -d ${wrf_run_path}/${where_previous_result} ) then
     echo ' '
     echo '   Error: No FCST/3DVAR result for "ens_method=randomcv" !'
     echo '          Does run_wrfv3/'${where_previous_result}' exist?'
     set err_num = `expr $err_num + 1`
 else
     echo '   run_wrfv3/'${where_previous_result}' is there!'
     echo ''
 endif
 endif
 # --- 26 Nov 2010, MU problem is solved!
 #if( ${ini_etkf_way}     == way2 ) then
 #if( ${rewrite_ens_mean} == no   ) then
 #if( ${ics_from_previous}   == no   ) then
 #  set if_mu = `echo $cv | grep MU`
 #  if( $if_mu != '' ) then
 #    echo ''
 #    echo '   Warning: MU included in the CV will cause WRF-CFL error!'
 #    echo ' '
 #  endif
 #endif
 #endif
 #endif
 #
 # --- check of prepared-ensemble input
 if( $ens_method == ensemble ) then
   set temp_day = `echo $cycle_date_beg | cut -c1-10  `
   set temp_hh  = `echo $cycle_date_beg | cut -c12-13 `
   set date_ens = `date +%Y%m%d%H --date "$temp_day $temp_hh"`
   set ens_ini  = ${wrf_run_path}/${ensemble_dir}
   if( ! -d $ens_ini ) then
     echo ' '
     echo '   Error: No '${ensemble_dir}' under ./run_wrfv3 !'
     echo '          "ens_method = ensemble" requires it. Check!'
     set err_num = `expr $err_num + 1`
     if( ${perturb_bc_prepare} == yes ) then
       echo '          However, perturb_bc_prepare = yes, it is ignored! '
       set err_num = `expr $err_num - 1`
     endif
   else
     echo '   Good job!'
     echo '     ./run_wrfv3/'${ensemble_dir}' has already existed'
     echo '     for the option: ens_method = ensemble.'
     echo ''
     if( ${1} == run ) then 
       if( -d ${wrf_run_path}/${date_ens}_ensemble ) then
         rm -rf ${wrf_run_path}/${date_ens}_ensemble
       endif
       #cp -R ${wrf_run_path}/${ensemble_dir} ${wrf_run_path}/${date_ens}_ensemble
       ln -s ${wrf_run_path}/${ensemble_dir} ${wrf_run_path}/${date_ens}_ensemble
     endif
   endif
 endif
 #
 #
 if( $err_num >= 1 ) then
   echo ' '
   echo '  ------------------------------------------------------------'
   echo '   Please check and correct hybrid_etkf_3dvar.csh!'
   echo '                            ~~~~~~~~~~~~~~~~~~~~~~~~'
   echo '   Please carefully review my_settings.msg .'
   echo '                           ~~~~~~~~~~~~~~~'
   echo '  ============================================================'
   exit
 else
   echo '   The '${be_file}', gts_obs or radiance_obs are OK.'
   echo ' '
   #
   # --- do settings  check only
   if( $# == 1  &&  $1 == 'check' ) then
     echo '  ------------------------------------------------------------'
     echo '   DFI_WRF = '${DFI_WRF}' , restart = '${restart} 
     echo '   mpi_opt = "'${mpi_opt_check}'"'
     echo '  ------------------------------------------------------------'
     echo '   Please carefully review my_settings.msg .'
     echo '                           ~~~~~~~~~~~~~~~'
     echo '  ============================================================'
     echo ''
     exit
   endif
   #
 endif


 # --- 2.1 judge which machine and deternime cpu number
 # ---
 set machine = `/bin/uname -a | awk '{print $2}'`
 echo '  =============== Machine : '$machine' ==============='

 # --- 2.2 create directories
 # ---
 cd ${wrf_run_path}
 set case_name=${case_name}'_'${da_type}
 if( -d ${case_name} ) then
   echo ''
   echo '  Warning Info: '
   echo '    this case name "'${case_name}'" has already existed.'
   if( $if_previous_IC_BC == yes ) then
     echo '    It will be used again !'
   else
     echo '    It will be deleted !'
     rm -rf ${case_name}
   endif
   echo ''
   if( $restart == 'yes' ) then
     echo ''
     echo ' It is a restart run ! '
     echo ' It will restart from the step='${from_step}
     echo ''
     echo ' ==== It is a restart run ! '                     >> ${wrf_cost_msg}
     echo ' ==== It will restart from the step='${from_step} >> ${wrf_cost_msg}
     # --- get cycle times
     set cycle_num = `sed -n 1p hybrid_3dvar_wrf_namelists/cycle_info`
     if( $cycle_date_end !=  $model_date_end ) then
       set cycle_num = `expr $cycle_num + 1`
     endif
     # --- start from the step${from_step}
     goto restart_here
     #
   endif 
 else
   echo '' 
   echo '  Warning Info: '
   echo '    '${case_name}' is not found, I have to create new IC-BCs.'
   set if_previous_IC_BC = no
 endif

 # --- 2.3 create namelist.input files
 # ---     Please do test beforehand by yourself.
 # ---
 # --- time label
 date +' Starting Time: '%Y-%m-%d_%H:%M:%S          > ${wrf_cost_msg}
 echo  '   '                                       >> ${wrf_cost_msg}
 #
 # --- 0) especially for hot start use
 # ---    27 Dec 2010, Yushan campus.
 if( $if_hot_start == yes ) then
   echo  ' ==== Produce WRF hot-start result for cycle-3dvar'  >> ${wrf_cost_msg}
   set time1 = `date +%s`
   # --- namelist
   set domain_num_h = 1
   cd ${wrf_run_path}/hybrid_3dvar_wrf_namelists 
   chmod u+x create_wrf_namelists.csh
   set wps_case_name_h = ${wps_case_name}_${bg_type}
   ./create_wrf_namelists.csh $ihot_start_beg $cycle_date_beg $model_date_end \
                              $ahead_hours $ahead_hours $wps_case_name_h      \
                              $sst_update $domain_num_h $numtiles $bg_intv    \
                              $if_use_input_w $if_ndown
   # --- multiple schemes
   set mps  = ${mp_physics[1]}
   set lays = ${sf_sfclay_physics[1]}
   set sfcs = ${sf_surface_physics[1]}
   set pbls = ${bl_pbl_physics[1]}
   set gras = ${grav_settling[1]}
   set cups = ${cu_physics[1]}
   set rass = ${ra_sw_physics[1]}
   set rals = ${ra_lw_physics[1]}
   set nsol = ${num_soil_layers[1]}
   set radt = ${radiation_delt_t}
   set cutt = ${cumulus_delt_t}
   mv -f namelist.input_step1 namelist.input_multiple
   sed 's/mps/'${mps}'/g' namelist.input_multiple | \ 
   sed 's/lays/'${lays}'/g' | \
   sed 's/sfcs/'${sfcs}'/g' | \
   sed 's/nsol/'${nsol}'/g' | \
   sed 's/gras/'${gras}'/g' | \
   sed 's/cups/'${cups}'/g' | \
   sed 's/cutt/'${cutt}'/g' | \
   sed 's/rass/'${rass}'/g' | \
   sed 's/rals/'${rals}'/g' | \
   sed 's/ra_dt/'${radt}'/g'| \
   sed 's/pbls/'${pbls}'/g' > namelist.input_step1
   rm -f namelist.input_multiple
   #
   mv -f namelist.input_step1 ../namelist.input_hot
   rm -f cycle_info
   # --- real.exe and wrf.exe
   cd ${wrf_run_path}
   sed 's/\!write_input/write_input/g' namelist.input_hot | \
   sed 's/time_step_second/'${time_step[1]}'/g' > namelist.input
   rm -f namelist.input_hot
   #
   # --- adpative time-step
   mv -f namelist.input namelist.input_adaptive
   sed 's/if_adaptive/'${if_adaptive}'/g'  namelist.input_adaptive | \
   sed 's/-5,-4,-3/'${max_time_step}'/g'   | \
   sed 's/-3,-4,-5/'${beg_time_step}'/g' > namelist.input
   rm -f namelist.input_adaptive
   #
   # --- check num_metgrid_soil_levels
   set syear  = `grep " start_" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-4`
   set smonth = `grep " start_" namelist.input | sed -n 2p | awk '{print $3}' | cut -c1-2`
   set sday   = `grep " start_" namelist.input | sed -n 3p | awk '{print $3}' | cut -c1-2`
   set shour  = `grep " start_" namelist.input | sed -n 4p | awk '{print $3}' | cut -c1-2`
   set sdate_string   =  ${syear}-${smonth}-${sday}_${shour}
   set check_wps_file = ${check_wps_path}/met_em.d01.${sdate_string}:00:00.nc
   set soil_num       = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
   sed 's/SOILNUM/'${soil_num}'/g' namelist.input > namelist.input_soil
   rm -f namelist.input
   mv -f namelist.input_soil namelist.input
   #
   if( $which_mpi == 'openmpi' ) then
     mpirun -np ${ncpu_real} ${mpi_opt} real.exe
     mpirun -np ${ncpu_wrf}  ${mpi_opt} wrf.exe
   endif
   if( $which_mpi == 'mpich2' ) then
     mpirun -l -n ${ncpu_real} real.exe < /dev/null
     mpirun -l -n ${ncpu_wrf}  wrf.exe  < /dev/null
   endif
   set check_hot_file = wrfout_d01_${cycle_date_beg}:00:00
   if( -e $check_hot_file ) then
     set hot_file = hot_file_${cycle_date_beg}
     mv -f $check_hot_file hot_file_${cycle_date_beg}
     rm -f rsl.* wrfout_*
     if( $sst_update == 1 ) then
       rm -f wrflowinp_d01
     endif
   else
     echo ''
     echo '   Bad news!'
     echo '   No this hot-file: '${check_hot_file}' to force cycle-3dvar!'
     echo ''
     rm -f rsl.* wrfout_*
     exit
   endif
   set time2 = `date +%s`
   set time_cost = `expr $time2 - $time1`
   if( $if_rsl_time == yes ) then
     set time_rsl = `grep -i 'elapsed seconds' rsl.error.0000|sed 's/elapsed seconds.//g'|awk '{sum +=$NF} END {print sum}'`
     set time_cost = ${time_cost}', '${time_rsl}
   endif
   echo '        cost_time: ('$time_cost's)'  >> ${wrf_cost_msg}
   echo '' >>  ${wrf_cost_msg}
 endif
 #
 # --- a) WRFV3
 cd ${wrf_run_path}/hybrid_3dvar_wrf_namelists 
 chmod u+x create_wrf_namelists.csh 
 set wps_case_name = ${wps_case_name}_${bg_type}
 ./create_wrf_namelists.csh $cycle_date_beg $cycle_date_end $model_date_end \
                            $cycle_intv $cycle_output $wps_case_name        \
                            $sst_update $domain_num   $numtiles $bg_intv    \
                            $if_use_input_w $if_ndown
 #
 # --- adpative time-step
 set nml_num = 1
 foreach namelist_file (`ls namelist.input_step*`)
   sed 's/if_adaptive/'${if_adaptive}'/g'  namelist.input_step${nml_num} | \
   sed 's/-5,-4,-3/'${max_time_step}'/g'   | \
   sed 's/-3,-4,-5/'${beg_time_step}'/g' > namelist.input_temp
   rm -f namelist.input_step${nml_num}
   mv -f namelist.input_temp namelist.input_step${nml_num}
   #
   # ---- reset cycling in namelist.input
   if( ${ics_from_previous} == yes || ${ens_method} == ensemble ) then
     mv namelist.input_step${nml_num}  namelist.input_cyling
     sed 's/cycling              = .false./cycling              = .true./g' \
         namelist.input_cyling > namelist.input_temp
     rm -f namelist.input_cyling
     mv -f namelist.input_temp namelist.input_step${nml_num}
   endif
   #
   set nml_num = `expr $nml_num + 1`
 end
 #
 # ---
 # --- b) WRFDA --- Hybrid-ETKF-3DVAR
 cd ${wrf_da_path}/cycling_hybrid_3dvar_namelists
 #
 # --- control radar and airsretobs assimilation
 # --- control the details of check_max_iv=.true.
 sed 's/RADAR_W/'${RADAR_W}'/g'     namelist.input_base | \
 sed 's/RADAR_OBS/'${RADAR_OBS}'/g'   | \
 sed 's/RADAR_RV/'${RADAR_RV}'/g'     | \
 sed 's/RADAR_RF/'${RADAR_RF}'/g'     | \
 sed 's/trUe/'${airsret}'/g'          | \
 sed 's/anal_type/'${anal_type}'/g'   | \
 sed 's/max_check/'${max_check}'/g'   | \
 sed 's/max_T/'${max_T}'/g'           | \
 sed 's/max_UV/'${max_UV}'/g'         | \
 sed 's/max_PW/'${max_PW}'/g'         | \
 sed 's/max_REF/'${max_REF}'/g'       | \
 sed 's/max_RH/'${max_RH}'/g'         | \
 sed 's/max_Q/'${max_Q}'/g'           | \
 sed 's/max_P/'${max_P}'/g'           | \
 sed 's/max_RT/'${max_TB}'/g'         | \
 sed 's/max_NS/'${max_TN}'/g'         | \
 sed 's/max_RV/'${max_RV}'/g'         | \
 sed 's/max_RF/'${max_RF}'/g'         | \
 sed 's/max_BUV/'${max_BUV}'/g'       | \
 sed 's/max_BT/'${max_BT}'/g'         | \
 sed 's/max_BQ/'${max_BQ}'/g'         | \
 sed 's/max_SLP/'${max_SLP}'/g'       | \
 sed 's/degrad/'${print_cost_grad}'/g'| \
 sed 's/eps_value/'${eps_value}'/g'   | \
 sed 's/outer_loop_num/'${outer_loop_num}'/g'   | \
 sed 's/inner_loop_num/'${inner_loop_num}'/g'   | \
 sed 's/bcfactor/'${varbc_factor}'/g' | \
 sed 's/RH_CHECK/'${check_rh_opt}'/g' | \
 sed 's/AS_CHECK/'${sfc_assi_opt}'/g' > namelist.input_temp
 #
 # --- crtm_atmosphere is not used in V3.3, but used in V3.2
 # --- judge WRFDA version
 #ls ${wrf_da_path}/radiance_info -l > wrfda_dir
 #set README_DA_dir = `sed 's/\/var\/run\/radiance_info//g' wrfda_dir | awk '{print $NF}'`
 set README_DA_dir = ../../.WRF_MODEL/WRFDA
 if( -e ${README_DA_dir}/README.VAR ) then
   grep V3.3 ${README_DA_dir}/README.VAR > if_new_ver
 endif
 if( -e ${README_DA_dir}/README.DA ) then
   grep V3.3 ${README_DA_dir}/README.DA > if_new_ver
 endif
 if ( ! -s if_new_ver ) then
   sed 's/\!crtm_atmosphere/crtm_atmosphere/g' namelist.input_temp \
       > namelist.input_temp_v321
   rm -f namelist.input_temp
   mv namelist.input_temp_v321 namelist.input_temp
 endif
 rm -f if_new_ver wrfda_dir
 # --- end of judging WRFDA version
 #
 set mps  = ${mp_physics[1]} 
 set lays = ${sf_sfclay_physics[1]}
 set sfcs = ${sf_surface_physics[1]}
 set pbls = ${bl_pbl_physics[1]}
 set cups = ${cu_physics[1]}
 set rass = ${ra_sw_physics[1]}
 set rals = ${ra_lw_physics[1]}
 set nsol = ${num_soil_layers[1]}
 set radt = ${radiation_delt_t}
 set cutt = ${cumulus_delt_t}
 chmod u+x create_da_namelists.csh
 ./create_da_namelists.csh $cycle_date_beg $cycle_date_end      \
                           $cycle_intv     $cv_number $numtiles \
                           ${je_factor}    ${alpha_corr_scale}  ${alpha_vertloc} \
                           ${mps}  ${lays} ${sfcs} ${pbls}      \
                           ${cups} ${rass} ${rals} ${radt} ${nsol} ${cutt}
 rm -f namelist.input_temp
 #
 # --- link gmao_airs_bufr.tbl
 cd ..
 ln -sf gmao_airs_bufr.tbl_${airs_bufr_tbl}  gmao_airs_bufr.tbl
 #
 cd ${wrf_run_path}

 # --- 2.4 get cycle times
 set cycle_num = `sed -n 1p hybrid_3dvar_wrf_namelists/cycle_info`
 if( $cycle_date_end !=  $model_date_end ) then
     set cycle_num = `expr $cycle_num + 1`
 endif

 if( $if_previous_IC_BC == no ) then
   mkdir ${case_name}
   set num = 1 
   while ( $num <= $cycle_num ) 
     mkdir ${case_name}/3dvar_step${num}
     mkdir ${case_name}/3dvar_step${num}/3dvar_result
     set num = ` expr $num + 1 `
   end
 endif
 #
 echo '   You want to do cycling Hybrid-ETKF-3DVAR! Is it right?!'
 echo '   I want to do '$da_type' !'

 # ===
 # === Step-3: under ${wrf_run_path}, run real.exe step by step 
 # ===         in order to get wrfbdy_d01 and wrfinput_d02

 # --- 3.1 do clean
 # ---
 if( -e namelist.input ) then
   rm -f namelist.input
 endif
 if( -e wrflowinp_d01 ) then
   rm -f wrflowinp_d01
 endif
 if( -e wrfinput_d01 ) then
   rm -f wrfinput_d01
 endif
 #
 if( $domain_num >= 1 ) then
   set wrfinput_d02  = ''
   set wrflowinp_d02 = ''
   set wrfinput_d03  = ''
   set wrflowinp_d03 = ''
 endif
 if( $domain_num >= 2 ) then
   if( -e wrfinput_d02 ) then
     rm -f wrfinput_d02
   endif
   if( -e wrflowinp_d02 ) then
     rm -f wrflowinp_d02
   endif
   # --- set variables for domain2
   set wrfinput_d02  = wrfinput_d02
   set wrflowinp_d02 = wrflowinp_d02
   #
   if( $domain_num == 3 ) then 
     if( -e wrfinput_d03 ) then
       rm -f wrfinput_d03
     endif
     if( -e wrflowinp_d03 ) then
       rm -f wrflowinp_d03
     endif
     # --- set variables for domain3
     set wrfinput_d03  = wrfinput_d03
     set wrflowinp_d03 = wrflowinp_d03
   endif
 endif

 # --- 3.2 cycling_hybrid_etkf
 # ---     produce initial-boundary conditions
 # ---
 if( $which_mpi == 'mpich2' && $mpd == yes ) then
   mpd &
   sleep 3
 endif
 #
 # --- time label
 echo ' ==== Start to produce initial and boundary conditions'  >> ${wrf_cost_msg}
 set time1 = `date +%s`
 #
 if( $if_previous_IC_BC == no ) then
 if( ${da_type} == 'cycling_hybrid_etkf' || ${da_type} == 'single_hybrid_etkf' ) then
   #
   if( ${da_type} == 'single_hybrid_etkf' ) then
     set num_beg = $cycle_num 
   else
     set num_beg = 1
   endif
   #
   set num = $num_beg
   while ( $num <= $cycle_num )
     # --- do not need initial conditions now
     # --- 10 Aug 2010.
     if( $num == 0 ) then 
       echo ''
       echo '  --- Produce initial-boundary conditions for cycle-'$num
       cp -f hybrid_3dvar_wrf_namelists/namelist.input_step1 ./namelist.input
       if( $which_mpi == 'openmpi' ) then
         mpirun -np ${ncpu_real}  ${mpi_opt} real.exe
       endif
       if( $which_mpi == 'mpich2' ) then
         mpirun -l -n ${ncpu_real} real.exe < /dev/null 2>& ../my_mpi_run.msg 
       endif

       mv wrfbdy_d01 wrfinput_d01 ${wrfinput_d02} ${case_name}/3dvar_step1/
       mv namelist.input ${case_name}/3dvar_step1/3dvar_result
       if( $sst_update == 1 ) then
         cp wrflowinp_d01 ${wrflowinp_d02} ${wrflowinp_d03} ${case_name}/3dvar_step1/
         mv wrflowinp_d01 ${wrflowinp_d02} ${wrflowinp_d03} ${case_name}/3dvar_step1/3dvar_result
       endif
       rm -f rsl.*
     else
       echo ''
       echo '  --- Produce initial/boundary conditions for cycle-'$num
       if( $ens_method  == 'randomcv' ) then
       if( ${num} == 1 ) then
         echo '  --- initial conditions for perturbation for ensemble.'
       endif
       endif
       echo '  --- initial conditions for updating BC after 3DVAR.'
       cp -f hybrid_3dvar_wrf_namelists/namelist.input_step${num} ./namelist.input
       # --- for intel compiler, 23 Jun 2011.
       sed 's/time_step_second/10/g' namelist.input > namelist.input_intel
       mv -f namelist.input_intel namelist.input
       # --- end
       #
       # --- multiple schemes
       set mps  = ${mp_physics[1]}
       set lays = ${sf_sfclay_physics[1]}
       set sfcs = ${sf_surface_physics[1]}
       set pbls = ${bl_pbl_physics[1]}
       set gras = ${grav_settling[1]}
       set cups = ${cu_physics[1]}
       set rass = ${ra_sw_physics[1]}
       set rals = ${ra_lw_physics[1]}
       set nsol = ${num_soil_layers[1]}
       set radt = ${radiation_delt_t}
       set cutt = ${cumulus_delt_t}
       mv -f namelist.input namelist.input_multiple
       sed 's/mps/'${mps}'/g' namelist.input_multiple | \
       sed 's/lays/'${lays}'/g' | \
       sed 's/sfcs/'${sfcs}'/g' | \
       sed 's/nsol/'${nsol}'/g' | \
       sed 's/gras/'${gras}'/g' | \
       sed 's/cups/'${cups}'/g' | \
       sed 's/cutt/'${cutt}'/g' | \
       sed 's/rass/'${rass}'/g' | \
       sed 's/rals/'${rals}'/g' | \
       sed 's/ra_dt/'${radt}'/g'| \
       sed 's/pbls/'${pbls}'/g' > namelist.input
       rm -f namelist.input_multiple
       #
       # --- check num_metgrid_soil_levels
       set syear  = `grep " start_" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-4`
       set smonth = `grep " start_" namelist.input | sed -n 2p | awk '{print $3}' | cut -c1-2`
       set sday   = `grep " start_" namelist.input | sed -n 3p | awk '{print $3}' | cut -c1-2`
       set shour  = `grep " start_" namelist.input | sed -n 4p | awk '{print $3}' | cut -c1-2`
       set sdate_string   =  ${syear}-${smonth}-${sday}_${shour}
       set check_wps_file = ${check_wps_path}/met_em.d01.${sdate_string}:00:00.nc
       set soil_num       = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
       sed 's/SOILNUM/'${soil_num}'/g' namelist.input > namelist.input_soil
       if ( $num == $cycle_num ) then
          set soil_cycle_num = $soil_num
       endif
       rm -f namelist.input
       mv -f namelist.input_soil namelist.input
       if( $which_mpi == 'openmpi' ) then
         mpirun -np ${ncpu_real}  ${mpi_opt} real.exe 
       endif
       if( $which_mpi == 'mpich2' ) then
         mpirun -l -n ${ncpu_real} real.exe < /dev/null  2>>& ../my_mpi_run.msg
       endif
       #
       # --- use DFI, 24 Feb 2011.
       if( $num == 1 && $if_DFI == yes ) then
         cp -f namelist.input namelist.input_normal
         set dfi_beg1 = `date +%Y --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg2 = `date +%m --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg3 = `date +%d --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg4 = `date +%H --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_end1 = $syear
         set dfi_end2 = $smonth
         set dfi_end3 = $sday
         set dfi_end4 = $shour
         set run_end1 = `date +%Y --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end2 = `date +%m --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end3 = `date +%d --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end4 = `date +%H --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_hrs = `grep " run_hours" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-2`
         #
         sed 's/dfi_opt = 0/dfi_opt = 3/g' namelist.input     | \
         sed 's/constant_bc = .false./constant_bc = .true./g' | \
         sed 's/9991/'${dfi_beg1}'/g' | \
         sed 's/9992/'${dfi_beg2}'/g' | \
         sed 's/9993/'${dfi_beg3}'/g' | \
         sed 's/9994/'${dfi_beg4}'/g' | \
         sed 's/8881/'${dfi_end1}'/g' | \
         sed 's/8882/'${dfi_end2}'/g' | \
         sed 's/8883/'${dfi_end3}'/g' | \
         sed 's/8884/'${dfi_end4}'/g' | \
         sed 's/time_step_dfi = 0/time_step_dfi = '${dfi_time_step}'/g'| \
         sed 's/max_dom              = 2/max_dom              = 1/g'   | \
         sed 's/run_hours            = '${run_hrs}'/run_hours = 0/g'   | \
         sed 's/sst_update            = 1/sst_update            = 0/g' | \
         sed 's/end_year             = '${run_end1}'/end_year             = '${syear}'/g'  | \
         sed 's/end_month            = '${run_end2}'/end_month            = '${smonth}'/g' | \
         sed 's/end_day              = '${run_end3}'/end_day              = '${sday}'/g'   | \
         sed 's/end_hour             = '${run_end4}'/end_hour             = '${shour}'/g'    \
         > namelist.input_dfi
         mv -f namelist.input_dfi namelist.input
         #
         # --- DFI does not like use_input_w
         if( $if_use_input_w == 'yes' ) then
             sed 's/use_input_w/\!use_input_w/g' namelist.input > namelist.input_w
             mv -f namelist.input_w namelist.input
         endif
         #
         rm -f rsl.*
         if( $if_use_DFI_result == no ) then
           if( $which_mpi == 'openmpi' ) then
             mpirun -np ${ncpu_wrf}  ${mpi_opt} wrf.exe
           endif
           if( $which_mpi == 'mpich2' ) then
             mpirun -l -n ${ncpu_wrf} wrf.exe < /dev/null
           endif
           if( -d DFI_rsl ) then
             rm -rf DFI_rsl
           endif
           mkdir DFI_rsl
           mv rsl.* DFI_rsl
           #
           #mv -f wrfinput_d01 wrfinput_d01_bc
           mv -f namelist.input_normal namelist.input
           if( -e wrfinput_initialized_d01 ) then
             set ok_size=`ls -l wrfinput_initialized_d01 | awk '{print $5}'`
             if( $ok_size < 1000000 ) then
               echo '  ' >> ${wrf_cost_msg}
               echo '  Error in doing DFI !' >> ${wrf_cost_msg}
               echo '  Please increase dfi_time_dim in namelist.input_wrf.' \
                    >> ${wrf_cost_msg}
               echo '  Or decrease dfi_time_step in hybrid_etkf_3dvar.csh' \
                    >> ${wrf_cost_msg}
               echo '  ' >> ${wrf_cost_msg}
               exit
             else
               rm -f wrfinput_d01
               mv -f wrfinput_initialized_d01 wrfinput_d01
             endif
           endif
         else
           #mv -f wrfinput_d01 wrfinput_d01_bc
           mv -f namelist.input_normal namelist.input
           rm -f wrfinput_d01
           cp -f ${DFI_result_file} wrfinput_d01
         endif
         #
       endif
       # --- 19 Aug 2010.
       if( $num < $cycle_num ) then
         set wrfinput_d02_hybrid = ''
       else
         set wrfinput_d02_hybrid = $wrfinput_d02
       endif
       # --- for intel compiler, 23 Jun 2011.
       sed 's/time_step            = 10/time_step            = time_step_second/g' \
           namelist.input > namelist.input_intel
       mv -f namelist.input_intel namelist.input
       # --- end
       mv wrfbdy_d01 wrfinput_d01 ${wrfinput_d02_hybrid} ${case_name}/3dvar_step${num}/
       mv namelist.input ${case_name}/3dvar_step${num}/3dvar_result
       if( $sst_update == 1 ) then
         if( $num < $cycle_num ) then
           cp wrflowinp_d01 ${case_name}/3dvar_step${num}/
           mv wrflowinp_d01 ${case_name}/3dvar_step${num}/3dvar_result
         else
           cp wrflowinp_d01 ${wrflowinp_d02} ${wrflowinp_d03} ${case_name}/3dvar_step${num}/
           mv wrflowinp_d01 ${wrflowinp_d02} ${wrflowinp_d03} ${case_name}/3dvar_step${num}/3dvar_result
         endif
       endif
       rm -f ${wrfinput_d02}
       rm -f rsl.*
       #
       # --- use the previous forecast/3DVAR result, 22 Nov 2010, 14 Dec 2010.
       if( ${ics_from_previous} == yes && ${num} == 1 ) then
         mv ${case_name}/3dvar_step${num}/wrfinput_d01     \
            ${case_name}/3dvar_step${num}/wrfinput_d01_bc
         cp ${where_previous_result}/${previous_file_name} \
            ${case_name}/3dvar_step${num}/wrfinput_d01 
         if( ${previous_file_name} == wrfinput_d01 ) then
           cp -f ${where_previous_result}/wrfbdy_d01   ${case_name}/3dvar_step${num}/ 
           rm -f ${case_name}/3dvar_step${num}/wrfinput_d01_bc
         endif
       endif
       #
       # --- use the previous forecast for hot-start cycle-3DVAR, 27 Dec 2010.
       if( ${if_hot_start} == yes && ${num} == 1 ) then
         mv ${case_name}/3dvar_step${num}/wrfinput_d01     \
            ${case_name}/3dvar_step${num}/wrfinput_d01_bc
         cp ${wrf_run_path}/${hot_file} \
            ${case_name}/3dvar_step${num}/wrfinput_d01
         endif
       endif
       #
     endif
     #
     set num = ` expr $num + 1 `
   end
   #
 endif
 endif
 if( $perturb_bc_prepare == yes ) then
    echo ' '   >> ${wrf_cost_msg}
    echo '     perturb_bc_prepare == yes'        >> ${wrf_cost_msg}
    echo '     See ./run_wrfv3/'${case_name}' !' >> ${wrf_cost_msg}
    exit
 endif
 # --- ndown, 03 Nov 2011, Yushan campus.
 if( $if_ndown == yes ) then
     goto end_output
 endif
 #
 if( $if_previous_IC_BC == yes ) then
   echo '      IC_BCs in '${case_name}' will be used.' >> ${wrf_cost_msg}
   # --- check num_metgrid_soil_levels
   set syear  = `echo $cycle_date_end | cut -c1-4`
   set smonth = `echo $cycle_date_end | cut -c6-7`
   set sday   = `echo $cycle_date_end | cut -c9-10`
   set shour  = `echo $cycle_date_end | cut -c12-13`
   set sdate_string   = ${syear}-${smonth}-${sday}_${shour}
   set check_wps_file = ${check_wps_path}/met_em.d01.${sdate_string}:00:00.nc
   set soil_cycle_num = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
 endif
 set time2 = `date +%s`
 set time_cost = `expr $time2 - $time1`
 echo '        cost_time: ('$time_cost's)'  >> ${wrf_cost_msg}

 # ===
 # === Step-4: run hybrid_etkf_3dvar.sh and wrf.exe step by step 
 # ===

 if( $da_type == single_hybrid_etkf ) then
   goto final_step
 endif

 # ---
 # --- 4.1 Cycling Hybrid-ETKF-3DVAR starts below
 # ---
 set num = 1
 if( $restart == 'yes' ) then
   label restart_here
   set num = ${from_step}
   set nout = `expr ${from_step} - 1`
   # --- 30 Jan 2012. If restart is activated, get etkf_data.txt from the previous step
   set re_date_beg = `echo $cycle_date_beg | cut -c1-10`
   set re_hour_beg = `echo $cycle_date_beg | cut -c12-13`
   set re_hr = `expr \( $num - 2 \) \* $cycle_intv `
   set date_string_previous = `date +%{Y}%{m}%{d}%{H} --date "$re_date_beg $re_hour_beg $re_hr hours"`
   cp -f ${wrf_da_path}/etkf_${date_string_previous}/etkf_data.txt ${wrf_da_path}/
   #
   # --- get soil_cycle_num for later use
   set r_date_string = `date +%{Y}-%{m}-%{d}_%{H} --date "$re_date_beg $re_hour_beg $re_hr hours"`
   set check_wps_file = ${check_wps_path}/met_em.d01.${r_date_string}:00:00.nc
   set soil_cycle_num = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
   #
   # --- do clean: delete the previous result (01 Feb 2012)
   cd ${wrf_da_path}
   set del_num = ${from_step}
   while ( $del_num <= 99 )
     set re_date_beg = `echo $cycle_date_beg | cut -c1-10`
     set re_hour_beg = `echo $cycle_date_beg | cut -c12-13`
     set re_hr = `expr \( $del_num - 1 \) \* $cycle_intv `
     set date_string_previous_1 = `date +%{Y}%{m}%{d}%{H} --date "$re_date_beg $re_hour_beg $re_hr hours"`
     set date_string_previous_2 = `date +%{Y}-%{m-}%{d_}%{H} --date "$re_date_beg $re_hour_beg $re_hr hours"`
     #
     set del_file1 = ${date_string_previous_1}
     set del_file2 = ${del_file1}_ensemble
     set del_file3 = etkf_${del_file1}
     set del_file4 = etkf_hybrid_result_${date_string_previous_2}
     set del_file5 = ${del_file4}_ensemble
     #
     # --- start to do clean
     set del_file = ( ${del_file1} ${del_file2} ${del_file3} ${del_file4} ${del_file5} )
     set delnum = 1
     while( $delnum <= 5 )
       if( -d ${del_file[$delnum]} || -l ${del_file[$delnum]} || -e ${del_file[$delnum]} ) then
         rm -rf ${del_file[$delnum]}
       endif
       set delnum = `expr $delnum + 1`
     end
     #
     set del_num = `expr $del_num + 1`
     if( ${date_string_previous_2} == ${cycle_date_end} ) then
       break
     endif
   end
   #
   cd ${wrf_run_path}
 endif
 #
 set end_step  = `expr ${cycle_num} + 1`
 while( $num < ${end_step} )
   #
   # --- The final step is done later, we need not do it here.
   # --- If we do, a lot of time will be wasted, especially for large ensemble.
   # --- Morning on 24 Feb 2012, Yushan campus.
   if( $forecast_type == det_fcst && $num == ${cycle_num} && ${ens_method} == 'ensemble') then
       set if_nout_added = no
       break
   else
       set if_nout_added = yes
   endif
   #
   echo ' ==== Cycle No. '$num
   echo ' ---- hybrid-3dvar'
   #
   echo ''                                 >> ${wrf_cost_msg}
   echo ' ==== Cycle No. '$num             >> ${wrf_cost_msg}
   if( $num == ${cycle_num} ) then
       echo '        This step is for ensemble forecast' >> ${wrf_cost_msg}
   endif
   date +'        Time: '%Y-%m-%d_%H:%M:%S >> ${wrf_cost_msg}
   echo '        --- run Hybrid-ETKF-3DVAR (ens_members='${ens_members}')' >> ${wrf_cost_msg}
   # 
   # --- run hybrid_etkf_3dvar.sh
   cd ${wrf_da_path}
   if( $num == 1 ) then
     set anal_time_init      = ${cycle_date_beg}
     set anal_time_init_next = `sed -n 2p ../run_wrfv3/hybrid_3dvar_wrf_namelists/cycle_info`
   else
     set num_next = `expr $num + 1`
     set anal_time_init      = `sed -n ${num}p ../run_wrfv3/hybrid_3dvar_wrf_namelists/cycle_info`
     set anal_time_init_next = `sed -n ${num_next}p ../run_wrfv3/hybrid_3dvar_wrf_namelists/cycle_info`
   endif
   set anal_time      = `echo $anal_time_init | cut -c1-4,6-7,9-10,12-13`
   set anal_time_next = `echo $anal_time_init_next | cut -c1-4,6-7,9-10,12-13`
   # --- echo date-time
   echo '            . Date-Time = '${anal_time_init} >> ${wrf_cost_msg}
   # 
   echo ' ---- If assimilated ? (1: Yes; 0: No ) == '${if_assimilate[${num}]}
   if( -e ${anal_time}_ensemble ) then
     rm -rf ${anal_time}_ensemble
   endif
   #
   # --- determine the way to produce ensemble forecasts at the first cycle
   set produce_ens = no
   if( $num == 1 ) then
     if( ${ens_method} == 'randomcv' ) then 
       set produce_ens = yes
     endif
   else
     set produce_ens = no
   endif
   if( $produce_ens == no ) then
     if( -d ${anal_time}_ensemble ) then
       rm -rf ${anal_time}_ensemble
     endif
     ln -s ../run_wrfv3/${anal_time}_ensemble .
   endif
   #
   set mark = 0
   #
   # --- 20 Nov 2010. After reading Wang Xuguang's email, I suddenly get the idea.
   set nout = `expr $nout + 1`
   # --- End of Modification
   #
   ./hybrid_etkf_3dvar.sh   ${anal_time}_ensemble  $ens_members ${anal_time}  \
                            $be_file    $if_radiance ${if_assimilate[${num}]} \
                            $which_mpi  $numtiles    $ncpu_wrfda    \
                            $num        ${case_name} $mark  $nv $cv \
                            $naccumt1   $naccumt2    $nout          \
                            $tainflatinput $rhoinput $if_update_ens_mean    \
                            ${if_radar} ${if_gts}    ${update_ens_mean_way} \
                            ${cv_number} ${produce_ens} ${ens_method}       \
                            ${use_filtered_obs}      ${cycle_intv}          \
                            ${rewrite_ens_mean}      ${update_anal_way}     \
                            ${wrf_hours} ${domain_num} ${anal_type}         \
                            ${ics_from_previous}     ${ini_etkf_way}  ${len_scale_cv5} \
                            ${if_put_seed}           ${pert_init_ens} ${gts_obs_dir}   \
                            ${mpi_opt_new}           ${ncpu_etkf_ob}  ${alpha_vertloc} \
                            ${if_speedup_obetkf}
   if( $pert_init_ens == yes ) then
     #cp hybrid_etkf_ens.csh ${anal_time}_ensemble/random_ensemble_msg
     cd ${wrf_run_path}
     if( -d pert_init_${anal_time}.ens ) then
       rm -rf pert_init_${anal_time}.ens
     endif
     mv ../run_hybrid/${anal_time}_ensemble pert_init_${anal_time}.ens
     echo ' '   >> ${wrf_cost_msg}
     echo '     pert_init_ens == yes'                         >> ${wrf_cost_msg}
     echo '     See ./run_wrfv3/pert_init_'${anal_time}'.ens' >> ${wrf_cost_msg}
     exit
   endif
   if( $num == ${cycle_num} ) then
     break
   else
     if( $pert_fcst_ens == yes && $anal_time_init_next == ${cycle_date_end} ) then
       cd ${wrf_run_path}
       if( -d pert_fcst_${anal_time}.ens ) then
         rm -rf pert_fcst_${anal_time}.ens
       endif
       mv ${anal_time}_ensemble pert_fcst_${anal_time}.ens
       echo ' '   >> ${wrf_cost_msg}
       echo '     pert_fcst_ens == yes'                         >> ${wrf_cost_msg}
       echo '     See ./run_wrfv3/pert_fcst_'${anal_time}'.ens' >> ${wrf_cost_msg} 
       exit
     endif
   endif  
   # 
   # --- run wrf.exe
   echo ' ---- wrf.exe '
   echo '  '                               >> ${wrf_cost_msg}
   date +'        Time: '%Y-%m-%d_%H:%M:%S >> ${wrf_cost_msg}
   echo '        --- run WRF (ens_members='$ens_members')'  >> ${wrf_cost_msg}
   echo '            time = '${anal_time_init}' --> '${anal_time_init_next} >> ${wrf_cost_msg}
   if( $if_adaptive_time_step == yes ) then
     echo '            Adaptive time step for WRF run' >> ${wrf_cost_msg}
   else
     if( $fixed_time_step == yes ) then
       echo '            Fixed time step for WRF run' >> ${wrf_cost_msg}
     else
       echo '            Multiple fixed time steps for WRF run' >> ${wrf_cost_msg}
     endif
   endif
   cd ${wrf_run_path}
   # ---     start LOOP for every member
   #
   # ---
   # --- DO speedup
   # --- if_speedup = yes, 17 Sep 2012, Yushan campus.
   if( ${if_speedup} == yes ) then
     set half_ens = `expr ${ens_members}  \/ 2`
     #
     # --- create namelist.input files
     set num_wrf = 1
     while ( $num_wrf <= $half_ens )
       if( $num_wrf < 10 ) then
         set e_num = 00$num_wrf
       else if( $num_wrf < 100 ) then
         set e_num = 0$num_wrf
       else
         set e_num = $num_wrf
       endif
       #
       cp -f  hybrid_3dvar_wrf_namelists/namelist.input_step${num} namelist.input
       sed 's/time_step_second/'${time_step[1]}'/g' namelist.input > namelist.input_time_step
       mv -f namelist.input_time_step namelist.input
       # --- 28 Nov 2010, write out input_formatted output for 3DVAR use
       sed 's/\!write_input/write_input/g' namelist.input > namelist.input_3dvar
       mv -f namelist.input_3dvar namelist.input
       #
       # --- check num_metgrid_soil_levels
       set syear  = `grep " start_" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-4`
       set smonth = `grep " start_" namelist.input | sed -n 2p | awk '{print $3}' | cut -c1-2`
       set sday   = `grep " start_" namelist.input | sed -n 3p | awk '{print $3}' | cut -c1-2`
       set shour  = `grep " start_" namelist.input | sed -n 4p | awk '{print $3}' | cut -c1-2`
       set sdate_string   =  ${syear}-${smonth}-${sday}_${shour}
       set check_wps_file = ${check_wps_path}/met_em.d01.${sdate_string}:00:00.nc
       set soil_num       = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
       sed 's/SOILNUM/'${soil_num}'/g' namelist.input > namelist.input_soil
       rm -f namelist.input
       mv -f namelist.input_soil namelist.input
       #
       # --- multiple schemes
       if( ${if_multi_schemes} == yes ) then
         set mps  = ${mp_physics[$num_wrf]}
         set lays = ${sf_sfclay_physics[$num_wrf]}
         set sfcs = ${sf_surface_physics[$num_wrf]}
         set pbls = ${bl_pbl_physics[$num_wrf]}
         set gras = ${grav_settling[$num_wrf]}
         set cups = ${cu_physics[$num_wrf]}
         set rass = ${ra_sw_physics[$num_wrf]}
         set rals = ${ra_lw_physics[$num_wrf]}
         set nsol = ${num_soil_layers[$num_wrf]}
       else
         set mps  = ${mp_physics[1]}
         set lays = ${sf_sfclay_physics[1]}
         set sfcs = ${sf_surface_physics[1]}
         set pbls = ${bl_pbl_physics[1]}
         set gras = ${grav_settling[1]}
         set cups = ${cu_physics[1]}
         set rass = ${ra_sw_physics[1]}
         set rals = ${ra_lw_physics[1]}
         set nsol = ${num_soil_layers[1]}
       endif
       set radt = ${radiation_delt_t}
       set cutt = ${cumulus_delt_t}
       mv -f namelist.input namelist.input_multiple
       sed 's/mps/'${mps}'/g' namelist.input_multiple | \
       sed 's/lays/'${lays}'/g' | \
       sed 's/sfcs/'${sfcs}'/g' | \
       sed 's/nsol/'${nsol}'/g' | \
       sed 's/gras/'${gras}'/g' | \
       sed 's/cups/'${cups}'/g' | \
       sed 's/cutt/'${cutt}'/g' | \
       sed 's/rass/'${rass}'/g' | \
       sed 's/rals/'${rals}'/g' | \
       sed 's/ra_dt/'${radt}'/g'| \
       sed 's/pbls/'${pbls}'/g' > namelist.input
       rm -f namelist.input_multiple
       #
       if( -e ../.run_wrfv3_speedup/namelist.input.e${e_num} ) then
         rm -f ../.run_wrfv3_speedup/namelist.input.e${e_num}
       endif
       mv namelist.input ../.run_wrfv3_speedup/namelist.input.e${e_num}
       #
       # --- if sst_update=1, then
       if( $num_wrf == 1 && $sst_update == 1 ) then
         cd ../.run_wrfv3_speedup
         if( -e wrflowinp_d01 ) then
           rm -f wrflowinp_d01
         endif
         ln -sf ../run_wrfv3/${case_name}/3dvar_step${num}/wrflowinp_d01 .
         cd ../run_wrfv3
       endif
       #
       set num_wrf = `expr ${num_wrf} + 1`
     end
     #
     # --- enter ../.run_wrfv3_speedup to run wrf.exe by calling speedup.sh
     #
     set half_ncpu_wrf = `expr ${ncpu_wrf} \/ 2`
     cd  ../.run_wrfv3_speedup
     chmod u+x speedup.sh
     nohup ./speedup.sh ${wrf_cost_msg}  ${anal_time_init} ${anal_time_init_next} ${anal_time_next}   \
           ${half_ens}  ${half_ncpu_wrf} ${min_step_time}  ${max_step_time} ${if_rsl_time} ${mpi_opt_new} &
     cd  ../run_wrfv3
     #
     # --- for the next while-loop if_speedup = yes.
     set num_wrf      = `expr ${half_ens} + 1`
     set ncpu_wrf_ens = ${half_ncpu_wrf} 
     #
     # --- the first-half of .nodefile is used
     if( -e ../.nodefile ) then
       set total_cpus = `wc -l ../.nodefile | awk '{print $1}'`
       set half_cpus  = `expr ${total_cpus} \/ 2`
       sed -n '1, '${half_cpus}'p' ../.nodefile > .nodefile
     endif
     #
   else
     # --- for the next while-loop if_speedup = no.
     set num_wrf      = 1
     set ncpu_wrf_ens = ${ncpu_wrf} 
   endif
   #
   while ( $num_wrf <= $ens_members )
     if( $num_wrf < 10 ) then
       set e_num = 00$num_wrf
     else if( $num_wrf < 100 ) then
       set e_num = 0$num_wrf
     else
       set e_num = $num_wrf
     endif
     #
     # ---- get initial and boundary conditions    
     set init_bdy_dir = ../run_hybrid/etkf_hybrid_result_${anal_time_init} 
     #
     # --- do link to save disk space and time
     # --- cp -f  ${init_bdy_dir}/e${e_num}/* .
     #
     ln -sf  ${init_bdy_dir}/e${e_num}/* .
     #
     echo '   --- run wrf, Member No. '$num_wrf
     #
     # --- use different time steps to run wrf.exe
     #
     if( ${fixed_time_step} == yes ) then
       set time_step_num  = 1
       #set total_wait_num = 0 
     endif
     set time1 = `date +%s`
     set step_num = 1
     while( $step_num <= $time_step_num ) 
       #
       # --- do clean and prepare
       set ens_dir = ${anal_time_next}_ensemble/${anal_time_next}.e${e_num}
       if( -d $ens_dir ) then
         rm -rf $ens_dir
       endif
       mkdir -p $ens_dir
       set check_wrf = wrfout_d01_${anal_time_init_next}:00:00 
       set check_var = wrfvar_d01_${anal_time_init_next}:00:00
       if( -e $check_wrf ) then
         rm -f $check_wrf
       endif
       if( -e $check_var ) then
         rm -f $check_var
       endif
       #
       # --- run wrf.exe
       if( -e rsl.out.0000 ) then
         rm -f  rsl.*
       endif
       cp -f  hybrid_3dvar_wrf_namelists/namelist.input_step${num} namelist.input
       sed 's/time_step_second/'${time_step[$step_num]}'/g' namelist.input > namelist.input_time_step
       mv -f namelist.input_time_step namelist.input
       # --- 28 Nov 2010, write out input_formatted output for 3DVAR use
       sed 's/\!write_input/write_input/g' namelist.input > namelist.input_3dvar
       mv -f namelist.input_3dvar namelist.input
       #
       # --- check num_metgrid_soil_levels
       set syear  = `grep " start_" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-4`
       set smonth = `grep " start_" namelist.input | sed -n 2p | awk '{print $3}' | cut -c1-2`
       set sday   = `grep " start_" namelist.input | sed -n 3p | awk '{print $3}' | cut -c1-2`
       set shour  = `grep " start_" namelist.input | sed -n 4p | awk '{print $3}' | cut -c1-2`
       set sdate_string   =  ${syear}-${smonth}-${sday}_${shour}
       set check_wps_file = ${check_wps_path}/met_em.d01.${sdate_string}:00:00.nc
       set soil_num       = `ncdump -h $check_wps_file | grep -i FLAG_SM | wc | awk '{print $1}'`
       sed 's/SOILNUM/'${soil_num}'/g' namelist.input > namelist.input_soil
       rm -f namelist.input
       mv -f namelist.input_soil namelist.input
       #
       # --- if sst_update=1, then ... (23 Dec 2010)
       if( $sst_update == 1 ) then
         if( -e wrflowinp_d01 ) then
           rm -f wrflowinp_d01
         endif
         ln -sf ${case_name}/3dvar_step${num}/wrflowinp_d01 .
       endif
       #
       # --- multiple schemes
       if( ${if_multi_schemes} == yes ) then
         set mps  = ${mp_physics[$num_wrf]}
         set lays = ${sf_sfclay_physics[$num_wrf]}
         set sfcs = ${sf_surface_physics[$num_wrf]}
         set pbls = ${bl_pbl_physics[$num_wrf]}
         set gras = ${grav_settling[$num_wrf]}
         set cups = ${cu_physics[$num_wrf]}
         set rass = ${ra_sw_physics[$num_wrf]}
         set rals = ${ra_lw_physics[$num_wrf]}
         set nsol = ${num_soil_layers[$num_wrf]}
       else
         set mps  = ${mp_physics[1]}
         set lays = ${sf_sfclay_physics[1]}
         set sfcs = ${sf_surface_physics[1]}
         set pbls = ${bl_pbl_physics[1]}
         set gras = ${grav_settling[1]}
         set cups = ${cu_physics[1]}
         set rass = ${ra_sw_physics[1]}
         set rals = ${ra_lw_physics[1]}
         set nsol = ${num_soil_layers[1]}
       endif
       set radt = ${radiation_delt_t}
       set cutt = ${cumulus_delt_t}
       mv -f namelist.input namelist.input_multiple
       sed 's/mps/'${mps}'/g' namelist.input_multiple | \
       sed 's/lays/'${lays}'/g' | \
       sed 's/sfcs/'${sfcs}'/g' | \
       sed 's/nsol/'${nsol}'/g' | \
       sed 's/gras/'${gras}'/g' | \
       sed 's/cups/'${cups}'/g' | \
       sed 's/cutt/'${cutt}'/g' | \
       sed 's/rass/'${rass}'/g' | \
       sed 's/rals/'${rals}'/g' | \
       sed 's/ra_dt/'${radt}'/g'| \
       sed 's/pbls/'${pbls}'/g' > namelist.input
       rm -f namelist.input_multiple
       # --- test DFI aim
       if( $DFI_WRF == yes ) then 
         set dfi_time1 = `date +%s`
         cp -f namelist.input namelist.input_normal
         set dfi_beg1 = `date +%Y --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg2 = `date +%m --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg3 = `date +%d --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_beg4 = `date +%H --date "${syear}${smonth}${sday} ${shour} 1 hours ago"`
         set dfi_end1 = $syear
         set dfi_end2 = $smonth
         set dfi_end3 = $sday
         set dfi_end4 = $shour
         set run_end1 = `date +%Y --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end2 = `date +%m --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end3 = `date +%d --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_end4 = `date +%H --date "${syear}${smonth}${sday} ${shour} ${cycle_intv} hours"`
         set run_hrs = `grep " run_hours" namelist.input | sed -n 1p | awk '{print $3}' | cut -c1-2`
         #
         set bck_min = `expr 60 - ${backward_minutes}`
         set fwd_min = ${forward_minutes}
         sed 's/dfi_opt = 0/dfi_opt = 3/g' namelist.input     | \
         sed 's/constant_bc = .false./constant_bc = .true./g' | \
         sed 's/9991/'${dfi_beg1}'/g' | \
         sed 's/9992/'${dfi_beg2}'/g' | \
         sed 's/9993/'${dfi_beg3}'/g' | \
         sed 's/9994/'${dfi_beg4}'/g' | \
         sed 's/8881/'${dfi_end1}'/g' | \
         sed 's/8882/'${dfi_end2}'/g' | \
         sed 's/8883/'${dfi_end3}'/g' | \
         sed 's/8884/'${dfi_end4}'/g' | \
         sed 's/dfi_bckstop_minute        = 00/dfi_bckstop_minute        = '${bck_min}'/g' | \
         sed 's/dfi_fwdstop_minute        = 30/dfi_fwdstop_minute        = '${fwd_min}'/g' | \
         sed 's/time_step_dfi = 0/time_step_dfi = '${dfi_time_step}'/g'| \
         sed 's/max_dom              = 2/max_dom              = 1/g'   | \
         sed 's/run_hours            = '${run_hrs}'/run_hours = 0/g'   | \
         sed 's/sst_update            = 1/sst_update            = 0/g' | \
         sed 's/end_year             = '${run_end1}'/end_year             = '${syear}'/g'  | \
         sed 's/end_month            = '${run_end2}'/end_month            = '${smonth}'/g' | \
         sed 's/end_day              = '${run_end3}'/end_day              = '${sday}'/g'   | \
         sed 's/end_hour             = '${run_end4}'/end_hour             = '${shour}'/g'    \
         > namelist.input_dfi
         mv -f namelist.input_dfi namelist.input
         #
         # --- DFI does not like use_input_w
         if( $if_use_input_w == 'yes' ) then
             sed 's/use_input_w/\!use_input_w/g' namelist.input > namelist.input_w
             mv -f namelist.input_w namelist.input
         endif
         #
         if( -e wrfinput_initialized_d01 ) then
           rm -f wrfinput_initialized_d01
         endif
         if( $which_mpi == 'openmpi' ) then
           mpirun -np ${ncpu_wrf_ens}  ${mpi_opt} wrf.exe
         endif
         if( $which_mpi == 'mpich2' ) then
           mpirun -l -n ${ncpu_wrf_ens} wrf.exe < /dev/null
         endif
         #
         if( -e wrfinput_initialized_d01 ) then
           set ok_size=`ls -l wrfinput_initialized_d01 | awk '{print $5}'`
           if( $ok_size < 1000000 ) then
             echo '  ' >> ${wrf_cost_msg}
             echo '  Error in doing DFI_WRF !' >> ${wrf_cost_msg}
             echo '  Please increase dfi_time_dim in namelist.input_wrf.' \
                  >> ${wrf_cost_msg}
             echo '  Or decrease dfi_time_step in hybrid_etkf_3dvar.csh' \
                  >> ${wrf_cost_msg}
             echo '  ' >> ${wrf_cost_msg}
             exit
           else
             # --- we have to update the boundary conditions
             # --- do this thing under a temparary dir named temp_bdy
             if( -d temp_bdy ) then
               rm -rf temp_bdy
             endif
             mkdir temp_bdy
             cd temp_bdy
             ln -s ../wrfinput_initialized_d01 wrfvar_output
             ln -s ../wrfinput_d01             fg
             cp -f ../wrfbdy_d01               wrfbdy_d01
             cp ../../run_hybrid/cycling_hybrid_3dvar_namelists/parame.in_cycling parame.in
             ln -s ../../run_hybrid/da_update_bc.exe .
             ./da_update_bc.exe > bdy.msg
             cd ..
             #
             # --- update some files
             cp -f  namelist.input temp_bdy/namelist.input_DFI
             rm -f  wrfinput_d01 wrfbdy_d01 namelist.input
             mv -f  wrfinput_initialized_d01 wrfinput_d01
             mv -f  temp_bdy/wrfbdy_d01      wrfbdy_d01
             mv -f  namelist.input_normal namelist.input
             # --- save temp_bdy for checking
             #mv temp_bdy temp_bdy.e${e_num}
             rm -rf temp_bdy
             #
           endif
         endif
         #
         set dfi_time2 = `date +%s`
         set dfi_time_cost = `expr $dfi_time2 - $dfi_time1`
         #
       endif
       #
       if( ${fixed_time_step} == yes ) then
         if( $which_mpi == 'openmpi' ) then
           mpirun -np ${ncpu_wrf_ens}  ${mpi_opt} wrf.exe
         endif
         if( $which_mpi == 'mpich2' ) then
           mpirun -l -n ${ncpu_wrf_ens} wrf.exe < /dev/null   2>>& ../my_mpi_run.msg
         endif
       endif
       if( ${fixed_time_step} == no ) then
         if( $which_mpi == 'openmpi' ) then
           mpirun -np ${ncpu_wrf}  ${mpi_opt}  wrf.exe &
         endif
         if( $which_mpi == 'mpich2' ) then
           mpirun -l -n ${ncpu_wrf} wrf.exe < /dev/null   2>>& ../my_mpi_run.msg &
         endif
         sleep 5
       endif
       #
       # --- save result for hybrid-3dvar of next cycle
       # --- Due to CFL >= 1, sometimes wrf.exe is keeping dead !
       # --- If this happens, kill wrf.exe !
       set wait_num = 0
       while( $wait_num <= $total_wait_num )
         if( -e $check_var ) then
           set w_num = 0
           while( $w_num <= 999 )
             set if_SUCCESS = `grep -h -c "SUCCESS COMPLETE" rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
             if( $if_SUCCESS > 0 ) then
               break
             else
               sleep 0.5s
             endif
             set w_num = `expr $w_num + 1`
           end
           set time2 = `date +%s`
           set time_cost = `expr $time2 - $time1`
           if( $if_rsl_time == yes ) then
             set time_rsl = `grep -i 'elapsed seconds' rsl.error.0000|sed 's/elapsed seconds.//g'|awk '{sum +=$NF} END {print sum}'`
             set time_cost = ${time_cost}', '${time_rsl}
           endif
           if( $DFI_WRF == yes ) then
               set time_cost = $time_cost's, DFI-'${dfi_time_cost}
           endif
           mv -f $check_var  ${ens_dir}/${check_wrf}
           rm -f wrf???_d01_${anal_time_init}:00:00
           if( $num_wrf < 10 ) then
             set wrf_head = 'Member No.0'${num_wrf}
           else
             set wrf_head = 'Member No.'${num_wrf}
           endif
           if( ${if_adaptive_time_step} == yes ) then
               echo '            '${wrf_head}' (time_step='${min_step_time}'-'${max_step_time}'s) ('${time_cost}'s)' >> ${wrf_cost_msg}
           else
             set display_time = ${time_step[$step_num]}
             if( $display_time < 100 ) then
               set display_time = ' '${display_time}
             endif
             echo '            '${wrf_head}' (time_step='${display_time}'s) ('${time_cost}'s)' >> ${wrf_cost_msg}
           endif
           set step_num = `expr $time_step_num + 1`
           break
         else
           # --- judge if mismatch 
           set if_mis = `grep -h -c "mismatch" rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
           if( $if_mis > 0 ) then
             echo  '                   "Mismatch" has happened!' >> ${wrf_cost_msg}
             echo  '                   Please see details in run_wrfv3/rsl.error.0000 !' >> ${wrf_cost_msg}
             exit
           endif
           # --- judge if successfully ends
           set if_end = `grep -h -c "SUCCESS COMPLETE" rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
           if( $if_end > 0 ) then
             # --- 09 Oct 2011, Yushan campus.
             # --- if adaptive time-step is used, sometimes WRF result file is like *:00:10,
             # --- then force to rename it like *:00:00
             # ---
             # --- Do not use "wrfvar_d01_${anal_time_init_next}:00:??" !
             # ---
             foreach wrf_file_shift ( `ls wrfvar_d01_${anal_time_init_next}:00:*` )
               if( ${wrf_file_shift} != ${check_var} ) then
                   mv -f ${wrf_file_shift} ${check_var}
                   echo '  '
                   echo '  Warning:'
                   echo '    I meet this file = '${wrf_file_shift}' !'
                   echo '    It is renamed to = '${check_var}
                   echo '  '
               endif
             end
             #break
           else
             # --- check rsl.*.0000
             set cfl = good
             if( $cfl_error == yes ) then 
               set cfl_check1 = `grep -h -c cfl rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
               set cfl_check2 = `grep -h -c NaN rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
               set cfl_check  = `expr $cfl_check1 + $cfl_check2`
               if( $cfl_check > 0 ) then
        	 set cfl = bad
               endif
             endif
             # --- if rsl.out.0000/rsl.error.0000 does not increase size,
             # --- then I think wrf.exe is dead!
             if( $cfl == good ) then
             if( -e rsl.out.0000 ) then
               #
               # --- old method
               #set size1 = `ls -l ${check_cfl_file} | awk '{print $5}'`
               #sleep $second_number1
               #set size2 = `ls -l ${check_cfl_file} | awk '{print $5}'`
               #
               # --- new method: total size of all rsl.* files
               set size1 = `ls -l rsl.* | awk '{print $5}' | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'` 
               sleep $second_number1
               set size2 = `ls -l rsl.* | awk '{print $5}' | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'` 
               if( $size2 == $size1 ) then
        	 set cfl = bad
               endif
               #
               set if_end = `grep -h -c "COMPLETE WRF" rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
               if( $if_end > 0 ) then
                 set cfl = good
                 break
               endif
               set cfl_check1 = `grep -h -c cfl rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}'`
               set cfl_check2 = `grep -h -c NaN rsl.* | awk '{for (i=0;i<NF;i++) s=s+$i } ; END {print s}' `
               set cfl_check  = `expr $cfl_check1 + $cfl_check2`
               if( $cfl_check > 0 ) then
                 set cfl = bad
               else
                 set cfl = good
               endif
             endif
             endif
             # --- kill and use shorter time step
             if( $cfl == bad ) then
               set who = `whoami`
               ps -u $who | grep -i wrf.exe > check_wrf_run
               if( $kill_all == no ) then 
                 #
                 # --- killing the first one is OK !
                 # --- need not kill all !
        	 set kill_id = `sed -n 1p check_wrf_run | awk '{print $1}'`
        	 kill -9 $kill_id
               else
        	 set wrf_num = 1
        	 while( $wrf_num <= ${ncpu_wrf} )
                   set kill_id = `sed -n ${wrf_num}p check_wrf_run | awk '{print $1}'`
                   kill -9 $kill_id
                   set wrf_num = `expr $wrf_num + 1`
        	 end
               endif
               rm -f check_wrf_run
               break
             else
               sleep $second_number2
             endif
           endif
           #
         endif
         # --- next waiting
         set wait_num = `expr $wait_num + 1`
       end
       # --- next step
       set step_num = `expr $step_num + 1`
     end
     # --- check the WRF run result
     if( ! -e ${ens_dir}/$check_wrf ) then
         echo ''
         echo ' Error: '
         echo '   Bad news! wrf.exe failed.'
         echo '   Cycle  No.'${num}
         echo '     wrf  No.'${num_wrf}
         echo '   time_step:'${time_step[$step_num]}
         echo ''
         exit
     endif
     #
     # --- next member
     set num_wrf = `expr $num_wrf + 1`
   end
   #
   # --- collect the result from speedup.sh in .run_wrfv3_speedup
   if( ${if_speedup} == 'yes' ) then
     cd ${wrf_run_path}
     #
     if( $ens_members < 10 ) then
       set e_num1 = 00${ens_members}
     else if( $ens_members < 100 ) then
       set e_num1 = 0${ens_members}
     else
       set e_num1 = ${ens_members}
     endif
     #
     if( $half_ens < 10 ) then
       set e_num2 = 00${half_ens}
     else if( $half_ens < 100 ) then
       set e_num2 = 0${half_ens}
     else
       set e_num2 = ${half_ens}
     endif
     #
     set ens_end1 = ${anal_time_next}_ensemble/${anal_time_next}.e${e_num1}
     set ens_end2 = ../.run_wrfv3_speedup/${anal_time_next}_ensemble/${anal_time_next}.e${e_num2}
     #
     set wait_num = 0
     while( ${wait_num} <= 1000 )
       if( -e ${ens_end1}/${check_wrf} && -e ${ens_end2}/${check_wrf} ) then
         sleep 5s
         mv  ../.run_wrfv3_speedup/${anal_time_next}_ensemble/*.e??? \
             ${anal_time_next}_ensemble/
         rm -rf ../.run_wrfv3_speedup/*_ensemble
         break
       else
         sleep 10s
       endif
       set wait_num = `expr ${wait_num} + 1`
     end
   endif
   #
   # --- next cycle
   set num = ` expr $num + 1 `
   #
 end
 
 # --- 4.3 for the final cycle !
 #
 # --- run hybrid_etkf_3dvar.sh
 if( $da_type == single_hybrid_etkf ) then
   label final_step
   echo ' ---- Single Hybrid-ETKF-3DVAR is running ...'
   echo ' ---- If assimilated ? (1: Yes; 0: No ) == '${if_assimilate[${cycle_num}]}
   set forecast_type = 'det_fcst'
 endif
 if( $forecast_type == 'det_fcst' || $forecast_type == 'all_fcst' ) then
   #
   echo ''                                  >> ${wrf_cost_msg}
   echo ' ==== Hybrid-ETKF especially for forecast_type="det_fcst".' >> ${wrf_cost_msg}
   echo ' ==== Cycle No. '${cycle_num}
   echo ' ==== Cycle No. '${cycle_num}       >> ${wrf_cost_msg}
   date +'        Time: '%Y-%m-%d_%H:%M:%S   >> ${wrf_cost_msg}
   echo '        --- run Hybrid-ETKF-3DVAR (ens_members='${ens_members}')' >> ${wrf_cost_msg}
   #
   # --- determine time step for WRF run
   cd ${wrf_run_path}
   cp -f  hybrid_3dvar_wrf_namelists/namelist.input_step${cycle_num} namelist.input
   # --- soil_cycle_num for the last cycle
   sed 's/SOILNUM/'${soil_cycle_num}'/g' namelist.input > namelist.input_soil 
   mv -f namelist.input_soil namelist.input
   # --- use the schemes of the first column 
   set mps  = ${mp_physics[1]}
   set lays = ${sf_sfclay_physics[1]}
   set sfcs = ${sf_surface_physics[1]}
   set pbls = ${bl_pbl_physics[1]}
   set gras = ${grav_settling[1]}
   set cups = ${cu_physics[1]}
   set rass = ${ra_sw_physics[1]}
   set rals = ${ra_lw_physics[1]}
   set nsol = ${num_soil_layers[1]}
   set radt = ${radiation_delt_t}
   set cutt = ${cumulus_delt_t}
   mv -f namelist.input namelist.input_multiple
   sed 's/mps/'${mps}'/g' namelist.input_multiple | \
   sed 's/lays/'${lays}'/g' | \
   sed 's/sfcs/'${sfcs}'/g' | \
   sed 's/nsol/'${nsol}'/g' | \
   sed 's/gras/'${gras}'/g' | \
   sed 's/cups/'${cups}'/g' | \
   sed 's/cutt/'${cutt}'/g' | \
   sed 's/rass/'${rass}'/g' | \
   sed 's/rals/'${rals}'/g' | \
   sed 's/ra_dt/'${radt}'/g'| \
   sed 's/pbls/'${pbls}'/g' > namelist.input
   rm -f namelist.input_multiple
   #
   sed 's/time_step_second/'${time_step[1]}'/g' namelist.input > namelist.input_time_step
   cp -f namelist.input_time_step  hybrid_3dvar_wrf_namelists/namelist.input_step${cycle_num}
   mv -f namelist.input_time_step  ${case_name}/3dvar_step${cycle_num}/3dvar_result/
   rm -f namelist.input
   #
   cd ${wrf_da_path}
   set mark           = 1
   set num            = ${cycle_num}
   set anal_time_init = `sed -n ${num}p ../run_wrfv3/hybrid_3dvar_wrf_namelists/cycle_info`
   set anal_time      = `echo $anal_time_init | cut -c1-4,6-7,9-10,12-13`
   set update_ens_mean_way = 'hybrid'
   #
   echo ' ------ '${if_assimilate[${num}]}
   if( -e ${anal_time}_ensemble ) then
     rm -f ${anal_time}_ensemble
   endif
   #
   set produce_ens = no
   if( $da_type == single_hybrid_etkf ) then
     if( ${ens_method} == 'randomcv' ) then
       set produce_ens = yes
     endif
   endif
   if( $produce_ens == no ) then
     ln -s ../run_wrfv3/${anal_time}_ensemble .
   endif
   #
   #
   # --- For forecast_type = det_fcst only!
   if( $if_nout_added == no ) then
       set nout = `expr $nout + 1`
   endif
   #
   ./hybrid_etkf_3dvar.sh   ${anal_time}_ensemble  $ens_members ${anal_time}  \
                            $be_file    $if_radiance ${if_assimilate[${num}]} \
                            $which_mpi  $numtiles    $ncpu_wrfda    \
                            $num        ${case_name} $mark  $nv $cv \
                            $naccumt1   $naccumt2    $nout          \
                            $tainflatinput $rhoinput $if_update_ens_mean    \
                            ${if_radar} ${if_gts}    ${update_ens_mean_way} \
                            ${cv_number} ${produce_ens} ${ens_method}       \
                            ${use_filtered_obs}      ${cycle_intv}          \
                            ${rewrite_ens_mean}      ${update_anal_way}     \
                            ${wrf_hours} ${domain_num} ${anal_type}         \
                            ${ics_from_previous}     ${ini_etkf_way}  ${len_scale_cv5} \
                            ${if_put_seed}           ${pert_init_ens} ${gts_obs_dir}   \
                            ${mpi_opt_new}           ${ncpu_etkf_ob}  ${alpha_vertloc} \
                            ${if_speedup_obetkf}
 endif

 if( $forecast_type == 'ens_fcst' || $forecast_type == 'all_fcst' ) then
   echo ' ' >> ${wrf_cost_msg}
   echo ' ==== Hybrid-ETKF especially for forecast_type="ens_fcst".' >> ${wrf_cost_msg}
   # --- determine time step for WRF run
   cd ${wrf_run_path}
   echo ${cycle_num}
   cp -f  hybrid_3dvar_wrf_namelists/namelist.input_step${cycle_num} namelist.input
   sed 's/time_step_second/'${time_step[1]}'/g' namelist.input > namelist.input.tmp
   rm -f namelist.input
   set num            = ${cycle_num}
   set anal_time_init = `sed -n ${num}p ../run_wrfv3/hybrid_3dvar_wrf_namelists/cycle_info`
   set anal_time      = `echo $anal_time_init | cut -c1-4,6-7,9-10,12-13`
   if( $forecast_type == all_fcst ) then
     set ens_etkf = ../run_hybrid/etkf_hybrid_result_${cycle_date_end}_ensemble
   else
     set ens_etkf = ../run_hybrid/etkf_hybrid_result_${cycle_date_end}
   endif
   #
   set num_wrf = 1
   while ( $num_wrf <= $ens_members )
     if( $num_wrf < 10 ) then
       set e_num = 00$num_wrf
     else if( $num_wrf < 100 ) then
       set e_num = 0$num_wrf
     else
       set e_num = $num_wrf
     endif
     #
     # --- multiple schemes
     if( ${if_multi_schemes} == yes ) then
       set mps  = ${mp_physics[$num_wrf]}
       set lays = ${sf_sfclay_physics[$num_wrf]}
       set sfcs = ${sf_surface_physics[$num_wrf]}
       set pbls = ${bl_pbl_physics[$num_wrf]}
       set gras = ${grav_settling[$num_wrf]}
       set cups = ${cu_physics[$num_wrf]}
       set rass = ${ra_sw_physics[$num_wrf]}
       set rals = ${ra_lw_physics[$num_wrf]}
       set nsol = ${num_soil_layers[$num_wrf]}
     else
       set mps  = ${mp_physics[1]}
       set lays = ${sf_sfclay_physics[1]}
       set sfcs = ${sf_surface_physics[1]}
       set pbls = ${bl_pbl_physics[1]}
       set gras = ${grav_settling[1]}
       set cups = ${cu_physics[1]}
       set rass = ${ra_sw_physics[1]}
       set rals = ${ra_lw_physics[1]}
       set nsol = ${num_soil_layers[1]}
     endif
     set radt = ${radiation_delt_t}
     set cutt = ${cumulus_delt_t}
     sed 's/mps/'${mps}'/g' namelist.input.tmp | \
     sed 's/lays/'${lays}'/g' | \
     sed 's/sfcs/'${sfcs}'/g' | \
     sed 's/nsol/'${nsol}'/g' | \
     sed 's/gras/'${gras}'/g' | \
     sed 's/cups/'${cups}'/g' | \
     sed 's/cutt/'${cutt}'/g' | \
     sed 's/rass/'${rass}'/g' | \
     sed 's/rals/'${rals}'/g' | \
     sed 's/ra_dt/'${radt}'/g'| \
     sed 's/pbls/'${pbls}'/g' > namelist.input
     #
     if( -e namelist.input_${e_num} ) then
        rm -f namelist.input_${e_num}
     endif
     mv -f namelist.input namelist.input_${e_num}
     cp -f namelist.input_${e_num} ${ens_etkf}/e${e_num}/namelist.input 
     rm -f ${ens_etkf}/e${e_num}/wrfinput_d01 >& .msg
     rm -f ${ens_etkf}/etkf_hybird.msg.*      >& .msg
     cp -f ../run_hybrid/etkf_${anal_time}/etkf_output.e${e_num} \
           ${ens_etkf}/e${e_num}/wrfinput_d01 
     if( $domain_num >= 2 ) then
       cp -f ${case_name}/3dvar_step${cycle_num}/wrfinput_d02 ${ens_etkf}/e${e_num}/
       if( $domain_num == 3 ) then
         cp -f ${case_name}/3dvar_step${cycle_num}/wrfinput_d03 ${ens_etkf}/e${e_num}/
       endif
     endif
     set num_wrf = `expr $num_wrf + 1`
   end 
   rm -f namelist.input.tmp .msg
 endif
 date +'        Time: '%Y-%m-%d_%H:%M:%S >> ${wrf_cost_msg}

 # --- 4.4 run WRF on a powerful machine
 cd ${current_path}
 #if( -e nohup.out ) then
   #if( $which_mpi == 'mpich2' ) then
   #  grep -v starting nohup.out | grep -v '\[.\]' | \
   #          grep -v '  of    ' | grep -v ' of   '| \
   #          grep -v 'ls: rsl.out.0000:   '       > my_final.msg
   #else
   #  mv -f nohup.out my_final.msg
   #endif
   #mv -f nohup.out my_final.msg
 #endif
 #
 echo ''                             >> ${wrf_cost_msg}
 echo ' ==== To save the results'    >> ${wrf_cost_msg}

 # === 5.0 copy all messages and results into a diretory
 cd ${current_path}
 # --- For PBS output use
 if( -d my_case_result ) then
   rm -rf my_case_result
 endif
 mkdir my_case_result
 mkdir -p my_case_result/filtered_obs
 mv run_hybrid/ob.ascii_step* my_case_result/filtered_obs
 mv run_hybrid/namelist*step* my_case_result/filtered_obs
 mv run_hybrid/cost_*_step*   my_case_result/filtered_obs
 mv run_hybrid/grad_*_step*   my_case_result/filtered_obs
 mv run_hybrid/etkf_data.txt  my_case_result/filtered_obs
 #
 # --- forecast_type = 'det_fcst'
 if( ${forecast_type} == 'det_fcst' || $forecast_type == 'all_fcst' ) then
   echo '      save the result of det_fcst'    >> ${wrf_cost_msg}
   set determine_fcst_dir = my_case_result/determine_fcst
   mkdir -p ${determine_fcst_dir}
   if( $sst_update == 1 ) then
     cp run_wrfv3/${case_name}/3dvar_step${cycle_num}/wrflowinp_d0? ${determine_fcst_dir}
   endif
   cp -R run_hybrid/etkf_hybrid_result_${cycle_date_end}/*        ${determine_fcst_dir}
 endif
 #
 # --- keep the result of ens_fcst
 cd ${current_path}
 if( $forecast_type == 'ens_fcst' || $forecast_type == 'all_fcst' ) then
   echo '      save the result of ens_fcst'    >> ${wrf_cost_msg}
   set ensemble_fcst_dir = my_case_result/ensemble_fcst
   mkdir -p ${ensemble_fcst_dir}
   if( $sst_update == 1 ) then
     cp run_wrfv3/${case_name}/3dvar_step${cycle_num}/wrflowinp_d0? ${ensemble_fcst_dir}
   endif
   if( $domain_num >= 2 ) then
     cp run_wrfv3/${case_name}/3dvar_step${cycle_num}/wrfinput_d02 ${ensemble_fcst_dir}
   endif
   if( $forecast_type == all_fcst ) then
     set ens_etkf = run_hybrid/etkf_hybrid_result_${cycle_date_end}_ensemble
   else
     set ens_etkf = run_hybrid/etkf_hybrid_result_${cycle_date_end}
   endif
   set num_wrf = 1     
   while ( $num_wrf <= $ens_members )
     if( $num_wrf < 10 ) then
       set e_num = 00$num_wrf
     else if( $num_wrf < 100 ) then
       set e_num = 0$num_wrf
     else
       set e_num = $num_wrf
     endif
     mkdir ${ensemble_fcst_dir}/e${e_num} 
     cd ${ens_etkf}/e${e_num}
     cp -R * ${current_path}/${ensemble_fcst_dir}/e${e_num}
     cd ${current_path}
     mv -f run_wrfv3/namelist.input_${e_num} ${ensemble_fcst_dir}/e${e_num}/namelist.input
     cd ${ensemble_fcst_dir}/e${e_num}
     ln -sf ../wrfinput_d0?   .
     ln -sf ../wrflowinp_d0?  .
     cd ${current_path}
     set num_wrf = `expr $num_wrf + 1`
   end
 endif
 #
 cd ${current_path}
 mkdir my_case_result/no_3dvar
 cp run_wrfv3/${case_name}/3dvar_step${cycle_num}/wrf*_d0? my_case_result/no_3dvar >& .msg
 if( $forecast_type == 'det_fcst' || $forecast_type == 'all_fcst' ) then
   cp ${determine_fcst_dir}/namelist.input  my_case_result/no_3dvar >& .msg
 endif
 if( $forecast_type == 'ens_fcst' ) then
   cp ${ensemble_fcst_dir}/e001/namelist.input  my_case_result/no_3dvar >& .msg
 endif
 echo ' ' >> ${wrf_cost_msg}
 date +' Ending   Time: '%Y-%m-%d_%H:%M:%S >> ${wrf_cost_msg}
 rm -f .msg
 mv *.msg  my_case_result

 if( $if_ndown == yes ) then
   label end_output
   echo ' --- For ndown use!'
   cd ${current_path} 
   mv -f run_wrfv3/seafog_single_hybrid_etkf/3dvar_step5 my_case_result
   mv -f my_cost_time.msg my_settings.msg my_case_result/
   rm -rf my_case_result/3dvar_result
   rm -rf run_wrfv3/seafog_single_hybrid_etkf
 endif
# =========================== End of File ==================================

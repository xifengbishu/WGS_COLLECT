; basic NCL functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; basic options, maps and interface to inline functions 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; The WRF ARW input file. Append ".nc" here, to show it is an 
; netCDF file. Input file do not actually need to have ".nc" 
; appended. 
;a = addfile("../wrfout_d01_2000-01-24_12:00:00.nc","r") 
a = addfile("./wrfout_d01.nc","r") 
 
; We want output on screen. Output will be called "plt_Surface1" 
;  type = "x11"
; type = "pdf"
 type = "ps"
; type = "ncgm"
wks = gsn_open_wks(type,"wrf_Surface") 
 
; Set basic plot options and Give our plot a main title
; Set Footers off 
ARWres = True 
ARWres@MainTitle = "REAL-TIME WRF" 
ARWres@Footer = False 
 
;--------------------------------------------------------------------------------- 
; Lets find out how many times are in the datasets.
times = wrf_user_list_times(a) ; get times in the file
ntimes = dimsizes(times) ; number of times in the file
it = ntimes-1 ; for this plot we are only interested in the last time 
ARWres@TimeLabel = times(it) ; keep some time information 
 
; Create a MAP background. 
mpres = True 
  mpres = True
  map_type = "color"
  map_cint       = 10 ; degree
  ; --- labels along X and Y axes
  ; --- please try 1, 2, 3, 4, then see the result.
  lon_skip_num   = 2  ;  
  lat_skip_num   = 2  ;
  ;
  map_text_size  = 0.02 
  map_tic_length = 0
  ;
  ; =========================================
  ;mpres@mpFillOn = True
  ;
  if( map_type .eq. "color" ) then
    ;mpres@mpFillColors  = (/"background","DeepSkyBlue","ForestGreen","DeepSkyBlue", "transparent"/)
  else
    ;mpres@mpFillColors  = (/"background","background","background", "transparent"/)
  end if
  ;
  mpres@mpGeophysicalLineColor      = "(/100.0,100.0,100.0/)"
  ;mpres@mpGeophysicalLineColor      = "ForestGreen"
  mpres@mpGridLineColor             = "Red"
  mpres@mpGridLineColor             = "(/150.0,150.0,150.0/)"
  mpres@mpGeophysicalLineThicknessF = 3.0 ; default is 1.0
  ;
  mpres@mpGridLineDashPattern       = "6"
  mpres@mpGridSpacingF              = map_cint
  mpres@tmXBMajorOutwardLengthF     = map_tic_length
  mpres@tmXBMinorOutwardLengthF     = map_tic_length
  mpres@pmTickMarkDisplayMode       = "Always"
  mpres@tmXBLabelStride             = lon_skip_num
  mpres@tmXTLabelStride             = lon_skip_num
  mpres@tmYLLabelStride             = lat_skip_num
  mpres@tmYRLabelStride             = lat_skip_num
  mpres@tmXBLabelFontHeightF        = map_text_size
  ;
  mpres@mpLimbLineColor             = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpUSStateLineColor          = "Black"

  mpres@tmYROn                  = True
  mpres@tmYLOn                  = True
  mpres@tmXBOn                  = True
  mpres@tmXTOn                  = True
;===========================================================
;mpres@mpLandFillColor = -1 ;Land is shaded ,sea is one color
mpres@mpGeophysicalLineThicknessF = 3.0 ; default is 1.0
;mpres@gsnDraw =  True 
;mpres@gsnFrame = False 


;mpres@tiMainString = "T639 850hPa Wind & Specific Humidty "

;mpres@mpProjection = "LambertConformal"
;mpres@mpLimitMode = "Corners"


;mpres@pmTickMarkDisplayMode = True 


;mpres@mpOutlineOn = True
;mpres@mpOutlineBoundarySets = "National"
;mpres@mpLabelsOn = True

;mpres@lgLabelsOn = True 
;mpres@tmXBOn = True 
;mpres@tmXTOn = False
;mpres@tmYLOn = True 
;mpres@mpGridAndLimbOn = True
;mpres@mpGridSpacingF  =10
;mpres@mpGridLineColor = 239

  ;;;;;;;;;;;;;;plot the OutlineSpecifiers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;mpres@mpDataBaseVersion="HighRes, RANGS"
  mpres@mpDataBaseVersion="MediumRes"
  mpres@mpDataSetName="Earth..4"
  ;mpres@mpOutlineSpecifiers=(/"China","Fujian","Guandong","Jiangxi","Zhejiang"/)
  mpres@mpOutlineSpecifiers="China : provinces" ;"Mexico : States, provinces, and counties"
  mpres@mpUSStateLineThicknessF     = 4
  mpres@mpUSStateLineColor="Black"
  mpres@mpUSStateLineColor="(/100.0,100.0,100.0/)"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;===========================================================
;===========================================================
;===========================================================
map = wrf_map(wks,a,mpres) 
 
;---------------------------------------------------------------------------------
; Get the variables we will need
 
; wrf_user_getvar function is located in the
; "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
; script.
; This function either extract the requested WRF variables 
; (like in the case of U10 and V10), or call in-line function 
; to calculate diagnostic (like slp). 
 
slp = wrf_user_getvar(a,"slp",it) ; Calculate diagnostics slp 
   wrf_smooth_2d( slp, 3 ) ; smooth slp

tc2 = wrf_user_getvar(a,"T2",it) ; Get T2 (deg K)
   tc2 = tc2-273.16 ; Convert to deg C 
   ;tf2 = 1.8*tc2+32. ; Turn temperature into Fahrenheit 
   tf2 = 1*tc2 ; Turn temperature into Fahrenheit 
   tf2@description = "Surface Temperature" 
   tf2@units = "C"
;   td_f = 1.8*td2+32. 

u10 = wrf_user_getvar(a,"U10",it) ; Get U10 
v10 = wrf_user_getvar(a,"V10",it) ; get V10 
   u10 = u10*1 ; Turn wind into knots 
   v10 = v10*1 
   u10@units = "m/s" 
   v10@units = "m/s"
   ;u10 = u10*1.94386 ; Turn wind into knots 
   ;v10 = v10*1.94386 
   ;u10@units = "kts" 
   ;v10@units = "kts"
 
;-------------------------------------------------------------------------- 
; Plotting options for T
opts = ARWres
opts@cnFillOn = True ; Shaded plot 
opts@ContourParameters = (/ -00., 40., 2./) ; Contour intervals 
opts@gsnSpreadColorEnd = -3 ; End 3rd from last color 
contour_tc = wrf_contour(a,wks,tf2,opts) ; Create plot 
delete(opts)
  
 

; Plotting options for SLP
opts = ARWres
opts@cnLineColor = "NavyBlue" ; Set line color
opts@cnHighLabelsOn = True ; Add high/low labels 
opts@cnLowLabelsOn = True
opts@ContourParameters = (/ 900., 1100., 4. /) ; Contour intervals
opts@cnLineLabelBackgroundColor = -1 ; Label background transparent 
opts@gsnContourLineThicknessesScale = 2.0 ; Set line thickness
contour_psl = wrf_contour(a,wks,slp,opts) ; Create plot 
delete(opts)
 

; Plotting options for Wind Vectors
opts = ARWres
opts@FieldTitle = "Winds" ; Overwrite the field title 
opts@NumVectors = 47 ; Density of wind barbs - high is denser
vector = wrf_vector(a,wks,u10,v10,opts); Create plot 
delete(opts)
 
 

; MAKE PLOTS
; wrf_map_overlay function is located in the 
;"$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
; script.
; This function overlays the desired plots (created above),
; with the map background.
; The last option (True in this case), indicates that frame
;: should be advanced once the overlay is complete.

 
wrf_map_overlay(wks,map,(/contour_tc,contour_psl,vector/),True)
  
;--------------------------------------------------------------------------

end

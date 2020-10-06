FUNCTION foxsi4_get_j_optics_effarea, energy_arr=energy_arr, r=r, plot=plot, _extra=extra

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the effective area of the japanese high resolution optics
  ;
  ; :inputs:
  ;
  ; :outputs:
  ;   The function returns an structure containing the energy array, the radius of the mirror and the effective area
  ;
  ; :keywords:
  ;   energy_arr: an array of energies at which the transmission and absorption are to be calculated
  ;   r: radius in mm of the mirror. We have data for r=30 and r=50. Default is r=30.
  ;   plot: set to do this analysis for the cmos sensor
  ;
  ; :call:
  ;   This function calls csv tables contained in a folder named optics_data
  ;
  ; :example:
  ;   energy_in = indgen(400)*0.1+1
  ;   area = foxsi4_get_j_optics_effarea(energy_arr=energy_in)
  ;
  ; :history:
  ;   2019/07/29, SMusset (UMN), initial release
  ;   2020/10/06, SMusset (UoG), change path to file and make file access compatible with Mac and Unix
  ;
  ; :to be done:
  ;   Right now we are using the data sent to us for optic height of 100mm, but for FOXSI4 we will have 200mm height,
  ;   so in this procedure the effective area is multiplied by 2 to mimic the 200mm high optics
  ;-

  DEFAULT, r, 30 ; radius of the mirror
  DEFAULT, plot, 0

  IF R EQ 30 THEN opticfile = 'optics_data/r30mm_sigma1nm_height100mm_cm2_kev.dat' $
    ELSE IF R eq 50 THEN opticfile = 'optics_data/r50mm_sigma1nm_height100mm_cm2_kev.dat' $
      ELSE BEGIN
        print, 'This radius is not available, picked r=30 mm instead'
        opticfile = 'optics_data/r30mm_sigma1nm_height100mm_cm2_kev.dat'
      ENDELSE
  
  os=!VERSION.OS_FAMILY
  IF os EQ 'Windows' THEN sep_char='\' ELSE sep_char='/'
  mypath = routine_filepath()
  sep = strpos(mypath,sep_char,/reverse_search)
  path = strmid(mypath, 0, sep)
  
  read_list_txt, file=path+sep_char+opticfile, tab=tab1
  
  energy1 = double(reform(tab1[*,0])) ; in kev
  effarea1 = double(reform(tab1[*,1])) ; in cm2
  
  selec1 = where(energy1 NE 0)
  
  energy1 = energy1[selec1]
  effarea1 = effarea1[selec1]
  
  IF keyword_set(energy_arr) THEN BEGIN
    interpol_data1 = interpol(effarea1, energy1, energy_arr)
    ; interpolate data on new energies    
  ENDIF ELSE BEGIN 
    energy_arr = energy1
    interpol_data1 = effarea1
  ENDELSE

  ; need to multiply by factor 2 (approximation) because the foxsi4 optics will be 200mm in height, not 100mm
  ; and these data are for 100mm height optics
  interpol_data1 = interpol_data1*2.
  
  IF plot EQ 1 THEN BEGIN
     plot,energy_arr,interpol_data1,chars=3,xtitle='Energy (keV)',ytitle='Effective area (cm2)', thick=3, xth=2, yth=2, charth=2,title='High resolution optic module (Japan)', _extra=extra
     al_legend, ['optics radius '+strtrim(string(r),2)+' mm','optics height 200 mm'], chars=3, charth=2, /right, _extra=extra
  ENDIF
  
  result = create_struct("energy_keV", energy_arr, "eff_area_cm2", interpol_data1, 'module_radius_mm', r)
  RETURN, result
END
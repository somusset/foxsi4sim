FUNCTION foxsi4_effective_area, energy_arr, shells=shells, al_um=al_um, be_um=be_um, pinhole=pinhole, cmos=cmos, cdte=cdte, cea_let=cea_let, det_thick=det_thick, $
  msfc_high_res=msfc_high_res, high_res_j_optic=high_res_j_optic, no_det=no_det, plot=plot, loud=loud

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function calculates the efficiency for FOXSI-4 for
  ;    different possibilities in optic module, detector and attenuator combination. It is done in 3 steps:
  ;    - get the optics effective area
  ;    - multiply by the detector efficiency (unless the no_det keyword is set)
  ;    - multiply by blanket+shutter efficiency
  ;
  ; :inputs:
  ;   energy_arr: array of energies (mean energy of energy bins)
  ;
  ; :outputs:
  ;   The function returns the count flux in photons/sec/keV
  ;
  ; :keywords:
  ;   shells: number of shells in the optic module. Default is 10, other accepted value is 7
  ;   al_um: Al attenuator thickness in microns, default is 0.
  ;   be_um: Be attenuator thickness in microns, default is 0.
  ;   pinhole: take attenuation factor consistent with pinhole attenuator. Default is 0
  ;   cmos: if this keyword is set, then efficiency of the cmos detector is considered
  ;   cdte: if this keyword is set, then efficiency of a cdte detector is considered
  ;   det_thick: thickness of the detector in microns. default is 10 for CMOS and 500 for CdTe
  ;   cea_let: use my own approximation of a 2 keV threshold for the cea detector
  ;   energy_resolution: detector energy resolution in keV
  ;   msfc_high_res: if set, take the theoretical effective area of the 2 innermost shell of a 10-shell module: this mimic the high resolution optic module from marshall
  ;   high_res_j_optic: if set, take the high resolution optic module from japan
  ;   no_det: do not include detector efficiency
  ;   plot: if set, plot the efficiency curve. Default is 0.
  ;   loud: if set, print info on optics and detector. DEFAULT is 1
  ;
  ; :call:
  ;   foxsi4_get_j_optics_effarea
  ;   foxsi4_get_msfc_optics_effarea
  ;   get_foxsi_optics_effarea
  ;   get_foxsi_deteff
  ;   foxsi4_get_shutter
  ;   foxsi4_get_pinhole_attenuation_factor
  ;
  ; :example:
  ;   energy_in = indgen(20)+3.5
  ;   res = foxsi4_effective_area(energy_in)
  ;   
  ; :heritage:
  ;   This function is directly copied / summarized from get_foxsi_effarea
  ;
  ; :history:
  ;   2019/07/22, SMusset (UMN), initial release
  ;   2019/07/29, SMusset (UMN), added theoretical QE for CMOS and CdTe
  ;   2019/08/07, SMusset (UMN), added msfc_high_res option
  ;   2019/08/19, SMusset (UMN), added det_thick and cea_let keywords to simulate cdte from CEA
  ;                              added loud keyword
  ;   2019/09/10, SMusset (UMN), added no_det keyword
  ;   2019/10/08, SMusset (UMN), added attenuation by electrodes for CdTE, following changes made
  ;                               in get_foxsi_deteff in the FOXSI science
  ;   2019/10/28, SMusset (UMN), added the pinhole attenuator option
  ;   2020/09/16, SMusset (UoG), change path to file and update documentation
  ;   2020/10/06, SMusset (UoG), change '\' to '/' in path for compatibility with Mac and Unix
  ;   2020/10/06, SMusset (UoG), change plot display window size for compatibility with other device
  ;   2020/10/12, SMusset (UoG), invert order to have blanket transmission before detector eff
  ;   2022/05/11, Y.Zhang (UMN), bug fix: move the CMOS pre-filter material to the blanket transmission part 
  ;                                       so that it can be properly taken into account
  ;
  ; :to be done:
  ;-

  screen_dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution)
  window_xsize = fix(0.3*screen_dimensions[0])
  window_ysize = fix(window_xsize*0.9)

  DEFAULT, shells, 10
  DEFAULT, al_um, 0 ; microns
  DEFAULT, be_um, 0 ; microns
  DEFAULT, pinhole, 0
  DEFAULT, poly_um, 0 ; microns
  DEFAULT, cmos, 0
  DEFAULT, cdte, 0
  DEFAULT, cea_let, 0
  DEFAULT, high_res_j_optic, 0
  DEFAULT, msfc_high_res, 0 
  DEFAULT, plot, 0
  DEFAULT, loud, 1
  DEFAULT, no_det, 0
  IF CMOS EQ 1 THEN DEFAULT, det_thick, 10. ELSE DEFAULT, det_thick, 500. ; microns

  energy_out = energy_arr
  thickness_str = strtrim(string(round(det_thick)),2)
  
  ;------------------------------------------------
  ; get the optic effective area
  ;------------------------------------------------

  IF high_res_j_optic EQ 1 THEN BEGIN
    IF loud EQ 1 THEN print, 'Effective area from Japan high resolution optics'
    area = foxsi4_get_j_optics_effarea(energy_arr=energy_out)
  ENDIF ELSE BEGIN
    IF msfc_high_res EQ 1 THEN BEGIN
      IF loud EQ 1 THEN print, 'Effective area = MSFC high resolution'
      area = foxsi4_get_msfc_optics_effarea(energy_arr=energy_out)
    ENDIF ELSE BEGIN
      IF shells EQ 10 THEN BEGIN 
        IF loud EQ 1 THEN PRINT, 'Taking data from optic module 6'
        module_number = 6 
        area = get_foxsi_optics_effarea( energy_arr=energy_out, module_number=module_number, $
          offaxis_angle=offaxis_angle, data_dir=data_dir, plot=plot, year=2014)
      ENDIF ELSE BEGIN
        IF shells EQ 7 THEN BEGIN
          IF loud EQ 1 THEN PRINT, 'Taking data from optic module 5'
          module_number = 5 
          area = get_foxsi_optics_effarea( energy_arr=energy_out, module_number=module_number, $
            offaxis_angle=offaxis_angle, data_dir=data_dir, plot=plot)
        ENDIF ELSE BEGIN
          print, 'This number of shells is not available'
        ENDELSE
      ENDELSE
    ENDELSE
  ENDELSE
  
  energy = area.energy_kev
  eff_area = area.eff_area_cm2
  
  eff_area_orig = interpol(eff_area, energy, energy_out)
  eff_area = eff_area_orig

  set_line_color
  IF plot EQ 1 THEN BEGIN
    window, 0, xsize=window_xsize, ysize=window_ysize
    plot, energy, eff_area, /xlog, /ylog, thick=2, color=0, background=1, chars=2, charth=2, xth=2, yth=2, linestyle=0, xtitle='Energy (keV)', ytitle='Effective area (cm2)', yr=[1d-1,1d2], /xsty
  ENDIF
  
  ;---------------------------------------------------------------------
  ; Blanketing transmission (the CMOS pre-filter is also included here)
  ;---------------------------------------------------------------------

  ;add in the various materials already in the optical path
  IF NOT keyword_set(nopath) THEN BEGIN
    IF cmos EQ 1 THEN BEGIN
      IF loud EQ 1 THEN print, 'adding 0.45 um of Al and 2 um of poly in front of CMOS'  ; adding CMOS pre-filter
      optical_path = foxsi4_get_shutter(energy_arr = energy_out, data_dir = data_dir, al_um=al_um+0.45, be_um=be_um, poly_um=poly_um+2.)
    ENDIF ELSE BEGIN
      optical_path = foxsi4_get_shutter(energy_arr = energy_out, data_dir = data_dir, al_um=al_um, be_um=be_um, poly_um=poly_um)
    ENDELSE
    eff_area = eff_area*optical_path.shut_eff
  ENDIF

  ; special case for the pinhole attenuator: use attenuation factor given by Dan
  IF pinhole EQ 1 THEN BEGIN
    res = foxsi4_get_pinhole_attenuation_factor(energy_arr = energy_out)
    eff_area = eff_area*res.att_factor
  ENDIF

  IF plot EQ 1 THEN BEGIN
    oplot, energy, eff_area, thick=2, color=0, linestyle=3
    al_legend, ['optics','optics+det','optics+det+path'], linestyle=[0,2,3], thick=2, chars=2, charth=2, box=0, /right, linsize=0.4
  ENDIF

  ;------------------------------------------------
  ; get the detector efficiency, including low-energy cutoff curve
  ;------------------------------------------------

  IF no_det NE 1 THEN BEGIN

    IF cdte EQ 1 THEN BEGIN
      IF loud EQ 1 THEN print, 'theoretical QE for CdTe with '+thickness_str+'um thickness'
      IF cea_let EQ 1 THEN det_eff = get_foxsi_deteff(energy_arr = energy_out, det_thick = det_thick, type = 'cdte', let_file='detector_data/efficiency_cea.sav') $
        ELSE det_eff = get_foxsi_deteff(energy_arr = energy_out, det_thick = det_thick, type = 'cdte')
      eff_area = eff_area*det_eff.det_eff
      IF loud EQ 1 THEN print, 'now including attenuation by CdTe electrodes'
         ;attenuation length for Au electrodes
         f = GETENV('FOXSIPKG')+'/calibration_data/' + ["au_atten_len.dat","pt_atten_len.dat"] ; sophie used GETENV for compatibility with windows
         restore, f[0]
         energy_keV_au = data.energy_ev/1000.
         atten_len_um_au = data.atten_len_um
         au_thick_um = 0.1
         ;attenuation length for Pt electrodes
         restore, f[1]
         energy_keV_pt = data.energy_ev/1000.
         atten_len_um_pt = data.atten_len_um
         pt_thick_um = .05
         atten_len_um_au = interpol(atten_len_um_au, energy_keV_au, energy_out)
         atten_len_um_pt = interpol(atten_len_um_pt, energy_keV_pt, energy_out)
         elec = ((5./6)*exp(-au_thick_um/atten_len_um_au)*exp(-pt_thick_um/atten_len_um_pt))+(1./6)
         eff_area = eff_area*elec
    ENDIF ELSE BEGIN
      IF cmos EQ 1 THEN BEGIN
        IF loud EQ 1 THEN  print, 'efficiency for thick CMOS is theoretical: absorption of '+thickness_str+' microns of Si'
        det_eff = get_foxsi_deteff(energy_arr = energy_out, det_thick = det_thick, type = 'si', /no_let)
        eff_area = eff_area*det_eff.det_eff
      ENDIF ELSE BEGIN
        IF loud EQ 1 THEN print, 'Efficiency for Silicon is calculated using det 102'
        let_file = 'efficiency_det102_avg.sav'
        det_eff = get_foxsi_deteff(energy_arr = energy_out, det_thick = det_thick, type = type, data_dir = data_dir, let_file = let_file)
        eff_area = eff_area*det_eff.det_eff
      ENDELSE
    ENDELSE
  
    IF plot EQ 1 THEN oplot, energy, eff_area, thick=2, color=0, linestyle=2
  ENDIF
  
 

  IF keyword_set(PLOT) THEN BEGIN

  ;  plot, energy_arr, num_modules*eff_area_orig, psym = -4, $
  ;    xtitle = "Energy [keV]", ytitle = "Effective Area [cm!U2!N]", charsize = 1.5, /xstyle, xrange = [min(energy_arr), max(energy_arr)], _EXTRA = _EXTRA, /nodata


  ;  txt = ['Optics', '+Optical Path']
  ;  oplot, energy_arr, num_modules*eff_area_orig, psym = -4, color = 7
  ;  oplot, energy_arr, eff_area, psym = -4, color = 6
  ;  ssw_legend, txt, textcolor = [7,6], /right

  
  ENDIF

  res = create_struct("energy_keV", energy_out, "eff_area_cm2", eff_area)

  RETURN, res

END 

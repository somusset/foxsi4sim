PRO foxsi4_plot_effective_area, no_att = no_att, ylog = ylog, plot_total=plot_total, attenuation_ontop=attenuation_ontop, xlog=xlog

  DEFAULT, no_att, 1
  DEFAULT, ylog, 1
  DEFAULT, plot_total, 1
  DEFAULT, attenuation_ontop, 1
  DEFAULT, xlog, 0
  
  energy_array = (indgen(250)+1)/10.
  
  ; MODULE 0: CdTe + MSFC high-res optics + pinhole
  ; MODULE 1: CdTe + MSFC high-res optics + 260 micron Al attenuator
  ; MODULE 2: CMOS + MSFC high-res optics + 240 micron Al attenuator
  ; MODULE 3: CMOS + Nagoya high-res + 180 micron Al attenuator
  ; MODULE 4: CdTe + Nagoya high-res + 180 micron Al attenuator
  ; MODULE 5: CdTe + 10-shell + 500 micron Al attenuator
  ; MODULE 6: CdTe + 10-shell + pinhole
  
  cdte_col = [8,13,15]
  cmos_col = [3,5]
  module_col = [8,9,3,5,13,16,17]
  
  ; modules 5
  al_um = 500.
  module_cdte_10shell_att = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick)
  IF no_att EQ 1 THEN al_um = 0
  det_thick = 500.
  module_cdte_10shell = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick) 
  
  ; module 1
  al_um=260. 
  ;al_um=200.
  module_cdte_msfc_hres_att = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick, msfc_high_res=1)
  IF no_att EQ 1 THEN al_um = 0
  det_thick = 500.
  module_cdte_msfc_hres = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick, msfc_high_res=1) 

  ; module 6 
  pinhole = 1
  module_cdte_10shell_pinhole_att = foxsi4_effective_area(energy_array, al_um=0, pinhole=pinhole, cdte=1, det_thick=det_thick)
  IF no_att EQ 1 THEN pinhole = 0
  det_thick = 500.
  module_cdte_10shell_pinhole = foxsi4_effective_area(energy_array, al_um=0, pinhole=pinhole, cdte=1, det_thick=det_thick) 

  ; module 0
  pinhole = 1 
  module_cdte_msfc_hres_pinhole_att = foxsi4_effective_area(energy_array, pinhole=pinhole, cdte=1, det_thick=det_thick, msfc_high_res=1) ; valid for 2 modules
  IF no_att EQ 1 THEN pinhole = 0
  det_thick = 500.
  module_cdte_msfc_hres_pinhole = foxsi4_effective_area(energy_array, pinhole=pinhole, cdte=1, det_thick=det_thick, msfc_high_res=1) ; valid for 2 modules

  ; module 4
  al_um=180.
  module_cdte_J_hres_att = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick, high_res_j_optic=1) ; valid for 1 module
  IF no_att EQ 1 THEN al_um = 0
  det_thick = 500.
  module_cdte_J_hres = foxsi4_effective_area(energy_array, al_um=al_um, cdte=1, det_thick=det_thick, high_res_j_optic=1) ; valid for 1 module

  ; module 3
  al_um=180. 
  module_CMOS_J_hres_att = foxsi4_effective_area(energy_array, al_um=al_um, CMOS=1, high_res_j_optic=1) ; valid for one module
  IF no_att EQ 1 THEN al_um = 0
  ;det_thick = 10.
  module_CMOS_J_hres = foxsi4_effective_area(energy_array, al_um=al_um, CMOS=1, high_res_j_optic=1) ; valid for one module
  
  ; module 2
  al_um=240.
  module_CMOS_msfc_hres_att = foxsi4_effective_area(energy_array, al_um=al_um, CMOS=1, msfc_high_res=1) ; valid for one module
  IF no_att EQ 1 THEN al_um = 0
  module_CMOS_msfc_hres = foxsi4_effective_area(energy_array, al_um=al_um, CMOS=1, msfc_high_res=1) ; valid for one module


  total_effarea = module_cdte_10shell_pinhole.eff_area_cm2 + module_cdte_10shell.eff_area_cm2 + module_cdte_msfc_hres_pinhole.eff_area_cm2 $
    + module_cdte_msfc_hres.eff_area_cm2 + module_cdte_J_hres.eff_area_cm2 + $
    module_CMOS_J_hres.eff_area_cm2 + module_CMOS_msfc_hres.eff_area_cm2 

  total_effarea_att = module_cdte_10shell_pinhole_att.eff_area_cm2 + module_cdte_10shell_att.eff_area_cm2 + module_cdte_msfc_hres_pinhole_att.eff_area_cm2 $
    + module_cdte_msfc_hres_att.eff_area_cm2 + module_cdte_J_hres_att.eff_area_cm2 + $
    module_CMOS_J_hres_att.eff_area_cm2 + module_CMOS_msfc_hres_att.eff_area_cm2

  window, xsize = 1300, ysize = 1000
  sophie_Linecolors
  th=2
  cs=2
  lst=2
  
  IF ylog EQ 1 THEN BEGIN 
    IF no_att EQ 1 THEN yr = [1d-3, 1d2] ELSE yr = [1d-3, 1d1]
  ENDIF ELSE BEGIN
    IF no_att EQ 1 THEN BEGIN
      IF plot_total EQ 1 THEN yr = [0,60] ELSE yr = [0,25]
    ENDIF ELSE BEGIN
      IF plot_total EQ 1 THEN yr = [0,12] ELSE yr = [0,4]
    ENDELSE
  ENDELSE
   
 
  IF xlog EQ 1 THEN xr = [2,25] ELSE xr=[0,23] 
  IF plot_total EQ 1 THEN yeffarea = total_effarea ELSE yeffarea = module_cdte_10shell.eff_area_cm2
  plot, module_cdte_10shell.energy_kev, yeffarea, xlog=xlog, $
    color=0, background=1, chars=cs, thick=th+1, xth=th, yth=th, charth=th, ylog=ylog, yr=yr, $
    xtitle = 'Energy (keV)', ytitle='Effective Area (cm!E2!N)', xr=xr, /xstyle, title='FOXSI-4 effective areas'
  ; plot module 6
  OPLOT, module_cdte_10shell_pinhole.energy_kev, module_cdte_10shell_pinhole.eff_area_cm2,     COLOR=module_col[6], THICK=TH+1
  ; plot module 5
  OPLOT, module_cdte_10shell.energy_kev, module_cdte_10shell.eff_area_cm2,     COLOR=module_col[5], THICK=TH+1
  ; plot module 0
  OPLOT, module_cdte_msfc_hres_pinhole.energy_kev, module_cdte_msfc_hres_pinhole.eff_area_cm2, COLOR=module_col[0], THICK=TH+1
  ; plot module 1
  OPLOT, module_cdte_msfc_hres.energy_kev, module_cdte_msfc_hres.eff_area_cm2, COLOR=module_col[1], THICK=TH+1
  ; plot module 4
  OPLOT, module_cdte_J_hres.energy_kev, module_cdte_J_hres.eff_area_cm2,       COLOR=module_col[4], THICK=TH+1
  ; plot module 3
  OPLOT, module_CMOS_J_hres.energy_kev, module_CMOS_J_hres.eff_area_cm2,       COLOR=module_col[3], THICK=TH+1
  ; plot module 2
  OPLOT, module_CMOS_msfc_hres.energy_kev, module_CMOS_msfc_hres.eff_area_cm2, COLOR=module_col[2], THICK=TH+1
  
  IF attenuation_ontop EQ 1 THEN BEGIN
    ; plot module 6
    OPLOT, module_cdte_10shell_pinhole_Att.energy_kev, module_cdte_10shell_pinhole_Att.eff_area_cm2,     COLOR=module_col[6], THICK=TH+1, linestyle=lst
    ; plot module 5
    OPLOT, module_cdte_10shell_Att.energy_kev, module_cdte_10shell_Att.eff_area_cm2,     COLOR=module_col[5], THICK=TH+1, linestyle=lst
    ; plot module 0
    OPLOT, module_cdte_msfc_hres_pinhole_Att.energy_kev, module_cdte_msfc_hres_pinhole_Att.eff_area_cm2, COLOR=module_col[0], THICK=TH+1, linestyle=lst
    ; plot module 1
    OPLOT, module_cdte_msfc_hres_Att.energy_kev, module_cdte_msfc_hres_Att.eff_area_cm2, COLOR=module_col[1], THICK=TH+1, linestyle=lst
    ; plot module 4
    OPLOT, module_cdte_J_hres_Att.energy_kev, module_cdte_J_hres_Att.eff_area_cm2,       COLOR=module_col[4], THICK=TH+1, linestyle=lst
    ; plot module 3
    OPLOT, module_CMOS_J_hres_Att.energy_kev, module_CMOS_J_hres_Att.eff_area_cm2,       COLOR=module_col[3], THICK=TH+1, linestyle=lst
    ; plot module 2
    OPLOT, module_CMOS_msfc_hres_att.energy_kev, module_CMOS_msfc_hres_att.eff_area_cm2, COLOR=module_col[2], THICK=TH+1, linestyle=lst
    
    OPLOT, module_cdte_10shell_pinhole_Att.energy_kev, total_effarea_att, color=0, thick=th+1, linestyle = lst
  ENDIF
  
  ;al_legend, ['CdTe+10shells','CdTe+HighResOpt', 'CdTe+JOpt','CMOS+JOpt','CMOS+HighResOpt'], textcol = [cdte_col,cmos_col], box=0, chars=cs, charth=th+1
  al_legend, 'Mod.'+[' 0',' 1',' 2',' 3',' 4',' 5', ' 6'], textcol = module_col, box=0, chars=cs, charth=th+1
  al_legend, 'Total effective area', textcol=0, box=0, chars=cs, charth=th+1, /right
  ;WRITE_PNG, 'foxsi4_effareas_all_total.png', TVRD(/TRUE)


END
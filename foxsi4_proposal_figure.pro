PRO foxsi4_proposal_figure, NUM=NUM, int_time=int_time, counting_stat=counting_stat, pinhole=pinhole, highres=highres, energy_resolution=energy_resolution

  default, NUM, 1 ; figure number, 1 for M3 flare, 2 for HIC flare, 3 for C3 flare
  default, int_time, 10. ; seconds
  default, counting_stat, 0 ; set to 1 to add photon noise
  default, pinhole, 0 ; set to 1 to use pinhole attenuator instead of al attenuator
  default, highres, 1 ; set to 1 to use MSFC high resolution optics instead of the 10-shell optics
  
  ATT_CDTE = 500 ; MICRONS
  IF highres EQ 1 THEN ATT_CDTE = 260. ; microns
  IF highres EQ 1 THEN BEGIN
    msfc_high_res=1 
    highresstring = 'msfc-hr'
  ENDIF ELSE BEGIN
    msfc_high_res=0
    highresstring = 'module6'
  ENDELSE
  IF keyword_set(energy_resolution) THEN eresstring='_dE='+strtrim(string(energy_resolution),2)+'keV' ELSE eresstring=''
  
  ATT_CMOS = 180. ; MICRONS
  th=3
  
  IF counting_stat EQ 0 THEN addstr = '' ELSE addstr = '_noisy'
  IF pinhole EQ 1 THEN addstr = addstr+'_pinhole'
  
  str_int_time = strtrim(string(round(int_time)),2)
  
  ; change title if we have some integration time
  IF int_time EQ 1 THEN ytitle = 'Count flux (counts/s/keV)' ELSE ytitle = 'Count spectrum (counts/keV)'
  
  
  ;===============================================================================================================
  ; FIGURE 1
  ;===============================================================================================================
  ;+

  ; simulation of the photon spectra

  IF num EQ 1 THEN BEGIN
    foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
    goesclass = 'm35'
    goesclass_tit = 'M3.5'
  ENDIF 
  
  IF num EQ 2 THEN BEGIN
    foxsi4_flare_simulation_c5_hic, FP_spectrum, FP2_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
    goesclass = 'c5'
    goesclass_tit = 'C5'
  ENDIF
  
  IF num EQ 3 THEN BEGIN
    foxsi4_flare_simulation_c3, FP_spectrum, FP2_spectrum,  CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
    goesclass = 'c26'
    goesclass_tit = 'C2.6'
  ENDIF

  ; if there is a pinhole attenuator we do not need the aluminum attenuator in front of the CdTe
  IF pinhole EQ 1 THEN att_cdte = 0

  ; PANEL WITH THE INTEGRATED SPECTRA (fig 1) OR THE coronal spectra (fig 2)

  IF num EQ 1 THEN BEGIN
    bestatt = ATT_CDTE
    al_um = round(bestatt)
    al_attstr_cdte = strtrim(string(al_um),2)
    
    if pinhole EQ 1 THEN attstrcdte = 'pinhole' ELSE attstrcdte =al_attstr_cdte+'um'
    
    foxsi4_calculate_and_plot_count_spectrum, full_spectrum, cdte=1, al_um=al_um, pinhole=pinhole, energy_edges=energy_edges, energy_resolution=energy_resolution, window_ind=2, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_'+highresstring+'-'+attstrcdte+eresstring+'.png', att_str = 'Al '+al_attstr_cdte+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat, msfc_high_res=msfc_high_res
  
    bestatt = ATT_CMOS
    al_um = round(bestatt)
    al_attstr_cmos = strtrim(string(al_um),2)
  
    foxsi4_calculate_and_plot_count_spectrum, full_spectrum, cmos=1, high_res_j_optic=1, al_um=al_um, energy_edges=energy_edges, window_ind=3, plot_title='Count flux CMOS + J-high res', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cmos_jhighres_Al-'+al_attstr_cmos+'um'+eresstring+'.png', att_str = 'Al '+al_attstr_cmos+' um', list_counts=full_list_counts_cmos, int_time=int_time, counting_stat=counting_stat
  
    yr=[1,1d4*int_time]
    ;IF highres EQ 1 THEN yr = [1,1d5*int_time]
  ENDIF
  
  IF num EQ 2 OR num EQ 3 THEN BEGIN
    bestatt = ATT_CDTE
    al_um = round(bestatt)
    al_attstr_cdte = strtrim(string(al_um),2)
    if pinhole EQ 1 THEN attstrcdte = 'pinhole' ELSE attstrcdte =al_attstr_cdte+'um'

    foxsi4_calculate_and_plot_count_spectrum, CS_spectrum, cdte=1, al_um=al_um, pinhole=pinhole, energy_edges=energy_edges, energy_resolution=energy_resolution, window_ind=2, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_'+highresstring+'_Al-'+attstrcdte+eresstring+'.png', att_str = 'Al '+al_attstr_cdte+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat, msfc_high_res=msfc_high_res
 
    bestatt = ATT_CMOS
    al_um = round(bestatt)
    al_attstr_cmos = strtrim(string(al_um),2)

    foxsi4_calculate_and_plot_count_spectrum, CS_spectrum, cmos=1, high_res_j_optic=1, al_um=al_um, energy_edges=energy_edges, window_ind=3, plot_title='Count flux CMOS + J-high res', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cmos_jhighres_Al-'+al_attstr_cmos+'um'+eresstring+'.png', att_str = 'Al '+al_attstr_cmos+' um', list_counts=full_list_counts_cmos, int_time=int_time, counting_stat=counting_stat
  
    IF num EQ 2 THEN yr=[1,1d3*int_time]
    IF num EQ 3 THEN yr=[1,1d1*int_time]
  ENDIF
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; first panel plot
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  fullspec = full_list_counts[0]
  window, 4, xsize=1000, ysize=1000
  sophie_linecolors
  ; plot HXR spectrum
  plot, fullspec.energy_kev, fullspec.count_flux*int_time, /xlog, /ylog, xr=[4,25], /xstyle, yr=yr, background=1, xthick=th, ythick=th, charthi=th, chars=2.2, thick=th, psym=10, $
    xtitle='Energy (keV)', ytitle=ytitle
  ; plot cmos NOT in shade
  cmos_counts = full_list_counts_cmos[0]
                  ; polyfill, cmos_counts.energy_kev, cmos_counts.count_flux,  color=32, noclip=0
  ; overplot CMOS error bars
  FOR k=0, n_elements(cmos_counts.count_flux)-1 DO oplot, [cmos_counts.energy_kev[k],cmos_counts.energy_kev[k]], cmos_counts.count_flux[k]*int_time+[-1.,+1.]*SQRT(cmos_counts.count_flux[k]*int_time), color=4, thick=3
  oplot, cmos_counts.energy_kev, cmos_counts.count_flux*int_time,  color=3, thick=2, psym = 10

  ; over plot CDTE error bars
  FOR k=0, n_elements(fullspec.count_flux)-1 DO oplot, [fullspec.energy_kev[k],fullspec.energy_kev[k]], fullspec.count_flux[k]*int_time+[-1.,+1.]*SQRT(fullspec.count_flux[k]*int_time), color=0, thick=3
  ; PLOT THERMAL PART
  full_th = full_list_counts[1]
  oplot, full_th.energy_kev, full_th.count_flux*int_time, thick=th*0.9, linestyle=2, color=33
  ; PLOT NONTHERMAL PART
  full_nth = full_list_counts[2]
  oplot, full_nth.energy_kev, full_nth.count_flux*int_time, thick=th*0.9, linestyle=4, color=33
  ; PLOT FLUX AGAIN SO THAT IT IS ON TOP OF EVERYTHING ELSE
  oplot, fullspec.energy_kev, fullspec.count_flux*int_time, thick=th, psym=10
  
  al_legend, ['CdTe','thermal','nonthermal'], linestyle=[0,2,4], color=[0,33,33], box=0, /right, chars=2, linsi=0.2, charth=th,thick=th  
  al_legend, ['CMOS'], box=0, color=3, chars=2, thick=th, linsi=0.2, linestyl=0, charth=th
  
  IF num EQ 1 THEN WRITE_PNG, 'proposal_figure1_panel1_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  IF num EQ 2 THEN WRITE_PNG, 'proposal_figure2_panel1_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  IF num EQ 3 THEN WRITE_PNG, 'proposal_figure3_panel1_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  stop
  
  ; PANEL WITH THE FOOTPOINTS SPECTRA
  
  ;define colors for plots
  IF num EQ 1 THEN begin
    FPCOL = 37
    COMPCOL = 14
  ENDIF
  IF num EQ 2 OR num EQ 3 THEN BEGIN
    FPCOL = 0
    COMPCOL = 33
  ENDIF
  
  
  bestatt = ATT_CDTE
  al_um = round(bestatt)
  al_attstr_cdte = strtrim(string(al_um),2)
  if pinhole EQ 1 THEN attstrcdte = 'pinhole' ELSE attstrcdte =al_attstr_cdte+'um'

  foxsi4_calculate_and_plot_count_spectrum, FP_spectrum, cdte=1, al_um=al_um, pinhole=pinhole, energy_edges=energy_edges, energy_resolution=energy_resolution, window_ind=2, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
    plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_'+highresstring+'_Al-'+attstrcdte+eresstring+'.png', att_str = 'Al '+al_attstr_cdte+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat, msfc_high_res=msfc_high_res

  bestatt = ATT_CMOS
  al_um = round(bestatt)
  al_attstr_cmos = strtrim(string(al_um),2)

  foxsi4_calculate_and_plot_count_spectrum, FP_spectrum, cmos=1, high_res_j_optic=1, al_um=al_um, energy_edges=energy_edges, window_ind=3, plot_title='Count flux CMOS + J-high res', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
    plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cmos_jhighres_Al-'+al_attstr_cmos+'um'+eresstring+'.png', att_str = 'Al '+al_attstr_cmos+' um', list_counts=full_list_counts_cmos, int_time=int_time, counting_stat=counting_stat

  fullspec = full_list_counts[0]
  window, 4, xsize=1000, ysize=1000
  sophie_linecolors
  plot, fullspec.energy_kev, fullspec.count_flux*int_time, /xlog, /ylog, xr=[4,25], /xstyle, yr=yr, background=1, xthick=th, ythick=th, charthi=th, chars=2.2, thick=th, psym=10, $
    xtitle='Energy (keV)', ytitle=ytitle
  ; plot cmos in shade
  cmos_counts = full_list_counts_cmos[0]
  FOR k=0, n_elements(cmos_counts.count_flux)-1 DO oplot, [cmos_counts.energy_kev[k],cmos_counts.energy_kev[k]], cmos_counts.count_flux[k]*int_time+[-1.,+1.]*SQRT(cmos_counts.count_flux[k]*int_time), color=4, thick=3
  oplot, cmos_counts.energy_kev, cmos_counts.count_flux*int_time,  color=3, thick=2, psym=10

  ; PLOT ERRORS ON FLUX
  FOR k=0, n_elements(fullspec.count_flux)-1 DO oplot, [fullspec.energy_kev[k],fullspec.energy_kev[k]], fullspec.count_flux[k]*int_time+[-1.,+1.]*SQRT(fullspec.count_flux[k]*int_time), color=FPCOL, thick=3
  ; PLOT THERMAL PART
  full_th = full_list_counts[1]
  oplot, full_th.energy_kev, full_th.count_flux*int_time, thick=th*0.9, linestyle=2, color=COMPCOL
  ; PLOT NONTHERMAL PART
  full_nth = full_list_counts[2]
  oplot, full_nth.energy_kev, full_nth.count_flux*int_time, thick=th*0.9, linestyle=4, color=COMPCOL
  ; PLOT FLUX AGAIN SO THAT IT IS ON TOP OF EVERYTHING ELSE
  oplot, fullspec.energy_kev, fullspec.count_flux*int_time, thick=th, psym=10, COL=FPCOL

  al_legend, ['CdTe','thermal','nonthermal'], linestyle=[0,2,4], color=[FPCOL,COMPCOL,COMPCOL], box=0, /right, chars=2, linsi=0.2, charth=th,thick=th
  al_legend, ['CMOS'], box=0, color=3, chars=2, thick=th, linsi=0.2, linestyl=0, charth=th
  
  IF num EQ 1 THEN WRITE_PNG, 'proposal_figure1_panel2_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  IF num EQ 2 THEN WRITE_PNG, 'proposal_figure2_panel2_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  IF num EQ 3 THEN WRITE_PNG, 'proposal_figure3_panel2_'+highresstring+'_al-'+al_attstr_cmos+'-cmos_'+str_int_time+'s'+addstr+eresstring+'.png', TVRD(/TRUE)
  STOP
  
  ;-
  
  ;===============================================================================================================
  ; FIGURE 2
  ;===============================================================================================================
  ;+
  IF num EQ 2 THEN BEGIN
    ; restore data file
    
    mypath = routine_filepath()
    sep = strpos(mypath,'\',/reverse_search)
    IF sep EQ -1 THEN sep=strpos(mypath,'/',/reverse_search)
    path = strmid(mypath, 0, sep)
    file = path+'\flare_data\fix_emcube_0.sav'
    restore, file

    ; define some constants

    pixel_size_arcsec = 0.6 ; arcsec
    Dsun = 150d6 * 1d5 ; 150 millions de km en cm
    pixel_size_cm = Dsun*atan(pixel_size_arcsec/3600*!pi/180)

    ; make a EM map and T map

    em = fltarr(501,501)
    te = fltarr(501,501)
    te_mean = fltarr(501,501)
    mask = fltarr(501,501)

    FOR i=0, 500 DO BEGIN
      FOR j=0, 500 DO BEGIN
        em[i,j] = total(reform(emcube[i,j,*]))*(pixel_size_cm^2) ; this is in 1d26 cm-3
        m = max(reform(emcube[i,j,*]),pos)
        moy = total(reform(emcube[i,j,*])*lgtaxis)/n_elements(lgtaxis)
        if em[i,j] GT 1d16 then mask[i,j] = 1
        te[i,j] = 10^(lgtaxis[pos])
        te_mean[i,j] = 10^(moy)
      ENDFOR
    ENDFOR

    mask_nonth_sel = where(em/1d23*1d49 GT 1d44)
    mask_nonth = fltarr(501,501)
    mask_nonth[mask_nonth_sel] = 1

      j = image(mask_nonth,title='Mask for nonthermal')

      i=image(alog10(em/1d23*1d49), rgb=13,title='Emission Measure', position=[0.20,0.05,0.99,0.9])
      c = colorbar(target=i, orientation=1, position=[0.15,0.05,0.20,0.9], title="log(EM [cm-3])")
      sym = symbol([70,53]*4,[60,61]*4, 'square',/data,sym_siz=1, sym_thick=2)
      
      pix_size = 0.6 ; arcsec
      theta=indgen(1000)/1000.*!pi*2.02
      
      r = 1.5 ; arcsec
      xl = r/pix_size*cos(theta)
      yl = r/pix_size*sin(theta)
      s = scatterplot(xl + 20, yl + 465, sym='.', sym_color='white', /over, xr=[0,500], yr=[0,500])
      t = text(40, 450, '3 arcsec', target = i, /data, font_size=10, color='white')
      
      r = 5. ; arcsec
      xl = r/pix_size*cos(theta)
      yl = r/pix_size*sin(theta)
      s = scatterplot(xl + 20, yl + 435, sym='.', sym_color='white', /over, xr=[0,500], yr=[0,500])
      t = text(40, 420, '10 arcsec', target = i, /data, font_size=10, color='white')

  ENDIF
  stop
END
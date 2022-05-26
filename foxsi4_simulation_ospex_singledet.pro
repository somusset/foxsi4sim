PRO foxsi4_simulation_ospex_singledet, num=num, int_time=int_time, counting_stat=counting_stat, highres=highres, cmos=cmos, pinhole=pinhole, $
          energy_resolution=energy_resolution, energy_bin=energy_bin, erange=erange, FP=FP, CS=CS, nonthermal=nonthermal
  
  ; PURPOSE:
  ; Generate simulated FOXSI-4 count spectrum for a single detector (CdTe/CMOS) and try photon spectrum reconstruction
  ; through spectral fitting in OPSEX.
  ; 
  ; Keywords: 
  ; NUM: flare label, 1 for M3 flare, 3 for C3 flare
  ; int_time: integration time in seconds
  ; counting_stat: if set, add Poisson noises
  ; highres: if set, use MSFC high resolution optics; otherwise, use the 10-shell optics for CdTe 
  ;          or use the Nagoya optics for CMOS
  ; cmos: if set, use the CMOS detector; otherwise, use the CdTe detector
  ; pinhole: if set, use the pinhole attenuator; otherwise, use the plain Al attenuator
  ; energy_resolution: energy resolution of the detector in keV
  ; energy_bin: energy bin size in keV for the count spectrum
  ; erange: energy range for spectral fitting [e_start,e_end] (keV)
  ; fp: if set, only take the footpoint spectrum
  ; cs: if set, only take the looptop spectrum (coronal source)
  ;     (If fp and cs are both 0, it uses spatially integrated spectrum.)
  ; nonthermal: if set, include nonthermal part in spectral fitting
  ;             (should always be 0 for CMOS, could be set for CdTe)
  ;
  ; NOTES: 
  ; Only tested for two RHESSI flares.
  ; Adapted from foxsi4_proposal_figure.pro and foxsi_ospex.pro 
  ; 
  ; HISTORY:
  ; 2022/05/11, Y.Zhang, initial release
 
 
  default, NUM, 1 
  default, int_time, 10. ; seconds
  default, counting_stat, 1.   
  default, highres, 0 
  default, cmos, 0    
  default, pinhole, 0 
  default, fp, 0      
  default, cs, 0      
  default, nonthermal, 0   
                           
  
  IF cmos EQ 0 THEN default, erange, [5.4,15.] ELSE default, erange, [5.4,10.]   ;energy range for spectral fitting

  IF CMOS EQ 1 THEN DEFAULT, energy_bin, 0.02 ELSE DEFAULT, energy_bin, 0.1
  
  IF cmos EQ 0 THEN BEGIN
    cdte = 1
    ATT_CDTE = 380 ; MICRONS
    IF highres EQ 1 THEN ATT_CDTE = 260. ; microns
    IF highres EQ 1 THEN BEGIN
      msfc_high_res=1 
      highresstring = 'msfc-hr'
    ENDIF ELSE BEGIN
      msfc_high_res=0
      highresstring = 'module6'
    ENDELSE
  ENDIF ELSE BEGIN
    cdte = 0
    ATT_CMOS = 180. ; MICRONS
    IF highres EQ 1 THEN BEGIN
      msfc_high_res = 1
      highresstring = 'msfc-hr'
    ENDIF ELSE BEGIN
      msfc_high_res = 0
      high_res_j_optic=1
      highresstring = 'nagoya'
    ENDELSE
  ENDELSE

  IF keyword_set(energy_resolution) THEN eresstring='_dE='+strtrim(string(energy_resolution),2)+'keV' ELSE eresstring=''
  
  IF num EQ 1 THEN BEGIN
    foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
    goesclass = 'm35'
    goesclass_tit = 'M3.5'
  ENDIF

  IF num EQ 3 THEN BEGIN
    foxsi4_flare_simulation_c3, FP_spectrum, FP2_spectrum,  CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
    goesclass = 'c26'
    goesclass_tit = 'C2.6'
  ENDIF

  input_photon_spec = full_spectrum
  IF FP EQ 1 THEN input_photon_spec = FP_spectrum
  IF CS EQ 1 THEN input_photon_spec = CS_spectrum


  IF cmos EQ 0 THEN BEGIN  ;get count spectrum for CdTe
    
    IF pinhole EQ 1 THEN att_cdte=0
    al_um = round(ATT_CDTE)
    al_attstr_cdte = strtrim(string(al_um),2)
    attstrcdte =al_attstr_cdte+'um'

    foxsi4_calculate_and_plot_count_spectrum, input_photon_spec, cdte=1, al_um=al_um, pinhole=pinhole, energy_edges=energy_edges,$
      msfc_high_res=msfc_high_res, energy_resolution=energy_resolution, energy_bin=energy_bin, window_ind=4, $
      plot_title='Count spectrum CdTe + '+highresstring,save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], $
      chars=chars,plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_'+highresstring+'-'+attstrcdte+eresstring+'.png',$
      att_str = 'Al '+al_attstr_cdte+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat
      
  ENDIF ELSE BEGIN      ;get count spectrum for CMOS
    
    al_um = round(ATT_CMOS)
    al_attstr_cmos = strtrim(string(al_um),2)
    attstrcmos = al_attstr_cmos+'um'

    foxsi4_calculate_and_plot_count_spectrum, input_photon_spec, cmos=1,  al_um=al_um, pinhole=pinhole, energy_edges=energy_edges, $
      high_res_j_optic=high_res_j_optic,  msfc_high_res=msfc_high_res, $
      energy_resolution=energy_resolution, energy_bin=energy_bin, window_ind=4, $
      plot_title='Count spectrum CMOS + '+highresstring, save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'],$
      chars=chars, plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cmos_'+highresstring+'-'+attstrcmos+eresstring+'.png', $
      att_str = 'Al '+al_attstr_cmos+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat
  ENDELSE
  
  ; stop


  ; Below starts spectral fitting:

  spec=full_list_counts[0]
  
  i = where( spec.energy_kev gt 3. and spec.energy_kev lt 30. )
  enm = spec.energy_kev[i]
  en_lo = enm - 0.5*energy_bin
  en_hi = enm + 0.5*energy_bin
  en2 = transpose( [[en_lo],[en_hi]] )
  eff=1.

  ; create response matrix
  resp = foxsi4_effective_area( enm, al_um=al_um, cmos=cmos, cdte=cdte, high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res, pinhole=pinhole )
  max_EA = max(resp.eff_area_cm2[where(resp.eff_area_cm2 ge 0.)]) ;determine maximum effective area
  ;normalize effective area
  diag = resp.eff_area_cm2 * eff / max_EA
  ndiag = n_elements( diag )
  nondiag = fltarr(ndiag,ndiag)   ;create array for nondiagonal response

  for j=0, ndiag-1 do nondiag[j,j]=diag[j]        ;set diagonal of nondiag to the diagonal response (cm^2)
  sigma = energy_resolution / 2.355            ; energy resolution is FWHM
  toty = total(gaussian(findgen(ndiag),[0.3989*energy_bin/sigma,round(((30-3)/(2*energy_bin))-1.),sigma/energy_bin] ))
        ; toty is a sum of the values of a normalized Gaussian function binned according to the set 'bin' keyword.
        ; The standard deviation for the Gaussian is normalized to the bin size (sigma/bin).
        ; toty should be equal to one, but is slightly off due to rounding.

  ; compute the nondiagonal response by convolving diagonal response with a Gaussian
  for j=0, ndiag-1 do begin
        y = diag[j]*gaussian( findgen(ndiag), [0.3989*energy_bin/sigma,j,sigma/energy_bin] )/toty
                ; y is the convolution of the diagonal response value diag[j] with a
                ; Gaussian function of standard deviation sigma/bin.
                ; The values are normalized using toty (described above).
        nondiag[*,j] = y
  endfor
 

  ;create livetime array
  livetime_array = fltarr(ndiag)
  livetime_array[*] = int_time

  ; run ospex for spectral analysis
  o = ospex(/no_gui)
  o -> set, spex_data_source = 'SPEX_USER_DATA'
  o -> set, spectrum = spec.count_flux[i]*energy_bin*int_time, spex_ct_edges = en2, errors = sqrt(spec.count_flux[i]*energy_bin*int_time),livetime=livetime_array
  o -> set, spex_respinfo = nondiag/energy_bin
  o -> set, spex_area = max_EA

 
  If nonthermal eq 0 then begin
    o-> set, fit_function= 'vth'   ; optically thin thermal plasma model (isothermal) 
    o-> set, fit_comp_params= [0.2, 1.0, 1.00000]
    o-> set, fit_comp_free_mask= [1B, 1B, 0B]
    o-> set, fit_comp_spectrum= ['full']
    o-> set, fit_comp_model= ['chianti']
    o-> set, spex_erange = erange
  Endif else begin
    o-> set, fit_function= 'vth+thick2' ; isothermal + thick-target model
    o-> set, fit_comp_params= [0.2, 1.0, 1.00000, 2., 5., 33000, 0.00, 10.0, 32000]
    o-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]
    o-> set, fit_comp_spectrum= ['full', '']
    o-> set, fit_comp_model= ['chianti', '']
    o-> set, spex_erange = erange
  Endelse

  ;o-> set, spex_fit_manual=0
  ;o-> set, spex_autoplot_enable=1

  o-> dofit
  o-> savefit
  stop

END

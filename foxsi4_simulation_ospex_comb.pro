PRO foxsi4_simulation_ospex_comb, num=num, int_time=int_time, counting_stat=counting_stat, highres=highres, pinhole=pinhole, $
          FP=FP, CS=CS

; PURPOSE:
; Photon spectrum reconstruction with OSPEX for the M3/C3 RHESSI flare.
; 
; DESCRIPTION:
; This routine is similar to foxsi4_simulation_ospex_singledet.pro, but it uses a combination of CdTe and CMOS detectors
; to achieve better results. The strategy is to first use the CMOS detector to fit, then take (only) the fitted thermal 
; parameters as fixed inputs for the CdTe detector and use CdTe to get the non-thermal parameters.
; For the M3 flare, it's hard for the CMOS detector to see the non-thermal part, so in the first step we only use an 
; isothermal model to fit. For the C3 flare, the CMOS detector can see some non-thermal emissions, so we add a non-thermal
; component in the CMOS fitting even though we're not going use those non-thermal parameters.
; Additionally, compared to default energy bins (0.8keV for CdTe and 0.2keV for CMOS), finer energy bins (0.1keV for CdTe 
; and 0.02keV for CMOS) work better for the M3 flare, but not for the C3 flare. The C3 flare even needs more rebinning at 
; higher energies because of low statistics. Probably we need more exploration of binning when trying to analyze real data.
; 
; Notes:
; Currently only match the CMOS detector with Nagoya optics in the code. The CdTe detector could be matched with either 
; 10-shell optics or MSFC high-res optics. (In practice there are more combinations.)
;
; Keywords:
; NUM: flare label, 1 for M3 flare, 3 for C3 flare
; int_time: integration time in seconds
; counting_stat: if set, add Poisson noises
; highres: (only applicable to CdTe) if set, use MSFC high resolution optics; otherwise, use the 10-shell optics.
; pinhole: if set, use the pinhole attenuator; otherwise, use the plain Al attenuator
; fp: if set, only take the footpoint spectrum
; cs: if set, only take the looptop spectrum (coronal source)
;     (If fp and cs are both 0, it uses spatially integrated spectrum.)
;
; HISTORY:
; 2022/05/11, Y.Zhang, initial release
;


  Default, NUM, 1 
  IF num EQ 1 THEN Default, int_time, 10. ELSE Default, int_time, 60.
  Default, counting_stat, 1   
  Default, highres, 0 
  Default, fp, 1
  Default, cs, 0  
  Default, pinhole, 0
  
  ; Define attenuator length for each detector
  ATT_CDTE = 380 ; MICRONS
  IF highres EQ 1 THEN ATT_CDTE = 260. ; microns
  IF highres EQ 1 THEN BEGIN
    msfc_high_res=1 
    highresstring = 'msfc-hr'
  ENDIF ELSE BEGIN
    msfc_high_res=0
    highresstring = 'module6'
  ENDELSE
  ATT_CMOS = 180. ; MICRONS

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

  ;-------------------------------------------------------;
  ; FIRST USE CMOS DETECTOR TO RECOVER THERMAL PARAMETERS ;
  ;-------------------------------------------------------;
  al_um = round(ATT_CMOS)
  al_attstr_cmos = strtrim(string(al_um),2)
  
  If num EQ 1 then energy_bin = 0.02 ELSE energy_bin = 0.2
  energy_resolution_cmos = 0.2

  foxsi4_calculate_and_plot_count_spectrum, input_photon_spec, cmos=1, high_res_j_optic=1, al_um=al_um, energy_edges=energy_edges, $
    window_ind=4, plot_title='Count spectrum CMOS + J-high res', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'],$
    chars=chars, plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cmos_jhighres_Al-'+al_attstr_cmos+'um'+eresstring+'.png', $
    att_str = 'Al '+al_attstr_cmos+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat,$
    energy_bin=energy_bin

  spec=full_list_counts[0]
  
  If num Eq 1 Then Begin  ;M3 flare
    i = where( spec.energy_kev gt 3. and spec.energy_kev lt 25. )
    enm = spec.energy_kev[i]
    en_lo = enm - 0.5*energy_bin
    en_hi = enm + 0.5*energy_bin
    en2 = transpose( [[en_lo],[en_hi]] )
  
    ; create response matrix for CMOS
    resp = foxsi4_effective_area( enm, al_um=al_um, cmos=1, cdte=0, high_res_j_optic=1, msfc_high_res=0 )
    max_EA = max(resp.eff_area_cm2[where(resp.eff_area_cm2 ge 0.)]) ;determine maximum effective area
    ;normalize effective area
    diag = resp.eff_area_cm2 / max_EA
    ndiag = n_elements( diag )
    nondiag = fltarr(ndiag,ndiag)   ;create array for nondiagonal response

    for j=0, ndiag-1 do nondiag[j,j]=diag[j]        ;set diagonal of nondiag to the diagonal response (cm^2)
    sigma = energy_resolution_cmos / 2.355            ; energy resolution is FWHM
    toty = total(gaussian(findgen(ndiag),[0.3989*energy_bin/sigma,round(((25-3)/(2*energy_bin))-1.),sigma/energy_bin] ))
        ; toty is a sum of the values of a normalized Gaussian function binned according to the set 'bin' keyword.
        ; The standard deviation for the Gaussian is normalized to the bin size (sigma/bin).
        ; toty should be equal to one, but is slightly off due to approximation.

    ; compute the nondiagonal response by convolving diagonal response with a Gaussian
    for j=0, ndiag-1 do begin
      y = diag[j]*gaussian( findgen(ndiag), [0.3989*energy_bin/sigma,j,sigma/energy_bin] )/toty
      ;y=diag[j]/energy_bin*(gauss_pdf((en_hi - enm[j])/sigma )-gauss_pdf((en_lo - enm[j])/sigma ))
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
    o-> set, fit_function= 'vth'   ; isothermal
            ; note: only need to do a thermal fit for CMOS detector when simulating M3 flare,
            ;       beacuse the non-thermal part is hard to see in the dectector's energy range
    o-> set, fit_comp_params= [0.2, 1.0, 1.00000]
    o-> set, fit_comp_free_mask= [1B, 1B, 0B]
    o-> set, fit_comp_spectrum= ['full', '']
    o-> set, fit_comp_model= ['chianti', '']
    o-> set, spex_erange = [5.4,10.]

    count_rates = spec.count_flux[i]*energy_bin

  Endif Else Begin  ;C3 flare
    ; for c3 flare we need to widen the bins at higher energies because of low statistics
    ; this part is some sort of rebinning, and the new bin sizes will be: 3~8.2keV: 0.2keV, 8.2~12.4keV: 0.6keV, 12.4~19.4keV: 1keV  
    i = where( spec.energy_kev gt 3. and spec.energy_kev lt 8.2 )
    enm1 = spec.energy_kev[i]
    en_lo1 = enm1 - 0.5*0.2
    en_hi1 = enm1 + 0.5*0.2
    count_rates1 = spec.count_flux[i]*energy_bin
    i = where( spec.energy_kev gt 8.2 and spec.energy_kev lt 12.4 )
    enm2 = spec.energy_kev[i]
    en_lo2 = enm2 - 0.5*0.2
    en_hi2 = enm2 + 0.5*0.2
    count_rates2 = spec.count_flux[i]*energy_bin
    en_lo2 = en_lo2[0:20:3]
    en_hi2 = en_hi2[2:20:3]
    count_rates2 = count_rates2[0:20:3]+count_rates2[1:20:3]+count_rates2[2:20:3]
    i = where( spec.energy_kev gt 12.4 and spec.energy_kev lt 19.4 )
    enm3 = spec.energy_kev[i]
    en_lo3 = enm3 - 0.5*0.2
    en_hi3 = enm3 + 0.5*0.2
    count_rates3 = spec.count_flux[i]*energy_bin
    en_lo3 = en_lo3[0:34:5]
    en_hi3 = en_hi3[4:34:5]
    count_rates3 = count_rates3[0:34:5]+count_rates3[1:34:5]+count_rates3[2:34:5]+count_rates3[3:34:5]+count_rates3[4:34:5]
    ; new bin edges and count rates
    en_lo = [en_lo1,en_lo2,en_lo3]
    en_hi = [en_hi1,en_hi2,en_hi3]
    en2 = transpose( [[en_lo],[en_hi]] )
    enm = get_edges(en2,/mean)
    count_rates = [count_rates1,count_rates2,count_rates3]
    bin_width = en_hi - en_lo
  
    ; create response matrix
    resp = foxsi4_effective_area( enm, al_um=al_um, cmos=1, cdte=0, high_res_j_optic=1, msfc_high_res=0 )
    max_EA = max(resp.eff_area_cm2[where(resp.eff_area_cm2 ge 0.)]) ;determine maximum effective area
    ;normalize effective area
    diag = resp.eff_area_cm2/max_EA
    ndiag = n_elements( diag )
    nondiag = fltarr(ndiag,ndiag)   ;create array for nondiagonal response

    for j=0, ndiag-1 do nondiag[j,j]=diag[j]/bin_width[j]        ;set diagonal of nondiag to the diagonal response (cm^2)
    sigma = energy_resolution_cmos / 2.355            ; energy resolution is FWHM
    toty = total(gaussian( enm, [0.3989/sigma,enm[30],sigma] ))    ; not equal to 1 in this case  
    
    ; compute the nondiagonal response by convolving diagonal response with a Gaussian
    for j=0, ndiag-1 do begin
        y = diag[j]/bin_width*gaussian( enm, [0.3989/sigma,enm[j],sigma] )/toty
            ; In principle, if a variable follows Gaussian distribution, the probability that it falls within each bin should be
            ; the integral of Gaussian in that bin. Here for simplicity we use values at median as an approximation.
            ; The values are normalized using toty.
        nondiag[*,j] = y
    endfor
    
    ;create livetime array
    livetime_array = fltarr(ndiag)
    livetime_array[*] = int_time
 
    ; run ospex for spectral analysis
    o = ospex(/no_gui)
    o -> set, spex_data_source = 'SPEX_USER_DATA'
    o -> set, spectrum = count_rates*int_time, spex_ct_edges = en2, errors = sqrt(count_rates*int_time),livetime=livetime_array
    o -> set, spex_respinfo = nondiag
    o -> set, spex_area = max_EA

    o-> set, fit_function= 'vth+thick2'   
    o-> set, fit_comp_params= [0.01, 1.0, 1.00000,2.,5.,33000,0.00,10.0,32000]
    o-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]
    o-> set, fit_comp_spectrum= ['full', '']
    o-> set, fit_comp_model= ['chianti', '']
    o-> set, spex_erange = [6.,12.]

  ENDELSE
    
  o-> set, spex_fit_manual=0
  o-> set, spex_autoplot_enable=1

  o-> dofit
  
  cmos_fit_params = o -> get(/fit_comp_params)


  ;----------------------------------------------------;
  ; NOW USE CDTE DETECTOR TO FIT NONTHERMAL PARAMETERS ;
  ;----------------------------------------------------;
  If pinhole eq 1 then att_cdte=0
  al_um = round(ATT_CDTE)
  al_attstr_cdte = strtrim(string(al_um),2)
  attstrcdte =al_attstr_cdte+'um'

 energy_bin = 0.1
 
  foxsi4_calculate_and_plot_count_spectrum, input_photon_spec, cdte=1, al_um=al_um, pinhole=pinhole, energy_edges=energy_edges,$
    energy_resolution=energy_resolution, window_ind=4, plot_title='Count spectrum CdTe + '+highresstring,save=save, $
    energy_bin=energy_bin, plot_legend= [goesclass_tit, 'Integrated spectrum'], $
    chars=chars,plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_'+highresstring+'-'+attstrcdte+eresstring+'.png',$
        att_str = 'Al '+al_attstr_cdte+' um', list_counts=full_list_counts, int_time=int_time, counting_stat=counting_stat, msfc_high_res=msfc_high_res
 
  spec=full_list_counts[0]

  i = where( spec.energy_kev gt 3. and spec.energy_kev lt 23. )
  enm = spec.energy_kev[i]
  en_lo = enm - 0.5*energy_bin
  en_hi = enm + 0.5*energy_bin
  en2 = transpose( [[en_lo],[en_hi]] )
  eff=1.
  
  ; create response matrix for CdTe
  resp = foxsi4_effective_area( enm, al_um=al_um, cmos=0, cdte=1, high_res_j_optic=0, msfc_high_res=msfc_high_res, pinhole=pinhole )
  max_EA = max(resp.eff_area_cm2[where(resp.eff_area_cm2 ge 0.)]) ;determine maximum effective area
  ;normalize effective area and multiply by ratio of good to all events
  diag = resp.eff_area_cm2 * eff / max_EA
  ndiag = n_elements( diag )
  nondiag = fltarr(ndiag,ndiag)   ;create array for nondiagonal response

  for j=0, ndiag-1 do nondiag[j,j]=diag[j]/energy_bin        ;set diagonal of nondiag to the diagonal response (cm^2)
  sigma = energy_resolution / 2.355            ; energy resolution is FWHM
  toty = total(gaussian(findgen(ndiag),[0.3989*energy_bin/sigma,round((20/(2*energy_bin))-1.),sigma/energy_bin] ))
      ; toty is a sum of the values of a normalized Gaussian function binned according to the set 'bin' keyword.
      ; The standard deviation for the Gaussian is normalized to the bin size (sigma/bin).
      ; toty should be equal to one, but is slightly off due to approximation.

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

  o-> set, fit_function= 'vth+thick2'
  o-> set, fit_comp_params= [cmos_fit_params[0:2], 2., 4., 33000, 0.00, 20.0, 32000]
  ;o-> set, fit_comp_params= [cmos_fit_params[0:2], 2., 5., 33000, 0.00, 10.0, 32000]
  o-> set, fit_comp_free_mask= [0B, 0B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]
  o-> set, fit_comp_spectrum= ['full', '']
  o-> set, fit_comp_model= ['chianti', '']
  IF num EQ 1 THEN o-> set, spex_erange = [6.,20.] ELSE o-> set, spex_erange = [6.,15.]
  
  ;o-> set, spex_fit_manual=0
  o-> set, spex_autoplot_enable=1
  o-> dofit

  cdte_fit_params = o -> get(/fit_comp_params) 
  stop

END

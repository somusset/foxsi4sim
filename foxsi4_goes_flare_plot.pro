PRO foxsi4_goes_flare_plot, highres=highres
  
; PURPOSE:  
; Simulate count spectra for typical flares of different GOES classes (C1,C5,M1,M5,X1)
; 
; DESCRIPTION:
; This routine was produced to help finalize the design for pinhole attenuators.
; It produces FOXSI count spectra for typical C1-X1 flares with optics (10-shell or MSFC high-res) + CdTe detector 
; + attenuator (plain Al or pinhole) and makes plots. It also calculates the count rates for each flare class and 
; the corresponding pileup fraction assuming photons hit 2-8 strips on the detector. The thickness of the plain Al 
; attenuator was chosen to match the count rates with the pinhole attenuator. Particularly for the X1 class flare, 
; it generates another plot for using both the pinhole attenuator and an additional Al attenuator.
;
; KEYWORDS:
; highres: if set to 1, use MSFC high-res optics; otherwise, use 10-shell optics (default).
;
; HISTORY:
; 2022/05/11, Y.Zhang, initial release
;
  
  
  Default, highres, 0
  
  screen_dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution)
  window_xsize = fix(0.5*screen_dimensions[0])
  window_ysize = fix(window_xsize)
  
  If highres eq 1 then begin
    al_um = 260   ; Al attenuator thickness when using MSFC high resolution optics
    optstr = 'msfc_highres'
    msfc_high_res = 1
  Endif else begin
    al_um = 380   ; Al attenuator thickness when using 10-shell optics
    optstr = '10 shell'
    msfc_high_res = 0
  Endelse
  attstr = strtrim(string(al_um),2)
  
  ;----------;
  ; C1 flare ;
  ;----------;
  goesflux = 1e-6
  
  ; simulate photon spectrum
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with plain Al attenuator
  count_al_c1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  totcount_al_c1 = total(count_al_c1.count_Rate)
  pileup_frac_al_c1 = [1-exp(-totcount_al_c1/2*3.2e-6),1-exp(-totcount_al_c1/8*3.2e-6)]  ;pileup fraction assuming 2 or 8 strips
  
  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with pinhole attenuator
  count_pinh_c1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh_c1 = total(count_pinh_c1.count_Rate)
  pileup_frac_pinh_c1 = [1-exp(-totcount_pinh_c1/2*3.2e-6),1-exp(-totcount_pinh_c1/8*3.2e-6)]  ;pileup fraction assuming 2 or 8 strips
 
  ;----------;
  ; C5 flare ;
  ;----------;
  goesflux = 5e-6

  ; simulate photon spectrum
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with plain Al attenuator
  count_al_c5 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  totcount_al_c5 = total(count_al_c5.count_Rate)
  pileup_frac_al_c5 = [1-exp(-totcount_al_c5/2*3.2e-6),1-exp(-totcount_al_c5/8*3.2e-6)]

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with pinhole attenuator
  count_pinh_c5 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh_c5 = total(count_pinh_c5.count_Rate)
  pileup_frac_pinh_c5 = [1-exp(-totcount_pinh_c5/2*3.2e-6),1-exp(-totcount_pinh_c5/8*3.2e-6)]

  ;----------;
  ; M1 flare ;
  ;----------;
  goesflux = 1e-5

  ; simulate photon spectrum
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with plain Al attenuator
  count_al_m1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  totcount_al_m1 = total(count_al_m1.count_Rate)
  pileup_frac_al_m1 = [1-exp(-totcount_al_m1/2*3.2e-6),1-exp(-totcount_al_m1/8*3.2e-6)]

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with pinhole attenuator
  count_pinh_m1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh_m1 = total(count_pinh_m1.count_Rate)
  pileup_frac_pinh_m1 = [1-exp(-totcount_pinh_m1/2*3.2e-6),1-exp(-totcount_pinh_m1/8*3.2e-6)]

  ;----------;
  ; M5 flare ;
  ;----------;
  goesflux = 5e-5

  ; simulate photon spectrum
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with plain Al attenuator
  count_al_m5 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  totcount_al_m5 = total(count_al_m5.count_Rate)
  pileup_frac_al_m5 = [1-exp(-totcount_al_m5/2*3.2e-6),1-exp(-totcount_al_m5/8*3.2e-6)]

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with pinhole attenuator
  count_pinh_m5 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh_m5 = total(count_pinh_m5.count_Rate)
  pileup_frac_pinh_m5 = [1-exp(-totcount_pinh_m5/2*3.2e-6),1-exp(-totcount_pinh_m5/8*3.2e-6)]
  
  ;----------;
  ; X1 flare ;
  ;----------;
  goesflux = 1e-4

  ; simulate photon spectrum
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with plain Al attenuator
  count_al_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  totcount_al_x1 = total(count_al_x1.count_Rate)
  countth_al_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  countnth_al_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um, msfc_high_res=msfc_high_res)
  pileup_frac_al_x1 = [1-exp(-totcount_al_x1/2*3.2e-6),1-exp(-totcount_al_x1/8*3.2e-6)]

  ; simulate count spectrum for cdte+optics (10-shell or MSFC high-res) with pinhole attenuator
  count_pinh_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh_x1 = total(count_pinh_x1.count_Rate)
  countth_pinh_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  countnth_pinh_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, pinhole=1, msfc_high_res=msfc_high_res)
  pileup_frac_pinh_x1 = [1-exp(-totcount_pinh_x1/2*3.2e-6),1-exp(-totcount_pinh_x1/8*3.2e-6)]

  ; simulate count spectrum for cdte+optics with pinhole attenuator + additional Al attenuator
  If highres eq 0 then al_um2=250 Else al_um2=120  ; thickness for the additional Al attenuator
  attstr2 = strtrim(string(al_um2),2)
  count_pinh2_x1 = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um2, pinhole=1, msfc_high_res=msfc_high_res)
  totcount_pinh2_x1 = total(count_pinh2_x1.count_Rate)
  pileup_frac_pinh2_x1 = [1-exp(-totcount_pinh2_x1/2*3.2e-6),1-exp(-totcount_pinh2_x1/8*3.2e-6)]
  window, 3, xs=window_xsize, ys=window_ysize
  plot, count_pinh2_x1.energy_kev, count_pinh2_x1.count_flux, chars=2, thick=2, charth=2, xth=2, yth=2, background=1, color=0, /xlog, /ylog,$
    /xsty, title='CdTe + '+optstr+', Al '+attstr2+'um'+'+Pinhole', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', $
    yr=[1.,1d6], xr=[3.,30.]
  al_legend, ['X1: '+strtrim(string(round(totcount_pinh2_x1)),2)+' c/s, '+string(pileup_frac_pinh2_x1[1],format='(F6.4)')+'-'+string(pileup_frac_pinh2_x1[0],format='(F6.4)')],$
             chars=2, charth=2, box=0

  ; make plots
  ; C1-X1 flares, Al attenuator
  sophie_linecolors
  window, 1, xs=window_xsize, ys=window_ysize
  plot, count_al_c1.energy_kev, count_al_c1.count_flux, chars=2, thick=2, charth=2, xth=2, yth=2, background=1, color=0, /xlog, /ylog,$
    /xsty, title='Count flux CdTe + '+optstr+', Al '+attstr+'um', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', $
    yr=[1.,1d6], xr=[3.,30.]
  oplot, count_al_c5.energy_kev, count_al_c5.count_flux, psym=10, color=3, thick=2
  oplot, count_al_m1.energy_kev, count_al_m1.count_flux, psym=10, color=6, thick=2
  oplot, count_al_m5.energy_kev, count_al_m5.count_flux, psym=10, color=9, thick=2
  oplot, count_al_x1.energy_kev, count_al_x1.count_flux, psym=10, color=14, thick=2
  al_legend, ['C1','C5','M1','M5','X1'], chars=2, charth=2, box=0, color=[0,3,6,9,14], linestyle=[0,0,0,0,0], linsi=0.2, thick=2, /right
  al_legend, ['C1: '+strtrim(string(round(totcount_al_c1)),2)+' c/s, '+string(pileup_frac_al_c1[1],format='(F6.4)')+'-'+string(pileup_frac_al_c1[0],format='(F6.4)'),$
              'C5: '+strtrim(string(round(totcount_al_c5)),2)+' c/s, '+string(pileup_frac_al_c5[1],format='(F6.4)')+'-'+string(pileup_frac_al_c5[0],format='(F6.4)'),$
              'M1: '+strtrim(string(round(totcount_al_m1)),2)+' c/s, '+string(pileup_frac_al_m1[1],format='(F6.4)')+'-'+string(pileup_frac_al_m1[0],format='(F6.4)'),$
              'M5: '+strtrim(string(round(totcount_al_m5)),2)+' c/s, '+string(pileup_frac_al_m5[1],format='(F6.4)')+'-'+string(pileup_frac_al_m5[0],format='(F6.4)'),$
              'X1: '+strtrim(string(round(totcount_al_x1)),2)+' c/s, '+string(pileup_frac_al_x1[1],format='(F6.4)')+'-'+string(pileup_frac_al_x1[0],format='(F6.4)')],$
              chars=2, charth=2, box=0

  ; C1-X1 flares, pinhole attenuator
  window, 2, xs=window_xsize, ys=window_ysize
  plot, count_pinh_c1.energy_kev, count_pinh_c1.count_flux, chars=2, thick=2, charth=2, xth=2, yth=2, background=1, color=0, /xlog, /ylog,$
    /xsty, title='Count flux CdTe + '+optstr+', Pinhole', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1.,1d6], xr=[3.,30.]
  oplot, count_pinh_c5.energy_kev, count_pinh_c5.count_flux, psym=10, color=3, thick=2
  oplot, count_pinh_m1.energy_kev, count_pinh_m1.count_flux, psym=10, color=6, thick=2
  oplot, count_pinh_m5.energy_kev, count_pinh_m5.count_flux, psym=10, color=9, thick=2
  oplot, count_pinh_x1.energy_kev, count_pinh_x1.count_flux, psym=10, color=14, thick=2
  al_legend, ['C1','C5','M1','M5','X1'], chars=2, charth=2, box=0, color=[0,3,6,9,14], linestyle=[0,0,0,0,0], linsi=0.2, thick=2, /right
  al_legend, ['C1: '+strtrim(string(round(totcount_pinh_c1)),2)+' c/s, '+string(pileup_frac_pinh_c1[1],format='(F6.4)')+'-'+string(pileup_frac_pinh_c1[0],format='(F6.4)'),$
              'C5: '+strtrim(string(round(totcount_pinh_c5)),2)+' c/s, '+string(pileup_frac_pinh_c5[1],format='(F6.4)')+'-'+string(pileup_frac_pinh_c5[0],format='(F6.4)'),$
              'M1: '+strtrim(string(round(totcount_pinh_m1)),2)+' c/s, '+string(pileup_frac_pinh_m1[1],format='(F6.4)')+'-'+string(pileup_frac_pinh_m1[0],format='(F6.4)'),$
              'M5: '+strtrim(string(round(totcount_pinh_m5)),2)+' c/s, '+string(pileup_frac_pinh_m5[1],format='(F6.4)')+'-'+string(pileup_frac_pinh_m5[0],format='(F6.4)'),$
              'X1: '+strtrim(string(round(totcount_pinh_x1)),2)+' c/s, '+string(pileup_frac_pinh_x1[1],format='(F6.4)')+'-'+string(pileup_frac_pinh_x1[0],format='(F6.4)')],$
              chars=2, charth=2, box=0

  stop
  
 
END
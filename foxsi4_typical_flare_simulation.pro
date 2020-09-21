PRO foxsi4_typical_flare_simulation, goesflux, goesclass, save=save
; goes flux is a number
; goes class is a string style 'c5'

  DEFAULT, save, 0

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE PHOTON FLUX
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate photon spectrum and plot it
  
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  set_line_color
  window, 0, xs=1000, ys=1200
  plot, phflux.energy_kev, phflux.photon_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Photon flux, '+goesclass+' flare', psym=10, xtitle='Energy (keV)', ytitle='Photons/s/cm2/keV'
  oplot, phflux.energy_kev, phflux.thermal_flux, thick=3, color=3, linestyle=2
  oplot, phflux.energy_kev, phflux.nonthermal_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  
  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_photon_flux.png', TVRD(/TRUE)

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE COUNT FLUX WITH CDTE + MODULE 6
  ;------------------------------------------------------------------------------------------------------------------------------
  
  ; simulate cdte+module6 optics without attenuator and plot
  
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in)

  set_line_color
  window, 1, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['no att',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
 ; FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_module6.png', TVRD(/TRUE)

  ; find best attenuator in al and do the same but with attenuation
  
  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, al=1)
  al_um = round(bestatt)
  attstr = strtrim(string(al_um),2)
  
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 2, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Al '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_module6_Al-'+attstr+'um.png', TVRD(/TRUE)
  
  ; find best attenuator in be and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, be=1)
  be_um = round(bestatt)
  attstr = strtrim(string(be_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)

  set_line_color
  window, 3, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Be '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_module6_Be-'+attstr+'um.png', TVRD(/TRUE)

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE COUNT FLUX WITH CMOS + J-EF
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate cmos+jef optics without attenuator and plot

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in)

  set_line_color
  window, 4, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CMOS + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['no att',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
  ;FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cmos_jef.png', TVRD(/TRUE)

  ; find best attenuator in al and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cmos=1, high_res_j_optic=1, al=1)
  al_um = round(bestatt)
  attstr = strtrim(string(al_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 5, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CMOS + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Al '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
  ;FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cmos_jef_Al-'+attstr+'um.png', TVRD(/TRUE)

  ; find best attenuator in be and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cmos=1, high_res_j_optic=1, be=1)
  be_um = round(bestatt)
  attstr = strtrim(string(be_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)

  set_line_color
  window, 6, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CMOS + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Be '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
  ;FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cmos_jef_Be-'+attstr+'um.png', TVRD(/TRUE)

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE COUNT FLUX WITH CDTE + J-EF
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate cdte+jef optics without attenuator and plot

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in)

  set_line_color
  window, 7, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['no att',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_jef.png', TVRD(/TRUE)

  ; find best attenuator in al and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, high_res_j_optic=1, al=1)
  al_um = round(bestatt)
  attstr = strtrim(string(al_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 8, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Al '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_jef_Al-'+attstr+'um.png', TVRD(/TRUE)

  ; find best attenuator in be and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, CdTe=1, high_res_j_optic=1, be=1)
  be_um = round(bestatt)
  attstr = strtrim(string(be_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, CdTe=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, CdTe=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, CdTe=1, high_res_j_optic=1, energy_edges=energy_in, be_um=be_um)

  set_line_color
  window, 9, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + J-EF', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Be '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_jef_Be-'+attstr+'um.png', TVRD(/TRUE)

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE COUNT FLUX WITH CDTE + MSFC high resolution
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate cdte+jef optics without attenuator and plot

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in)

  set_line_color
  window, 10, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + MSFC high res', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['no att',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_msfc.png', TVRD(/TRUE)

  ; find best attenuator in al and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, msfc_high_res=1, al=1)
  al_um = round(bestatt)
  attstr = strtrim(string(al_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, msfc_high_res=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 11, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + MSFC high res', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Al '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_msfc_Al-'+attstr+'um.png', TVRD(/TRUE)

  ; find best attenuator in be and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, CdTe=1, msfc_high_res=1, be=1)
  be_um = round(bestatt)
  attstr = strtrim(string(be_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, CdTe=1, msfc_high_res=1, energy_edges=energy_in, be_um=be_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, CdTe=1, msfc_high_res=1, energy_edges=energy_in, be_um=be_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, CdTe=1, msfc_high_res=1, energy_edges=energy_in, be_um=be_um)

  set_line_color
  window, 12, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CdTe + MSFC high res', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Be '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_msfc_Be-'+attstr+'um.png', TVRD(/TRUE)

END
PRO foxsi4_typical_flare_simulation_cea, goesflux, goesclass, save=save, cdte_thick=cdte_thick, chars=chars, loweth=loweth
  ; goes flux is a number
  ; goes class is a string style 'c5'
  ; 
  
  screen_dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution)
  window_xsize = fix(0.25*screen_dimensions[0])
  window_ysize = fix(window_xsize*1.2)
  
  DEFAULT, save, 0
  DEFAULT, cdte_thick, 1000. ; micron, detector thickness
  DEFAULT, chars, 2 ; charsize
  DEFAULT, loweth, 2.
  
  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE PHOTON FLUX
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate photon spectrum and plot it

  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)

  set_line_color
  window, 0, xs=window_xsize, ys=window_ysize
  plot, phflux.energy_kev, phflux.photon_flux, chars=chars, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Photon flux, '+goesclass+' flare', psym=10, xtitle='Energy (keV)', ytitle='Photons/s/cm2/keV'
  oplot, phflux.energy_kev, phflux.thermal_flux, thick=3, color=3, linestyle=2
  oplot, phflux.energy_kev, phflux.nonthermal_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=chars, charth=3, linsi=0.4, box=0, /right

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_photon_flux.png', TVRD(/TRUE)

  ;------------------------------------------------------------------------------------------------------------------------------
  ; SIMULATE COUNT FLUX WITH CDTE CEA LET 2 KEV + MODULE 6
  ;------------------------------------------------------------------------------------------------------------------------------

  ; simulate cdte+module6 optics without attenuator and plot

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, loweth=loweth)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, loweth=loweth)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, loweth=loweth)

  set_line_color
  window, 1, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=chars, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CEA CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=chars, charth=3, linsi=0.4, box=0, /right
  al_legend, ['no att',strtrim(string(round(totcount)),2)+' c/s'], chars=chars, charth=3, box=0, /bottom
  ; FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_cea_module6.png', TVRD(/TRUE)

  ; find best attenuator in al and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, al=1, cea_let=1, det_thick=cdte_thick, loud=0, loweth=2.)
  al_um = round(bestatt)
  attstr = strtrim(string(al_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, al_um=al_um, loweth=loweth)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, al_um=al_um, loweth=loweth)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, al_um=al_um, loweth=loweth)

  set_line_color
  window, 2, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=chars, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CEA CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=chars, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Al '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=chars, charth=3, box=0, /bottom
  ;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_cea_module6_Al-'+attstr+'um.png', TVRD(/TRUE)

  ; find best attenuator in be and do the same but with attenuation

  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, be=1, cea_let=1, det_thick=cdte_thick, loud=0, loweth=2.)
  be_um = round(bestatt)
  attstr = strtrim(string(be_um),2)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, be_um=be_um, loweth=loweth)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, be_um=be_um, loweth=loweth)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, cea_let=1, det_thick=cdte_thick, be_um=be_um, loweth=loweth)

  set_line_color
  window, 3, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=chars, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux ('+goesclass+') CEA CdTe + module 6', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=chars, charth=3, linsi=0.4, box=0, /right
  al_legend, ['Be '+attstr+' um',strtrim(string(round(totcount)),2)+' c/s'], chars=chars, charth=3, box=0, /bottom
  ;  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0, thick=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_'+goesclass+'_count_flux_cdte_cea_module6_Be-'+attstr+'um.png', TVRD(/TRUE)

  
END
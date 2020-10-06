PRO foxsi4_flare_simulations
  
  screen_dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution)
  window_xsize = fix(0.25*screen_dimensions[0])
  window_ysize = fix(window_xsize*1.2)
  
  ; define flare classes to study
  b5 = 5.e-7
  c1 = 1.e-6
  c5 = 5.e-6
  m1 = 1.e-5
  
  ;energy_in = indgen(27)+3
  energy_in = indgen(4000)*0.01+1
  phflux = foxsi4_flare_simulation_from_goesclass(c5, energy_in=energy_in, energy_out=energy_out)
  
  set_line_color
  window, 0, xs=window_xsize, ys=window_ysize
  plot, phflux.energy_kev, phflux.photon_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Photon flux', psym=10, xtitle='Energy (keV)', ytitle='Photons/s/cm2/keV'
  oplot, phflux.energy_kev, phflux.thermal_flux, thick=3, color=3, linestyle=2
  oplot, phflux.energy_kev, phflux.nonthermal_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right

  WRITE_PNG, 'foxsi4_c5_photon_flux.png', TVRD(/TRUE)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in)
  
  bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, al=1)
  
  set_line_color
  window, 1, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom
  
  WRITE_PNG, 'foxsi4_c5_count_flux_cdte_module6.png', TVRD(/TRUE)

  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], [count.error_count_flux[k], count.error_count_flux[k]], color=0

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX,  cdte=1, high_res_j_optic=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX,  cdte=1, high_res_j_optic=1, energy_edges=energy_in)

  set_line_color
  window, 2, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cdte_j-ef.png', TVRD(/TRUE)

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX,  cmos=1, high_res_j_optic=1, energy_edges=energy_in)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX,  cmos=1, high_res_j_optic=1, energy_edges=energy_in)

  set_line_color
  window, 3, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cmos_j-ef.png', TVRD(/TRUE)

  al_um = 200.
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 4, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cdte_module6_al-200um.png', TVRD(/TRUE)
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*count.error_count_flux[k], color=0

  al_um = 100.
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX,  cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX,  cmos=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 5, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cmos_j-ef_al-100um.png', TVRD(/TRUE)
  
  al_um = 50.
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  totcount = total(count.count_Rate)
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX,  cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX,  cdte=1, high_res_j_optic=1, energy_edges=energy_in, al_um=al_um)

  set_line_color
  window, 6, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cdte_j-ef_al-50um.png', TVRD(/TRUE)

  be_um = 1.8d4
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)
  totcount = total(count.count_Rate)
  print,totcount
  countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)
  countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX, cdte=1, energy_edges=energy_in, be_um=be_um)

  set_line_color
  window, 7, xs=window_xsize, ys=window_ysize
  plot, count.energy_kev, count.count_flux, chars=3, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1d-2,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=3, charth=3, linsi=0.4, box=0, /right
  al_legend, [strtrim(string(round(totcount)),2)+' c/s'], chars=3, charth=3, box=0, /bottom

  WRITE_PNG, 'foxsi4_c5_count_flux_cdte_module6_be-18mm.png', TVRD(/TRUE)


    stop

  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1)
  set_line_color
  window, 2, xs=window_xsize, ys=window_ysize
  plot, phflux.energy_kev, count, chars=2, thick=3, charth=2, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10
  count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cdte=1, high_res_j_optic=1)
  oplot, phflux.energy_kev, count, thick=3, linestyle=2

 stop
 
 count = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.PHOTON_FLUX, cmos=1, high_res_j_optic=1)
 countth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.thermal_FLUX,  cmos=1, high_res_j_optic=1)
 countnth = foxsi4_flare_response_simulation(phflux.energy_kev, phflux.nonthermal_FLUX,  cmos=1, high_res_j_optic=1)

 set_line_color
 window, 4, xs=window_xsize, ys=window_ysize
 plot, phflux.energy_kev, count, chars=2, thick=3, charth=2, xth=2, yth=2, background=1, color=0, $
   /xlog, /ylog, /xsty, title='Count flux', psym=10
 oplot, phflux.energy_kev, countth, thick=3, color=3, linestyle=2
 oplot, phflux.energy_kev, countnth, thick=3, color=5, linestyle=2

 
 stop
 
 
 
 
  area = foxsi4_effective_area(energy_out)
  count_flux_0 = phflux*area.eff_area_cm2

  area = foxsi4_effective_area(energy_out, al_um=100)
  count_flux_100 = phflux*area.eff_area_cm2

  window, 1, xs=window_xsize, ys=window_ysize
  plot, energy_out, count_flux_0, chars=2, thick=3, charth=2, xth=2, yth=2, background=1, color=0,$
    /xlog, /ylog, /xsty, title='Count flux', psym=10
  ;oplot, energy_out, count_flux_0, thick=3, psym=10, color=2
  oplot, energy_out, count_flux_100, thick=3, psym=10, color=6
  al_legend, ['no shutter','0.1 mm Al'], textcol=[0,6], box=0, /right, chars=2, charth=2
  oplot, energy_out, energy_out*0+1., thick=2, color=0, linestyle=2
  stop
  
  e_bins  = get_edges( energy_in, /width )

  totcounts_0 = total(count_flux_0 * e_bins)
  totcounts_100 = total(count_flux_100 * e_bins)
  
  window, 2, xs=window_xsize, ys=window_ysize
  plot, energy_out, count_flux_10, chars=2, thick=3, charth=2, xth=2, yth=2, background=1, $
    /xlog, /ylog, /xsty, title='Count flux', psym=10
END
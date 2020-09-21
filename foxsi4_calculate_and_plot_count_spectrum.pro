PRO foxsi4_calculate_and_plot_count_spectrum, spectrum_structure, energy_edges=energy_edges, window_ind=window_ind, cdte=cdte, cmos=cmos, $
  al_um=al_um, be_um=be_um, pinhole=pinhole, counting_stat=counting_stat, int_time=int_time, cea_let=cea_let, det_thick=det_thick, loweth=loweth, $
  energy_resolution=energy_resolution, energy_bin=energy_bin, $
  high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res, list_counts=list_counts, model=model, $
  plot_title=plot_title, plot_legend=plot_legend, plot_name=plot_name, att_str=att_str, save=save, chars=chars

  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This procedures takes a photon flux structure, apply the response of the FOXSI-4 sounding rocket,
  ;    plot the count spectrum
  ;    overplot the thermal and non-thermal parts of the spectrum
  ;    add a legend to the plot
  ;
  ; :inputs:
  ;   spectrum_structure: structure containing 'energy_kev', 'photon_flux', 'thermal_flux' and 'nonthermal_flux'
  ;
  ; :outputs:
  ;
  ; :keywords:
  ;   energy_edges: energy edges for the energy_kev in the structure
  ;   window_ind: window number to open the window that will contain the plot
  ;   list_counts: list of count spectra produced
  ;   plot_title: plot title
  ;   plot_legend: array of strings containing any legend element to be displayed in the upper left corner of the plot
  ;   plot_name: name of the plot if saved as a png
  ;   save: set to 1 to save a png. Default is 0
  ;   att_str: string containing the attenuator info for plot legend
  ;   model: if set to 1, the counting statistic is applied only to the total count, not to the thermal and nonthermal parts
  ;   
  ;   for other keywords, see foxsi4_flare_response_simulation
  ;
  ; :calls:
  ;   This procedure calls foxsi4_flare_response_simulation
  ;
  ; :example:
  ;
  ; :history:
  ;   2019/08/22, SMusset (UMN), initial release
  ;   2019/10/10, SMusset (UMN), added the keyword model
  ;   2019/10/28, SMusset (UMN), added the pinhole keyword
  ;   2020/09/10, SMusset (UoG), added the energy_resolution keyword
  ;   2020/09/20, SMusset (UoG), added the energy_bin keyword
  ;-

  DEFAULT, window_ind, 1
  DEFAULT, save, 0
  DEFAULT, chars, 2
  DEFAULT, att_str, 'no att'
  DEFAULT, model, 1
  
  list_counts = list()
  
  count = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.PHOTON_FLUX, cdte=cdte, cmos=cmos, $
    al_um=al_um, be_um=be_um, pinhole=pinhole, counting_stat=counting_stat, int_time=int_time, cea_let=cea_let, det_thick=det_thick, loweth=loweth, energy_resolution=energy_resolution, energy_bin=energy_bin, $
    energy_edges=energy_edges, high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res)
  list_counts.add, count
  totcount = total(count.count_Rate)
  
  IF model eq 1 then begin
    counting_statistics = 0
    intg_time = 1
  ENDIF
  countth = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.thermal_FLUX, cdte=cdte, cmos=cmos, $
    al_um=al_um, be_um=be_um, pinhole=pinhole, counting_stat=counting_statistics, int_time=intg_time, cea_let=cea_let, det_thick=det_thick, loweth=loweth, energy_resolution=energy_resolution, energy_bin=energy_bin, $
    energy_edges=energy_edges, high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res)
  list_counts.add, countth
  countnth = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.nonthermal_FLUX, cdte=cdte, cmos=cmos, $
    al_um=al_um, be_um=be_um, pinhole=pinhole, counting_stat=counting_statistics, int_time=intg_time, cea_let=cea_let, det_thick=det_thick, loweth=loweth, energy_resolution=energy_resolution, energy_bin=energy_bin, $
    energy_edges=energy_edges, high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res)
  list_counts.add, countnth

  set_line_color
  window, window_ind, xs=1000, ys=1200
  plot, count.energy_kev, count.count_flux, chars=chars, thick=3, charth=3, xth=2, yth=2, background=1, color=0, $
    /xlog, /ylog, /xsty, title=plot_title, psym=10, xtitle='Energy (keV)', ytitle='Counts/s/keV', yr=[1,1d8]
  oplot, countth.energy_kev, countth.count_flux, thick=3, color=3, linestyle=2
  oplot, countnth.energy_kev, countnth.count_flux, thick=3, color=5, linestyle=2
  al_legend, ['Total flux','Thermal flux','Nonthermal flux'], linestyle=[0,2,2], color=[0,3,5], thick=3, chars=chars, charth=3, linsi=0.4, box=0, /right
  al_legend, [att_str,strtrim(string(round(totcount)),2)+' c/s'], chars=chars, charth=3, box=0, /bottom
  al_legend, plot_legend, chars=chars, box=0, charth=3
  FOR k=0, n_elements(count.count_flux)-1 DO oplot, [count.energy_kev[k],count.energy_kev[k]], count.count_flux[k]+[-0.5,+0.5]*SQRT(count.count_flux[k]), color=0, thick=3

  IF save EQ 1 THEN WRITE_PNG, plot_name, TVRD(/TRUE)

  

END
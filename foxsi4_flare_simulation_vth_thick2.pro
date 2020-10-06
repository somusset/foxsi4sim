PRO foxsi4_flare_simulation_vth_thick2, energy_edges, params, energy_mean=energy_mean, vth=vth, thick2=thick2, plot=plot, chars=chars, window_ind=window_ind
  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function simulates a flare from parameters for vth+thick2 and plot the resulting spectra (thermal and non thermal)
  ;    
  ; :inputs:
  ;   energy_edges: energy array in keV
  ;   params: array containing the parameters for vth+thick2
  ;
  ; :outputs:
  ;
  ; :keywords:
  ;   energy_mean: energy array, mean values
  ;   vth: photon spectrum for the vth component
  ;   thick2: photon spectrum for the thick2 component
  ;   plot: if set, plot the spectra, default is 1
  ;   chars: character size for the plot, default is 3
  ;   window_ind: integer to open a plot window
  ;
  ; :calls:
  ;
  ; :example:
  ;
  ; :history:
  ;   2019/08/22, SMusset (UMN), initial release
  ;   2020/10/06, SMusset (UoG), changed plot display window size for compatibility with other devices
  ;-
  
  screen_dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution)
  window_xsize = fix(0.3*screen_dimensions[0])
  window_ysize = fix(window_xsize/0.8)
  
  DEFAULT, plot, 1
  DEFAULT, chars, 2.2
  DEFAULT, window_ind, 0
  
  energy_mean = get_edges( energy_edges, /mean )

  vth = f_vth(energy_edges, params[0:2])
  thick2 = f_thick2(energy_mean, params[3:-1])

  IF plot EQ 1 THEN BEGIN
    set_line_color
    window, window_ind, xsize=window_xsize, ysize=window_ysize
    plot, energy_mean, vth+thick2, /xlog, /ylog, chars=chars, charth=3, thick=3, xth=2, yth=2, background=1, color=0, xtitle='Energy (keV)', ytitle='Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]'
    oplot, energy_mean, vth, thick=3, color=3, linestyle=5
    oplot, energy_mean, thick2, thick=3, color=5, linestyle=5
    al_legend, ['Thermal spectrum','Thick target spectrum'], box=0, /right, chars=chars, textcol=[3,5], charth=3
  ENDIF


END
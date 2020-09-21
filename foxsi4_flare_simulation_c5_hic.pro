PRO foxsi4_flare_simulation_c5_hic, FP_spectrum, FP2_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, plot=plot, save=save

  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function simulate the spectra from the footpoint, coronal source, and the spatially intergated spectrum
  ;    for the C5 flare data provided by the Hi-C team
  ;
  ; :inputs:
  ;   none
  ;
  ; :outputs:
  ;   FP_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the first footpoint (east ribbon)
  ;   FP2_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the second footpoint (west ribbon)
  ;   CS_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the coronal source
  ;   FULL_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the spatially integrated flux
  ;   energy_edges, FLTARR, edges of the energy bins (the mean energy is in the structure)
  ;
  ; :keywords:
  ;   plot: if set, plot the spectra, default is 1
  ;   save: if set, save the plots, default is 0
  ;
  ; :calls:
  ;    
  ;
  ; :example:
  ;
  ; :history:
  ;   2019/08/29, SMusset (UMN), initial release
  ;   2020/09/20, SMusset (UMN), changed path to typical flare parameters
  ;   
  ; :Note:
  ;   It seems that this is not a C5 flare after all...
  ;   Also note that there might be a problem with closest, since multiple functions exists with this name
  ;-

  DEFAULT, plot, 1
  DEFAULT, save, 0
  low_e_cutoff = 5. ; keV

  chars=2

  ;-------------------------------------------------
  ; Read the flare data
  ;-------------------------------------------------

  mypath = routine_filepath()
  sep = strpos(mypath,'\',/reverse_search)
  IF sep EQ -1 THEN sep=strpos(mypath,'/',/reverse_search)
  path = strmid(mypath, 0, sep)

  file = path+'\flare_data\photonflux_fineEbin.sav'
  restore, file
  
  energy_mean = get_edges(energy, /mean)
  dE = get_edges(energy, /width)
  
  ;-------------------------------------------------
  ; Degrade spatial resolution
  ;-------------------------------------------------

  tronc = xray_flux[0:499,0:499,*]
  new_photonflux = fltarr(125,125,n_elements(energy_mean))

  FOR i=0,124 do begin
    FOR j=0,124 do begin
      FOR k=0, n_elements(energy_mean)-1 DO BEGIN
        new_photonflux[i,j,k] = total(tronc[i*4:i*4+3,j*4:j*4+3,k])
      ENDFOR
    ENDFOR
  ENDFOR

  ;-------------------------------------------------
  ; Add the non-thermal data
  ;-------------------------------------------------

  peak_flux = 5d-6
  ;restore, 'C:\Users\SMusset\Documents\GitHub\foxsi-smex\idl\typical_flares.sav' ; restore variables fgoes, temp, em, gamma, f35
  restore, path+'\typical_flare_scales\typical_flares.sav' ; restore variables fgoes, temp, em, gamma, f35
  
  ;  ind = closest(peak_flux, fgoes) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  ind = closest(fgoes, peak_flux) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  PRINT, 'For a C5 flare, typical photon gamma is ', gamma[ind]
  nontherm = f_1pow( energy_mean, [f35[ind],gamma[ind],35] )
  low_e = where(energy_mean lt low_e_cutoff)
  nontherm[low_e] = 0.

  mask_nth = fltarr(125,125)
  selec = where(new_photonflux[*,*,20] GT 5*mean(new_photonflux[*,*,20]))
  mask_nth[selec] = 1
  i=image(mask_nth)

  nonthflux = fltarr(125,125,n_elements(energy_mean))
  FOR i=0,124 do begin
    FOR j=0,124 do begin
      IF mask_nth[i,j] EQ 1 THEN BEGIN
        nonthflux[I,J,*] = 0.5*nontherm
      ENDIF
    ENDFOR
  ENDFOR

  ;-------------------------------------------------
  ; Read footpoint 1 data, "east ribbon"
  ;-------------------------------------------------

  xx = 53
  yy = 61
  window_ind=0
  
  fp_vth = reform(new_photonflux[xx,yy,*])
  fp_nonth = reform(nonthflux[xx,yy,*])
  IF plot EQ 1 THEN BEGIN
    set_line_color
    window, window_ind, xsize=1200, ysize=1500
    plot, energy_mean, fp_vth+fp_nonth, /xlog, /ylog, chars=chars, charth=3, thick=3, xth=2, yth=2, background=1, color=0, xtitle='Energy (keV)', ytitle='Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]'
    oplot, energy_mean, fp_vth, thick=3, color=3, linestyle=5
    oplot, energy_mean, fp_nonth, thick=3, color=5, linestyle=5
    al_legend, ['Thermal spectrum','Thick target spectrum'], box=0, /right, chars=chars, textcol=[3,5], charth=3

    al_legend, ['C5 flare','Footpoint east'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C5-hi-c_flare_fp1_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_nonth
  fp_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_nonth)

  ;-------------------------------------------------
  ; Read footpoint 2 data, "west ribbon"
  ;-------------------------------------------------

  xx = 74
  yy = 66
  window_ind=1
  
  fp_vth = reform(new_photonflux[xx,yy,*])
  fp_nonth = reform(nonthflux[xx,yy,*])
  IF plot EQ 1 THEN BEGIN
    set_line_color
    window, window_ind, xsize=1200, ysize=1500
    plot, energy_mean, fp_vth+fp_nonth, /xlog, /ylog, chars=chars, charth=3, thick=3, xth=2, yth=2, background=1, color=0, xtitle='Energy (keV)', ytitle='Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]'
    oplot, energy_mean, fp_vth, thick=3, color=3, linestyle=5
    oplot, energy_mean, fp_nonth, thick=3, color=5, linestyle=5
    al_legend, ['Thermal spectrum','Thick target spectrum'], box=0, /right, chars=chars, textcol=[3,5], charth=3
    al_legend, ['C5 flare','Footpoint west'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C5-hi-c_flare_fp2_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_nonth
  fp2_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_nonth)

  ;-------------------------------------------------
  ; Read looptop data
  ;-------------------------------------------------

  xx = 70
  yy = 60
  window_ind=2
  
  fp_vth = reform(new_photonflux[xx,yy,*])
  fp_nonth = reform(nonthflux[xx,yy,*])
  IF plot EQ 1 THEN BEGIN
    set_line_color
    window, window_ind, xsize=1200, ysize=1500
    plot, energy_mean, fp_vth+fp_nonth, /xlog, /ylog, chars=chars, charth=3, thick=3, xth=2, yth=2, background=1, color=0, xtitle='Energy (keV)', ytitle='Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]'
    oplot, energy_mean, fp_vth, thick=3, color=3, linestyle=5
    oplot, energy_mean, fp_nonth, thick=3, color=5, linestyle=5
    al_legend, ['Thermal spectrum','Thick target spectrum'], box=0, /right, chars=chars, textcol=[3,5], charth=3
    al_legend, ['C5 flare','Coronal emission'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C5-hi-c_flare_cs_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_nonth
  cs_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_nonth)

  ;-------------------------------------------------
  ; Read spatially integrated data
  ;-------------------------------------------------

  fp_vth = fltarr(n_elements(energy_mean))
  fp_nonth = fltarr(n_elements(energy_mean))
  FOR k=0, n_elements(energy_mean)-1 DO BEGIN
    fp_vth[k] = total(new_photonflux[*,*,k])
    fp_nonth[k] = total(nonthflux[*,*,k])
  ENDFOR
  IF plot EQ 1 THEN BEGIN
    set_line_color
    window, window_ind, xsize=1200, ysize=1500
    plot, energy_mean, fp_vth+fp_nonth, /xlog, /ylog, chars=chars, charth=3, thick=3, xth=2, yth=2, background=1, color=0, xtitle='Energy (keV)', ytitle='Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]'
    oplot, energy_mean, fp_vth, thick=3, color=3, linestyle=5
    oplot, energy_mean, fp_nonth, thick=3, color=5, linestyle=5
    al_legend, ['Thermal spectrum','Thick target spectrum'], box=0, /right, chars=chars, textcol=[3,5], charth=3
    al_legend, ['C5 flare','Spatially integrated'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C5-hi-c_flare_total_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_nonth
  full_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_nonth)


  energy_edges = energy
END
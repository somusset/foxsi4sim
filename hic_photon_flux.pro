PRO hic_photon_flux, loop_spectrum = loop_spectrum, footpoint_spectrum = footpoint_spectrum, loud=loud, save_plot=save_plot

  
  ; set default values
  
  DEFAULT, loud, 1
  DEFAULT, save_plot, 0
  DEFAULT, low_e_cutoff, 5.

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

  IF loud EQ 1 THEN BEGIN
    print, minmax(em)/1d23 ; this is supposed to be in 1d49 cm-3
    print, minmax(te)/1d6
  ENDIF
  
  mask_nonth_sel = where(em/1d23*1d49 GT 1d44)
  mask_nonth = fltarr(501,501)
  mask_nonth[mask_nonth_sel] = 1
  IF loud EQ 1 THEN BEGIN
    j = image(mask_nonth,title='Mask for nonthermal')
    
    i=image(alog10(em/1d23*1d49), rgb=13,title='Emission Measure', position=[0.20,0.05,0.99,0.9])
    c = colorbar(target=i, orientation=1, position=[0.15,0.05,0.20,0.9], title="log(EM [cm-3])")
    ;ct = contour(mask, /over, c_label_show=0, c_thick=1, color='white')
;    sym = symbol([70,53]*4,[60,61]*4, 'square',/data,sym_siz=1, sym_thick=2)
    j = image(mask)
  ENDIF

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; restore file with previously created photon flux data array, see procedure lookatdemfile.pro
  
  file = path+'\flare_data\photonflux.sav'
  restore, file
  
  energy_mean = get_edges(energy, /mean)
  dE = get_edges(energy, /width)
  
  ; create two images from the data
  
  IF loud EQ 1 THEN BEGIN
    selection1 = where(energy_mean GT 4. AND energy_mean LT 7.)
    selection2 = where(energy_mean GT 10. AND energy_mean LT 20.)
    image1 = fltarr(501,501)
    image2 = fltarr(501,501)
  
    FOR i=0, 500 DO BEGIN
      FOR j=0,500 DO BEGIN
        image1[i,j] = total(xray_flux[i,j,selection1]*de[selection1])
        image2[i,j] = total(xray_flux[i,j,selection2]*de[selection1])
      ENDFOR
    ENDFOR

    i=image(image1, rgb=13, title='Photon flux 4-7 keV')
    i=image(image2, rgb=13, title='Photon flux 10-20 keV')

    corona = [248,248]
    footpt = [216,242]
  
    sophie_linecolors
    window, xsize=1200, ysize=1300
    plot, energy_mean, xray_flux[corona[0],corona[1],*], chars=2, charth=3, thick=3, xth=3, yth=3, /xlog, /ylog, xr=[1,30],/xstyle, background=1, color=0, $
      title='Photon flux',xtitle='Energy (keV)', ytitle='Photon flux'
    oplot, energy_mean, xray_flux[footpt[0],footpt[1],*], thick=3, linestyle=2, color=0
    al_legend, ['Pixel in corona', 'Pixel in footpoint'], box=0, linestyle=[0,2], color=0, chars=2, charth=3, thick=3, linsi=0.5, /bottom
    IF save_plot EQ 1 THEN WRITE_PNG, 'hic_flare_spectra_examples.png', TVRD(/TRUE)
  ENDIF
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; need to bin pixels together to make a more FOXSI-like image
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; keep only 500 pixels
  
  tronc = xray_flux[0:499,0:499,*]
  new_photonflux = fltarr(125,125,n_elements(energy_mean))
  
  FOR i=0,124 do begin
    FOR j=0,124 do begin
      FOR k=0, n_elements(energy_mean)-1 DO BEGIN
        new_photonflux[i,j,k] = total(tronc[i*4:i*4+3,j*4:j*4+3,k])
      ENDFOR
    ENDFOR
  ENDFOR
  
  IF loud EQ 1 THEN BEGIN
    image3 = fltarr(125,125)
    image4 = fltarr(125,125)

    FOR i=0, 124 DO BEGIN
      FOR j=0,124 DO BEGIN
        image3[i,j] = total(new_photonflux[i,j,selection1]*de[selection1])
        image4[i,j] = total(new_photonflux[i,j,selection2]*de[selection1])
      ENDFOR
    ENDFOR
  
    i=image(image3, rgb=13, title='Photon flux 4-7 keV',position=[0.05,0.05,0.9,0.9])
    i=image(image4, rgb=13, title='Photon flux 10-20 keV',position=[0.05,0.05,0.9,0.9])
    i=image(alog(image4), rgb=13, title='Photon flux 10-20 keV',position=[0.05,0.05,0.9,0.9])
  ENDIF
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; adding nonthermal stuff
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  peak_flux = 5d-6
  restore, path+'\typical_flare_scales\typical_flares.sav' ; restore variables fgoes, temp, em, gamma, f35
  
  ;  ind = closest(peak_flux, fgoes) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  ind = closest(fgoes, peak_flux) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  IF loud EQ 1 THEN PRINT, 'For a C5 flare, typical photon gamma is ', gamma[ind]
  nontherm = f_1pow( energy_mean, [f35[ind],gamma[ind],35] )
  low_e = where(energy_mean lt low_e_cutoff)
  nontherm[low_e] = 0.
  
  mask_nth = fltarr(125,125)
  selec = where(new_photonflux[*,*,20] GT 5*mean(new_photonflux[*,*,20]))
  mask_nth[selec] = 1
  IF loud EQ 1 THEN i=image(mask_nth)

  nonthflux = fltarr(125,125,n_elements(energy_mean))
  FOR i=0,124 do begin
    FOR j=0,124 do begin
      IF mask_nth[i,j] EQ 1 THEN BEGIN
        nonthflux[I,J,*] = nontherm
      ENDIF
    ENDFOR
  ENDFOR
  ; more pltos
  
  corona = [70,60]
  footpt = [53,61] ; east fp
  ; west footpoint is 74,66

  ft_th_flux = new_photonflux[footpt[0],footpt[1],*]
  lt_th_flux = new_photonflux[corona[0],corona[1],*]
  nt_flux = 0.2*nontherm
  
  sophie_linecolors
  window, xsize=1200, ysize=1300
  plot, energy_mean, new_photonflux[corona[0],corona[1],*], chars=2, charth=3, thick=3, xth=3, yth=3, /xlog, /ylog, xr=[1,30],/xstyle, background=1, color=0, $
    title='Photon flux',xtitle='Energy (keV)', ytitle='Photon flux'
  oplot, energy_mean, new_photonflux[footpt[0],footpt[1],*], thick=3, linestyle=2, color=0
  al_legend, ['Pixel in corona', 'Pixel in footpoint'], box=0, linestyle=[0,2], color=0, chars=2, charth=3, thick=3, linsi=0.5, /bottom

  ; throw a factor 5 in here because normalization does not seem quite right
  oplot, energy_mean, 0.2*nontherm, thick=3, linestyle=4, color=0
  IF save_plot EQ 1 THEN WRITE_PNG, 'hic_flare_spectra_examples_nonth.png', TVRD(/TRUE)

  loop_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", lt_th_flux+nt_flux, "thermal_flux", lt_th_flux, "nonthermal_flux", nt_flux)
  footpoint_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", ft_th_flux+nt_flux, "thermal_flux", ft_th_flux, "nonthermal_flux", nt_flux)

END
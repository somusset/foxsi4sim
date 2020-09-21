PRO test_demfile, pixel_i=pixel_i, pixel_j=pixel_j

  DEFAULT, pixel_i, 250
  DEFAULT, pixel_j, 230

  ; read data file

  file = 'C:\Users\SMusset\Documents\GitHub\foxsi4\fix_emcube_0.sav'
  restore, file
  
  ; some constants
  
  pixel_size_arcsec = 0.6 ; arcsec
  Dsun = 150d6 * 1d5 ; 150 millions de km en cm
  pixel_size_cm = Dsun*atan(pixel_size_arcsec/3600*!pi/180)
    
  ; make a EM map and T map
  em = fltarr(501,501)
  te = fltarr(501,501)
  mask = fltarr(501,501)
  
  FOR i=0, 500 DO BEGIN
    FOR j=0, 500 DO BEGIN
      em[i,j] = total(reform(emcube[i,j,*]))*(pixel_size_cm^2) ; this is in 1d26 cm-3
      m = max(reform(emcube[i,j,*]),pos)
      if em[i,j] GT 1d16 then mask[i,j] = 1
      te[i,j] = 10^(lgtaxis[pos])
    ENDFOR
  ENDFOR

  print, minmax(em)/1d23 ; this is supposed to be in 1d49 cm-3
  print, minmax(te)/1d6
  
  ; plot the dem distribution for the selected pixel
  
  window, 0
  plot, lgtaxis, emcube[pixel_i, pixel_j, *], chars=2, xtitle='log(T)', ytitle='EM (1d26 cm-5)'
  
  stop
  
  ; calculate X-ray flux only for this pixel, this is only a test !
  
  xray_flux = fltarr(27,299)
  energy = indgen(300)/10.+1
  energy_mean = get_edges(energy, /mean)
  
  ; start at minimum temperature allowed in f_vth
        FOR k=11, 26 DO BEGIN
         ; print, 10^(lgtaxis[k])/11.6d6
          xray_flux[k,*] = f_vth( energy, [emcube[pixel_i,pixel_j,k]*1d26/1d49*(pixel_size_cm^2), (10^(lgtaxis[k]))/11.6d6, 1.])
        ENDFOR

  flux = fltarr(299)
  FOR h=0, n_elements(flux)-1 DO flux[h] = total(reform(xray_flux[*,h]))

  window, 1
  plot, energy_mean, flux, /xlog, /ylog, chars=2, xtitle='Energy (keV)', ytitle='Photon spectrum', thick=3
 ; plot, energy_mean, xray_flux[20,*], /xlog, /ylog, chars=2, xtitle='Energy (keV)', ytitle='Photon spectrum'
  FOR k=11, 26 DO BEGIN
    oplot, energy_mean, xray_flux[k,*]
  ENDFOR


END
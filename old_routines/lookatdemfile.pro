PRO lookatdemfile, em=em, mask=mask, mask_nonth=mask_nonth


DEFAULT, calculate_flux, 0

file = 'C:\Users\SMusset\Documents\GitHub\foxsi4\fix_emcube_0.sav'
restore, file

pixel_size_arcsec = 0.6 ; arcsec
Dsun = 150d6 * 1d5 ; 150 millions de km en cm
pixel_size_cm = Dsun*atan(pixel_size_arcsec/3600*!pi/180)

;print, pixel_size_cm

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

print, minmax(em)/1d23 ; this is supposed to be in 1d49 cm-3
print, minmax(te)/1d6

mask_nonth_sel = where(em/1d23*1d49 GT 1d44)
mask_nonth = fltarr(501,501)
mask_nonth[mask_nonth_sel] = 1
j = image(mask_nonth,title='Mask for nonthermal')

i=image(alog10(em/1d23*1d49), rgb=13,title='Emission Measure', position=[0.20,0.05,0.99,0.9])
c = colorbar(target=i, orientation=1, position=[0.15,0.05,0.20,0.9], title="log(EM [cm-3])")
;ct = contour(mask, /over, c_label_show=0, c_thick=1, color='white')
j = image(mask)
stop
i=image(alog10(te_mean), rgb=13,title='Temperature')
i=image(te, rgb=13,title='Temperature')
stop

IF calculate_flux EQ 1 THEN BEGIN

  
  xray_flux_cube = fltarr(501,501,27,299)
  energy = indgen(300)/10.+1
  
  FOR i=0, 500 DO BEGIN
    print, 'pixel x=',i,' / 500'
    FOR j=0, 500 DO BEGIN
      IF mask[i,j] EQ 1 THEN BEGIN
        FOR k=11, 26 DO BEGIN
         ; print, emcube[i,j,k]/1.d49
         ; print, 10^(lgtaxis[k])/11.6d6
          xray_flux_cube[i,j,k,*] = f_vth( energy, [emcube[i,j,k]*1d26/1d49*(pixel_size_cm^2),10^(lgtaxis[k])/11.6d6,1.])
        ENDFOR
      ENDIF 
    ENDFOR
  ENDFOR
  
  save, mask, xray_flux_cube, energy, filename='photonfluxpertemp_fineEbin.sav'
  stop
ENDIF 
  
  ;restore, 'photonfluxpertemp.sav'
  restore, 'photonfluxpertemp_fineEbin.sav'
  
  xray_flux = fltarr(501,501,n_elements(energy)-1)
  FOR i=0, 500 DO BEGIN
    FOR j=0, 500 DO BEGIN
      FOR k=0,n_elements(energy)-2 DO BEGIN
        xray_flux[i,j,k] = total(reform(xray_flux_cube[i,j,*,k]))
      ENDFOR
    ENDFOR
  ENDFOR

save, mask, xray_flux, energy, filename='photonflux_fineEbin.sav'
stop

END
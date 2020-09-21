PRO my_favorite_flare

  ; choose a certain energy array

  energy = INDGEN(22)+3
  en2 = get_edges( energy, /edges_2 ) ; edges of the energy bins
  en_mean = get_edges( energy, /mean ) ; mean of the energy bins


; PLOT FOXSI-2 effective area (calibration data)

area = get_foxsi_effarea(ener=en_mean)
area0 = get_foxsi_effarea(ener=en_mean, module=0)
area1 = get_foxsi_effarea(ener=en_mean, module=1)
area2 = get_foxsi_effarea(ener=en_mean, module=2)
area3 = get_foxsi_effarea(ener=en_mean, module=3)
area4 = get_foxsi_effarea(ener=en_mean, module=4)
area5 = get_foxsi_effarea(ener=en_mean, module=5)
area6 = get_foxsi_effarea(ener=en_mean, module=6)

sophie_linecolors
colo = [3,5,8,10,12,14,17,19]
window, xs=1200, ys=1000

PLOT, AREA0.ENERGY_KEV, AREA0.EFF_AREA_CM2, /xstyle, yr=[0,25], /yst, background=1, color=0, thick=3, xth=2, yth=2, charth=3, chars=2, xtitle='Energy (keV)', ytitle='Effective area (cm!E2!N)', title='FOXSI-2 Effective areas'
oplot, AREA0.ENERGY_KEV, AREA0.EFF_AREA_CM2, color=colo[0], thick=3
oplot, AREA1.ENERGY_KEV, AREA1.EFF_AREA_CM2, color=colo[1], thick=3
oplot, AREA2.ENERGY_KEV, AREA2.EFF_AREA_CM2, color=colo[2], thick=3
oplot, AREA3.ENERGY_KEV, AREA3.EFF_AREA_CM2, color=colo[3], thick=3
oplot, AREA4.ENERGY_KEV, AREA4.EFF_AREA_CM2, color=colo[4], thick=3
oplot, AREA5.ENERGY_KEV, AREA5.EFF_AREA_CM2, color=colo[5], thick=3
oplot, AREA6.ENERGY_KEV, AREA6.EFF_AREA_CM2, color=colo[6], thick=3
al_legend, 'Module '+strtrim(string(indgen(7)),2), textcol = colo[0:6], box=0, chars=2, charth=3, /right

stop
; sophie used GETENV for compatibility with windows 

; 0: looptop, 1: footpoint 1, 2: footpoint 2

EM = [0.21, 0.014, 0.008] ; x10^49 cm-3
Te = [2.1, 2.5, 2.5] ; keV

norn = [0.46, 0., 0.] ; x10^55 cm-2 sec-1
rate = [0., 0.12, 0.06] ; x10^35 sec^-1
delt = [5.2, 4.4, 4.2]

low_cutoff = 25. ; keV


; calculate spectra

looptop_vth = f_vth(energy, [EM[0], Te[0], 1.])
footpt1_vth = f_vth(energy, [EM[1], Te[1], 1.])
footpt2_vth = f_vth(energy, [EM[2], Te[2], 1.])

looptop_thin = f_thin2(en2, [norn[0], delt[0], 3600., 2., low_cutoff, 3600.])
footpt1_thic = f_thick2(en2, [rate[1], delt[0], 3600., 2., low_cutoff, 3600.])
footpt2_thic = f_thick2(en2, [rate[2], delt[0], 3600., 2., low_cutoff, 3600.])

looptop_tot = looptop_vth + looptop_thin
footpt1_tot = footpt1_vth + footpt1_thic
footpt2_tot = footpt2_vth + footpt2_thic

sophie_linecolors
window, xs=1000, ys=1300
thi=2
plot, en_mean, looptop_tot, /xlog, /ylog, chars=2.5, color=0, background=1, xthi=thi, yth=thi, thick=thi+1, charth=thi+1, psym=10, $
  xtitle="Energy [keV]", ytitle="Photon flux [photon.cm!E-2!N.s!E-1!N.keV!E-1!N)]", /xstyle, yr=[1d-1, 1d6]
oplot, en_mean, footpt1_tot, thick=thi+1, color=0, psym=10
oplot, en_mean, footpt2_tot, thick=thi+1, color=0, psym=10

oplot, en_mean, looptop_vth, thick=thi, color=3
oplot, en_mean, footpt1_vth, thick=thi, color=3
oplot, en_mean, footpt2_vth, thick=thi, color=3
oplot, en_mean, looptop_thin, thick=thi, color=13
oplot, en_mean, footpt1_thic, thick=thi, color=13
oplot, en_mean, footpt2_thic, thick=thi, color=13

al_legend, ['thermal','nonthermal','total'], textcol=[3,13,0], box=0, /right, charth=3, chars=2.5

oplot, AREA2.ENERGY_KEV, AREA2.EFF_AREA_CM2, color=colo[2], thick=2, linestyle=2
al_legend, ['effective area'], thick=2, linestyle=2, color=colo[2], box=0, /bottom, charth=3, chars=2.5, lins=0.5

stop


looptop_rate = looptop_tot*AREA2.EFF_AREA_CM2
footpt1_rate = footpt1_tot*AREA2.EFF_AREA_CM2
footpt2_rate = footpt2_tot*AREA2.EFF_AREA_CM2

looptop_vth_rate = looptop_vth*AREA2.EFF_AREA_CM2
footpt1_vth_rate = footpt1_vth*AREA2.EFF_AREA_CM2
footpt2_vth_rate = footpt2_vth*AREA2.EFF_AREA_CM2


sophie_linecolors
window, xs=1000, ys=1300
thi=2
plot, en_mean, looptop_rate, /xlog, /ylog, chars=2.5, color=0, background=1, xthi=thi, yth=thi, thick=thi+1, charth=thi+1, psym=10, $
  xtitle="Energy [keV]", ytitle="Count flux [counts.s!E-1!N.keV!E-1!N)]", /xstyle, yr=[1d-1, 1d6]
oplot, en_mean, footpt1_rate, thick=thi+1, color=0, psym=10
oplot, en_mean, footpt2_rate, thick=thi+1, color=0, psym=10
oplot, en_mean, looptop_vth_rate, thick=thi, color=3
oplot, en_mean, footpt1_vth_rate, thick=thi, color=3
oplot, en_mean, footpt2_vth_rate, thick=thi, color=3

stop

; try to simulate different flare sizes

add_path, 'C:\Users\SMusset\Documents\RESEARCH\FOXSI\SMEX\'
add_path, 'C:\Users\SMusset\Documents\GitHub\foxsi-smex\idl\',/ex

;restore, 'C:\Users\SMusset\Documents\GitHub\foxsi-smex\idl\typical_flares_corr.sav'
restore, 'C:\Users\SMusset\Documents\GitHub\foxsi-smex\idl\typical_flares.sav'
b5 = 5.e-7
c1 = 1.e-6
c5 = 5.e-6
m1 = 1.e-5

; plot photon fluxes for the 4 typical flares

goes_flux = [b5,c1,c5,m1]
titles = ['B5 flare', 'C1 flare', 'C5 flare', 'M1 flare']
thi=3
!p.multi=[0,2,2]
FOR k=0,3 DO BEGIN
  flux = photon_flux_from_goes(goes_flux[k], energy_in=energy, energy_out=energy_out, low_e_cutoff=low_e_cutoff, nontherm=nontherm, therm=therm , /keep_energy_in)
  plot, energy_out, therm, /xlo, /ylo, xr=[3.,26.], yr=[1.e-1,1.e6], /xsty, charsi=1.5, charth=thi, xtit='Energy [keV]', ytit='Phot s!U-1!N cm!U-2!N keV!U-1!N', tit=titles[k], th=thi, xth=thi, yth=thi, background=1, color=0
  oplot, energy_out, therm, color=3, th=thi
  oplot, energy_out, nontherm, color=13, th=thi
ENDFOR
!p.multi=0

stop

; plot count rates for the 4 typical flares

!p.multi=[0,2,2]
FOR k=0,3 DO BEGIN
  flux = photon_flux_from_goes(goes_flux[k], energy_in=energy, energy_out=energy_out, low_e_cutoff=low_e_cutoff, nontherm=nontherm, therm=therm , /keep_energy_in)
  plot, energy_out, therm*AREA2.EFF_AREA_CM2+nontherm*AREA2.EFF_AREA_CM2, /xlo, /ylo, xr=[3.,26.], yr=[1.e-1,1.e6], /xsty, charsi=1.5, charth=thi, xtit='Energy [keV]', ytit='Counts s!U-1!N keV!U-1!N', tit=titles[k], th=thi, xth=thi, yth=thi, background=1, color=0
  oplot, energy_out, therm*AREA2.EFF_AREA_CM2, color=3, th=thi
  oplot, energy_out, nontherm*AREA2.EFF_AREA_CM2, color=13, th=thi
ENDFOR
!p.multi=0

stop

; plot count rates from more typical flares

fluxes = [5.e-6, 3e-6, 2e-6, 1.e-6, 5.e-7, 4.e-7, 3.e-7]
tit = ['C5','C3','C2','C1','B5','B4','B3']+' flare'
e_bins = en2[1,*]-en2[0,*]
totcounts = dblarr(n_elements(fluxes))
window, xs=3000, ys=800
!p.multi=[0,7,1]
FOR k=0, n_elements(fluxes)-1 DO BEGIN 
  photon_flux = photon_flux_from_goes(fluxes[k], energy_in=energy, energy_out=energy_out, low_e_cutoff=low_e_cutoff, nontherm=nontherm, therm=therm , /keep_energy_in)
  count_flux = photon_flux*AREA2.EFF_AREA_CM2
  counts = count_flux * e_bins[0,*]
  totcounts[k] = total(counts) ; total counts in c/s
  plot, energy_out, count_flux, /xlo, /ylo, xr=[3.,26.], yr=[1.e-1,1.e6], /xsty, charsi=3, charth=thi, xtit='Energy [keV]', ytit='Counts s!U-1!N keV!U-1!N', tit=tit[k], th=thi, xth=thi, yth=thi, background=1, color=0
  al_legend, [string(totcounts[k])+' cts/s'], chars=1.5, textcol=0, box=0, /right, charth=thi
ENDFOR
!p.multi=0

stop

END
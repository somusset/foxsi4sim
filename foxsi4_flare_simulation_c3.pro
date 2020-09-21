PRO foxsi4_flare_simulation_c3, FP_spectrum, FP2_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, plot=plot, save=save

  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function simulate the spectra from the footpoint, coronal source, and the spatially intergated spectrum
  ;    for the C2.6 flare from Simoes et al 2015
  ;    The photon spectra are the outputs in data structures
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
  ;    foxsi4_flare_simulation_vth_thick2
  ;    
  ; :example:
  ;
  ; :history:
  ;   2019/08/22, SMusset (UMN), initial release
  ;-

  DEFAULT, plot, 1
  DEFAULT, save, 0

  chars=3

  ;-------------------------------------------------
  ; Define energy input
  ;-------------------------------------------------

  energy = indgen(5000)*0.01+1

  ;-------------------------------------------------
  ; Read footpoint 1 data, "east ribbon"
  ;-------------------------------------------------

  fp1_param = [0.0096, 10.19/11.6, 1.00, 1.02, 5.7, 33000, 0.00, 10.0, 32000]

  foxsi4_flare_simulation_vth_thick2, energy, fp1_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window=0
  IF plot EQ 1 THEN BEGIN
    al_legend, ['C2.6 flare','Footpoint east'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C26_flare_fp1_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  fp_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

  ;-------------------------------------------------
  ; Read footpoint 2 data, "west ribbon"
  ;-------------------------------------------------

  fp2_param = [0.0099, 10.01/11.6, 1.00, 0.51, 4.9, 33000, 0.00, 10.0, 32000]

  foxsi4_flare_simulation_vth_thick2, energy, fp2_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window=1
  IF plot EQ 1 THEN BEGIN
    al_legend, ['C2.6 flare','Footpoint west'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C26_flare_fp2_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  fp2_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

  ;-------------------------------------------------
  ; Read looptop data
  ;-------------------------------------------------

  lt_param = [0.0060, 11.81/11.6, 1.00, 0.73, 5.2, 33000, 0.00, 10.0, 32000]

  foxsi4_flare_simulation_vth_thick2, energy, lt_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window=2
  IF plot EQ 1 THEN BEGIN
    al_legend, ['C2.6 flare','Coronal source'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C26_flare_lt_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  cs_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)
  
  ;-------------------------------------------------
  ; Read spatially integrated data
  ;-------------------------------------------------
  
  full_param = [0.0133, 11.81/11.6, 1.00, 2.84, 5.6, 33000, 0.00, 10.0, 32000]

  foxsi4_flare_simulation_vth_thick2, energy, full_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window=3
  IF plot EQ 1 THEN BEGIN
    al_legend, ['C2.6 flare','Spatially integrated'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_C26_flare_full_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  full_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

 
  energy_edges = energy
END
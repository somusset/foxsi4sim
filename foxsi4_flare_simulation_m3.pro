PRO foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, plot=plot, save=save

 ;+
 ; :Project:
 ;   FOXSI-4 sounding rocket simulation
 ;
 ; :description:
 ;    This function simulate the spectra from the footpoint, coronal source, and the spatially intergated spectrum
 ;    for the M3.5 flare from Simoes and Kontar 2013 (flare C)
 ;    The photon spectra are the outputs in data structures
 ;
 ; :inputs:
 ;   none
 ;
 ; :outputs:
 ;   FP_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the footpoints
 ;   CS_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the coronal source
 ;   FULL_spectrum, str, data structure containing the spectrum of the photon flux in photon/(cm2 s keV) for the spatially integrated flux
 ;   energy_edges, FLTARR, edges of the energy bins (the mean energy is in the structure)
 ;
 ; :keywords:
 ;   plot: if set, plot the spectra, default is 1
 ;   save: if set, save the plots, default is 0
 ;
 ; :calls:
 ;   This function reads the fit parameters in the folder 'SK2013.20110224'
 ;   foxsi4_flare_simulation_vth_thick2
 ;   
 ; :example:
 ;
 ; :history:
 ;   2019/08/22, SMusset (UMN), initial release
 ;   2020/09/20, SMusset (UoG), changed path to data
 ;-

 DEFAULT, plot, 1
 DEFAULT, save, 0
 
 mypath = routine_filepath()
 sep = strpos(mypath,'\',/reverse_search)
 IF sep EQ -1 THEN sep=strpos(mypath,'/',/reverse_search)
 path = strmid(mypath, 0, sep)
 datadir = path+'\flare_data\SK2013.20110224\'

 chars=3
 window_ind = 0

 ;-------------------------------------------------
 ; Define energy input
 ;-------------------------------------------------
 
 energy = indgen(5000)*0.01+1
 energy_mean = get_edges( energy, /mean )
 
 ;-------------------------------------------------
 ; Read footpoint data
 ;-------------------------------------------------
 
 fp_res = spex_read_fit_results(datadir+'ospex_results_FP.fits')
 fp_param = fp_res.SPEX_SUMM_PARAMS
 
  foxsi4_flare_simulation_vth_thick2, energy, fp_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window_ind=0
  IF plot EQ 1 THEN BEGIN
    al_legend, ['M3.5 flare','Footpoints'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_m3-5_flare_fp_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  fp_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

 ;-------------------------------------------------
 ; Read looptop data
 ;-------------------------------------------------

 lt_res = spex_read_fit_results(datadir+'ospex_results_LT.fits')
 lt_param = lt_res.SPEX_SUMM_PARAMS

 foxsi4_flare_simulation_vth_thick2, energy, lt_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window_ind=1
  IF plot EQ 1 THEN BEGIN
    al_legend, ['M3.5 flare','Looptop'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_m3-5_flare_lt_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  CS_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

 ;-------------------------------------------------
 ; Read spatially integrated data
 ;-------------------------------------------------

 Full_res = spex_read_fit_results(datadir+'ospex_results_FULL.fits')
 full_param = Full_res.SPEX_SUMM_PARAMS

 foxsi4_flare_simulation_vth_thick2, energy, full_param, energy_mean=energy_mean, vth=fp_vth, thick2=fp_thick, plot=plot, window_ind=2
  IF plot EQ 1 THEN BEGIN
    al_legend, ['M3.5 flare','Spatially integrated'], box=0, chars=chars, charth=3
    IF save EQ 1 THEN  WRITE_PNG, 'foxsi4_m3-5_flare_full_photon_spectrum.png', TVRD(/TRUE)
  ENDIF
  fp_total = fp_vth + fp_thick
  FULL_spectrum = create_struct("energy_keV", energy_mean, "photon_flux", fp_total, "thermal_flux", fp_vth, "nonthermal_flux", fp_thick)

 energy_edges = energy
END
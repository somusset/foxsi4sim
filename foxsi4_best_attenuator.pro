FUNCTION foxsi4_best_attenuator, photon_flux_str, energy_in, cdte=cdte, cmos=cmos, high_res_j_optic=high_res_j_optic, $
  msfc_high_res=msfc_high_res, al=al, be=be, max_um=max_um, totcount_limit=totcount_limit, error=error, loud=loud, $
  cea_let=cea_let, det_thick=det_thick, loweth=loweth
  
  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the attenuator thickness required to get the count flux just below a threshold.
  ;    This is produced e.g. by the foxsi4_flare_simulation_from_goesclass function.
  ;    This works for an Al attenuator (default) or Be attenuator.
  ;    This is done using dichotomy.
  ;
  ; :inputs:
  ;   photon_flux_str, structure containing a photon flux with tags: energy_kev and PHOTON_FLUX
  ;
  ; :outputs:
  ;   The function returns the ideal thickness of the attenuator for this photon flux in microns
  ;
  ; :keywords:
  ;   cdte: set to 1 to use CdTe detector
  ;   cmos: set to 1 to use CMOS detector
  ;   high_res_j_optic: set to 1 to use high resolution optics from Nagoya
  ;   msfc_high_res: set to 1 to use high resolution optics from Marshall
  ;   al: default is 1. Set to one to calculate thickness of Al attenuator
  ;   be: default is 0. Set to one to calculate thickness of Be attenuator
  ;   cea_let: set to 1 to use CEA low energy threshold for CdTe
  ;   det_thick: detector thickness
  ;   loweth: low energy threshold
  ;   max_um: maximum thickness of attenuator to consider in microns
  ;   totcount_limit: total count limit to consider for the detector
  ;   error: accepted difference on the count rate (as percentage of the maximum count rate), used to stop optimisation.
  ;   loud: set to 1 to get messages during the process. default is 1.
  ;
  ; :calls:
  ;   foxsi4_flare_response_simulation
  ;   
  ; :example:
  ;   energy_in = INDGEN(23)+3
  ;   phflux = foxsi4_flare_simulation_from_goesclass(goesflux, energy_in=energy_in, energy_out=energy_out)
  ;   bestatt = foxsi4_best_attenuator(phflux, energy_in, cdte=1, al=1)
  ;
  ; :history:
  ;   2020/09/16, SMusset (UMN), initial documentation
  ;   
  ; :to be done:
  ;   the input energy_in should disappear: it is confusing since the energy is already provided in the photon flux structure,
  ;   and potentially this is doing something funny in the code.
  ;   However it should be tested to make sure the code does not break when removing this input.
  ;-
  
  DEFAULT, al, 1
  DEFAULT, be, 0
  DEFAULT, cmos, 0
  DEFAULT, cdte, 0
  DEFAULT, error, 0.005 ; change from 0.05 to 0.005 on Aug 21 2019 - Sophie
  DEFAULT, loud, 1

  IF cdte EQ 1 THEN DEFAULT, totcount_limit, 5000
  IF cmos EQ 1 THEN DEFAULT, totcount_limit, 800
  
  IF be EQ 1 THEN AL=0
  IF al EQ 1 THEN default, max_um, 1000.
  IF be EQ 1 THEN default, max_um, 50000.
  
  ; test if the maximum attenuation is enough
  IF AL eq 1 THEN AL_UM = MAX_UM ELSE al_um = 0
  IF BE EQ 1 THEN BE_UM = MAX_UM ELSE be_um = 0
  count = foxsi4_flare_response_simulation(photon_flux_str.energy_kev, photon_flux_str.PHOTON_FLUX, cdte=cdte, cmos=cmos, high_res_j_optic=high_res_j_optic, $
    msfc_high_res=msfc_high_res, energy_edges=energy_in, al_um=al_um, be_um=be_um, cea_let=cea_let, det_thick=det_thick, loud=loud, loweth=loweth)
  totcount = total(count.count_Rate)
  IF totcount GT totcount_limit THEN BEGIN
    print, 'biggest attenuator is not enough'
    if al eq 1 THEN print, 'Al'
    if be eq 1 THEN print, 'be'
    print, string(max_um), ' microns thick'
    RETURN, -1
  ENDIF ELSE BEGIN
    ;initialisation of mini and maxi
    mini = 0.
    maxi = max_um
    dif = maxi-mini
    WHILE dif GT 1. AND (totcount GT (1+error)*totcount_limit OR totcount LT (1-error)*totcount_limit) DO BEGIN
      value = mean([mini,maxi])
      IF al EQ 1 THEN AL_um = value
      IF be EQ 1 THEN be_um = value
      count = foxsi4_flare_response_simulation(photon_flux_str.energy_kev, photon_flux_str.PHOTON_FLUX, cdte=cdte, cmos=cmos, high_res_j_optic=high_res_j_optic, $
        msfc_high_res=msfc_high_res, energy_edges=energy_in, al_um=al_um, be_um=be_um, cea_let=cea_let, det_thick=det_thick, loud=loud, loweth=loweth)
      totcount = total(count.count_Rate)
      IF totcount GT (1+error)*totcount_limit THEN mini = value
      IF totcount LT (1-error)*totcount_limit THEN maxi = value
      dif = maxi-mini
      IF dif LE 1. THEN PRINT, 'attenuator thickness iteration stopped because difference of attenuation is lower than 1 microns'
    ENDWHILE
    print, 'while loop stopped for thickness = ', value, ' um'
    if al eq 1 THEN print, 'Al'
    if be eq 1 THEN print, 'be'
    print, 'total count at the end if ', totcount
    print, 'limit in total count was ', totcount_limit
    RETURN, value
  ENDELSE
    
END
PRO foxsi4_real_flare_simulation, flare_class, save=save, flux=flux, footpoint=footpoint, corona=corona
  
  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This procedure produces simulation of the FOXSI sounding rocket observations of a few real flares
  ;    Flare 1 is the M3.5 flare from Simoes and Kontar 2013
  ;    Flare 2 is the C2.6 flare from Simoes et al 2015
  ;
  ; :inputs:
  ;   flare_class: string containing the approximate flare class of the event we want to look at
  ;
  ; :outputs:
  ;
  ; :keywords:
  ;   save: set to 1 to save a png. Default is 0
  ;   flux: the count flux obtained (default is integrated flux) - the flux returned is the one with the best Al attenuator
  ;   footpoint: set this keyword to return the footpoint flux instead
  ;   corona: set this keyword to return the corona flux instead
  ;   
  ; :calls:
  ;   foxsi4_flare_simulation_m3
  ;   foxsi4_flare_simulation_c3
  ;
  ; :example:
  ;   foxsi4_real_flare_simulation, 'M3'
  ;
  ; :history:
  ;   2019/08/22, SMusset (UMN), initial release
  ;   2019/10/07, SMusset (UMN), added keywords flux, footpoint, corona
  ;-
  
  DEFAULT, save, 0
  DEFAULT, footpoint, 0 ; set to 1 to return the footpoint flux in the keyword flux
  DEFAULT, corona, 0 ; set to 1 to return the coronal flux in the keyword flux
  
  chars=2.

  flare_number = 0
  
  CASE flare_class OF
    'M3': flare_number = 1
    'M3.5': flare_number = 1
    'M4': flare_number = 1
    'C2': flare_number = 2
    'C3': flare_number = 2
    'C2.6': flare_number = 2
    'C5':flare_number = 3
    ELSE: flare_number = 0
  ENDCASE

  IF flare_number EQ 0 THEN BEGIN
    print, 'This flare option is not available'
  ENDIF ELSE BEGIN
    
    ;=========================================================
    ; simulate the photon spectra
    ;=========================================================
    
    IF flare_number EQ 1 THEN BEGIN
      foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
      goesclass = 'm35'
      goesclass_tit = 'M3.5'

    ENDIF
    IF flare_number EQ 2 THEN BEGIN
      foxsi4_flare_simulation_c3, FP_spectrum, FP2_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
      goesclass = 'c26'
      goesclass_tit = 'C2.6'
    ENDIF
    IF flare_number EQ 3 THEN BEGIN
      foxsi4_flare_simulation_c5_hic, FP_spectrum, FP2_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save
      goesclass = 'c5'
      goesclass_tit = 'C5'
    ENDIF
    
    ;=========================================================
    ; simulate the FOXSI observation
    ;=========================================================

    ; INTEGRATED
    ;-----------

    foxsi4_calculate_and_plot_count_spectrum, full_spectrum, cdte=1, energy_edges=energy_edges, window_ind=1, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_module6.png'
      
    ; find best al attenuator
    bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, loud=0)
    al_um = round(bestatt)
    al_attstr = strtrim(string(al_um),2)
    foxsi4_calculate_and_plot_count_spectrum, full_spectrum, cdte=1, al_um=al_um, energy_edges=energy_edges, window_ind=2, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_module6_Al-'+al_attstr+'um.png', att_str = 'Al '+al_attstr+' um'

    flux = full_spectrum

    ; find best be attenuator
    bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, be=1, loud=0)
    be_um = round(bestatt)
    be_attstr = strtrim(string(be_um),2)
    foxsi4_calculate_and_plot_count_spectrum, full_spectrum, cdte=1, be_um=be_um, energy_edges=energy_edges, window_ind=3, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Integrated spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_integrated_count_flux_cdte_module6_Be-'+be_attstr+'um.png', att_str = 'Be '+be_attstr+' um'

    ; FOOTPOINTS
    ;-----------

    foxsi4_calculate_and_plot_count_spectrum, FP_spectrum, cdte=1, energy_edges=energy_edges, window_ind=4, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_footpoint_count_flux_cdte_module6.png'
    foxsi4_calculate_and_plot_count_spectrum, FP_spectrum, cdte=1, al_um=al_um, energy_edges=energy_edges, window_ind=5, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_footpoint_count_flux_cdte_module6_Al-'+al_attstr+'um.png', att_str = 'Al '+al_attstr+' um'
    if footpoint EQ 1 THEN flux = FP_spectrum
    foxsi4_calculate_and_plot_count_spectrum, FP_spectrum, cdte=1, be_um=be_um, energy_edges=energy_edges, window_ind=6, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_footpoint_count_flux_cdte_module6_Be-'+be_attstr+'um.png', att_str = 'Be '+be_attstr+' um'

    IF flare_number EQ 2 OR flare_number EQ 3 THEN BEGIN
      foxsi4_calculate_and_plot_count_spectrum, FP2_spectrum, cdte=1, energy_edges=energy_edges, window_ind=10, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint west spectrum'], chars=chars, $
        plot_name = 'foxsi4_'+goesclass+'_footpoint2_count_flux_cdte_module6.png'
      foxsi4_calculate_and_plot_count_spectrum, FP2_spectrum, cdte=1, al_um=al_um, energy_edges=energy_edges, window_ind=11, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint west spectrum'], chars=chars, $
        plot_name = 'foxsi4_'+goesclass+'_footpoint2_count_flux_cdte_module6_Al-'+al_attstr+'um.png', att_str = 'Al '+al_attstr+' um'
      foxsi4_calculate_and_plot_count_spectrum, FP2_spectrum, cdte=1, be_um=be_um, energy_edges=energy_edges, window_ind=12, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Footpoint west spectrum'], chars=chars, $
        plot_name = 'foxsi4_'+goesclass+'_footpoint2_count_flux_cdte_module6_Be-'+be_attstr+'um.png', att_str = 'Be '+be_attstr+' um'
    ENDIF

    ; LOOPTOP
    ;-----------

    foxsi4_calculate_and_plot_count_spectrum, CS_spectrum, cdte=1, energy_edges=energy_edges, window_ind=7, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Looptop spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_looptop_count_flux_cdte_module6.png'
    foxsi4_calculate_and_plot_count_spectrum, CS_spectrum, cdte=1, al_um=al_um, energy_edges=energy_edges, window_ind=8, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Looptop spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_looptop_count_flux_cdte_module6_Al-'+al_attstr+'um.png', att_str = 'Al '+al_attstr+' um'
    if corona EQ 1 THEN flux = FP_spectrum
    foxsi4_calculate_and_plot_count_spectrum, CS_spectrum, cdte=1, be_um=be_um, energy_edges=energy_edges, window_ind=9, plot_title='Count flux CdTe + module 6', save=save, plot_legend= [goesclass_tit, 'Looptop spectrum'], chars=chars, $
      plot_name = 'foxsi4_'+goesclass+'_looptop_count_flux_cdte_module6_Be-'+be_attstr+'um.png', att_str = 'Be '+be_attstr+' um'
   
    
  ENDELSE


END
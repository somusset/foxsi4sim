FUNCTION foxsi4_flare_simulation_from_goesclass, peak_flux, energy_in=energy_in, energy_out=energy_out, $
  low_e_cutoff=low_e_cutoff, nontherm=nontherm, therm=therm, plot=plot

  ;+
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;   
  ; :description:
  ;    This function returns a structure containing the energies (keV), the photon flux spectrum, the thermal and the nonthermal flux spectra
  ;    for a given GOES flux, using flare parameters saved in typical_flares.sav
  ;    seen at Earth in units of photon/(cm2 s keV)
  ;
  ; :inputs:
  ;   peak_flux, float, the goes flux in W m^-2
  ;
  ; :outputs:
  ;   photon_flux, fltarr, spectrum of the photon flux in photon/(cm2 s keV)
  ;
  ; :keywords:
  ;   energy_in, fltarr, energy array to be taken
  ;   energy_out. fltarr, energy array as output
  ;   low_e_cutoff, fltarr, low energy cutoff for nonthermal spectrum in keV, default is 6 keV
  ;   nontherm, fltarr, non thermal spectrum retourned
  ;   therm, fltarr, thermal spectrum retourned
  ;   plottest, set to 1 to plot the components for visual verification. default should be 0.
  ;   
  ; :calls:
  ;   This function reads the typical_flare.sav file that is only on Sophie's laptop currently
  ;     
  ; :example:
  ; 
  ; :history:
  ;   2019/07/22, SMusset (UMN), initial release
  ;   2019/08/19, SMusset (UMN), change call to closest - need: array, then value
  ;   2020/10/06, SMusset (UoG), changed path access to be compatible with Unix and Mac
  ;   
  ; :note:
  ;   they are several function 'closest' in ssw - e.g. in gx simulator... and in the foxsi soft. Call to closest here may not work on other computers
  ;   it could be useful to create a foxsi_closest to avoid confusion...
  ;-
  
  DEFAULT, low_e_cutoff, 6. ; keV
  DEFAULT, plot, 0
  DEFAULT, energy_in, INDGEN(23)+3
  
  ; calculate mean values in energy array
  en  = get_edges( energy_in, /mean )

  ; read the typical flare data  
  ;restore, 'C:\Users\SMusset\Documents\GitHub\foxsi-smex\idl\typical_flares.sav' ; restore variables fgoes, temp, em, gamma, f35
  mypath = routine_filepath()
  os=!VERSION.OS_FAMILY
  IF os EQ 'Windows' THEN sep_char='\' ELSE sep_char='/'
  sep = strpos(mypath,sep_char,/reverse_search)
  path = strmid(mypath, 0, sep)
  restore, path+sep_char+'typical_flare_scales'+sep_char+'typical_flares.sav' ; restore variables fgoes, temp, em, gamma, f35
  ; this file was created for the FOXSI SMEX analysis
;  ind = closest(peak_flux, fgoes) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  ind = closest(fgoes, peak_flux) ;  index in the fgoes tab that correspond to the values the closest to goes_flux
  
  ; calculate components
  nontherm = f_1pow( en, [f35[ind],gamma[ind],35] )
  low_e = where(en lt low_e_cutoff)
  nontherm[low_e] = 0.
  therm = f_vth( energy_in, [em[ind]/1.d49,temp[ind]/11.6,1.] ) ; why use en2 and not en???
  
  ; if needed, plot
  IF plot EQ 1 THEN BEGIN
    window,0
    plot, en, nontherm, /xlog, /ylog, xr=[1,150], /xsty, chars=2, thi=2, charthi=2, xthi=2, ythi=2
    set_line_color
    oplot, en2, nontherm2, color=3, th=2
    oplot, en, nontherm2, color=4, linestyle=2, th=2
    al_legend, ['mean energy and associated nonth', 'energy edges and associated nontherm', 'mean energy and nonth calculated with edge energy'], $
      linestyle=[0,0,2], color=[1,3,4], box=0, right_legend=1, th=2, charth=2, chars=2, bottom_legend=1

    window,1
    plot, en, therm, /xlog, /ylog, xr=[1,150], /xsty, chars=2, thi=2, charthi=2, xthi=2, ythi=2
    set_line_color
    oplot, en2, therm2, color=3, th=2, psym=10
    oplot, en, therm2, color=4, linestyle=2, th=2
    al_legend, ['mean energy and associated vth', 'energy edges and associated vth', 'mean energy and vth calculated with edge energy'], $
      linestyle=[0,0,2], color=[1,3,4], box=0, right_legend=1, th=2, charth=2, chars=2, bottom_legend=1
  ENDIF

  ; calculate the flux and return the energy array used
  photon_flux = therm + nontherm
  energy_out = en

  res = create_struct("energy_keV", energy_out, "photon_flux", photon_flux, "thermal_flux", therm, "nonthermal_flux", nontherm)
  RETURN, res
END

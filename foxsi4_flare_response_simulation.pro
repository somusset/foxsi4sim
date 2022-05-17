FUNCTION foxsi4_flare_response_simulation, energy_arr, photon_flux, shells=shells, al_um=al_um, be_um=be_um, pinhole=pinhole, $
  cmos=cmos, cdte=cdte, high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res, no_det=no_det, energy_resolution=energy_resolution, $
  energy_bin=energy_bin, cea_let=cea_let, det_thick=det_thick, loweth=loweth, plot=plot, loud=loud, $
  energy_edges=energy_edges, counting_stat=counting_stat, int_time=int_time
  
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This procedure takes a photon flux and its corresponding the energy array and calculate the count flux for FOXSI-4 for
  ;    different possibilities in optic module, detector and attenuator combination. This is done with the following steps:
  ;    - calculation of the effective area
  ;    - gaussian convolution of the count flux with energy resolution of the detector
  ;    - energy binning
  ;    - addition of Poisson noise if needed
  ;    - error estimation on the spectrum
  ;    - plot result if needed
  ;
  ; :inputs:
  ;   energy_arr: array of energies (mean energy of energy bins)
  ;   photon_flux: photon flux in photons/sec/cm2/keV
  ;
  ; :outputs:
  ;   The function returns a structure with the energy array, the photon flux in photons/sec/keV, 
  ;   the count flux in counts/sec/keV, the count rate in counts/sec, the error on the count flux 
  ;   and the error on the count rate
  ;
  ; :keywords:
  ;   shells: number of shells in the optic module. Default is 10, other accepted value is 7
  ;   al_um: Al attenuator thickness in microns, default is 0.
  ;   be_um: Be attenuator thickness in microns, default is 0.
  ;   pinhole: Pinhole attenuator - take attenuator factor provided by Dan
  ;   cmos: if this keyword is set, then efficiency of the cmos detector is considered
  ;   cdte: if this keyword is set, then efficiency of a cdte detector is considered
  ;   high_res_j_optic: set to 1 to use high resolution optics from Nagoya
  ;   msfc_high_res: set tp 1 to use high resolution optics from Marshall
  ;   det_thick: thickness of detector. Default is 500 microns for HXR detectors, 10 microns for CMOS
  ;   cea_let: if set, use CEA low energy threshold of 2 keV
  ;   loweth: low energy threshold used to not plot the low energy data for CdTe in keV, default is 3.
  ;   no_det: if set, do not take into account detector efficiency in the calculation of the effective area
  ;   energy_resolution: single number (no energy dependence) - energy resolution of the detector in keV
  ;   energy_bin: single number - energy bin size in keV for the resulting spectrum
  ;   plot: if set, plot the photon and count spectra side to side. Default is 0.
  ;   loud: if set, print info on the simulation. Default is 1.
  ;   energy_edges: by default, edges of the input energy array
  ;   counting_stat: if set, add poisson counting statistic to the signal
  ;   int_time: integration time for the poisson counting statistic. The final product is still a count flux (per second)
  ;   errors: array of uncertainties calculated with poisson statistics
  ;
  ; :call:
  ;   foxsi4_effective_area
  ;
  ; :example:
  ;
  ; :history:
  ;   2019/07/22, SMusset (UMN), initial release
  ;   2019/08/06, SMusset (UMN), added counting_stat and errors
  ;   2019/08/19, SMusset (UMN), added the keyword 'cea_let' for CEA low energy threshold (2 keV)
  ;                              and 'det_thick' keyword
  ;                              and 'loud' keyword
  ;   2019/09/10, SMusset (UMN), added no_det keyword, to be called in foxsi4_effective_area.pro
  ;   2019/10/07, SMusset (UMN), change energy resolution for CMOS
  ;   2019/10/10, SMusset (UMN), added int_Time for counting statistics calculation
  ;   2019/10/27, SMusset (UMN), added Gaussian smooting of the photon spectra to account for detector energy resolution
  ;   2019/10/28, SMusset (UMN), added option for pinhole attenuator
  ;   2020/09/10, SMusset (UoG), added keyword to change energy resolution
  ;   2020/09/16, SMusset (UoG), added keyword to change energy binning + updated documentation
  ;   2022/05/11, Y.Zhang (UMN), switch order to calculate Possion noise after energy binning; 
  ;                              minor changes of the output energy bin edge locations for CdTe;
  ;                              minor changes in the Possion noise part to avoid getting the exact same values from the random
  ;                              number generator (this only happens occasionally, unknown reason, maybe it's an IDL bug?);
  ;                              small adjustments to plots
  ;   
  ; :to be done:
  ;   
  ;-

  DEFAULT, al_um, 0
  DEFAULT, be_um, 0
  DEFAULT, pinhole, 0
  DEFAULT, plot, 0
  DEFAULT, cdte, 0
  DEFAULT, cmos, 0
  DEFAULT, shells, 10
  DEFAULT, loweth, 3. ; keV ; low energy threshold used to not plot the low energy data for CdTe
  DEFAULT, counting_stat, 0 
  IF CMOS EQ 1 THEN DEFAULT, det_thick, 10. ELSE DEFAULT, det_thick, 500. ; microns
  IF CMOS EQ 1 THEN DEFAULT, energy_resolution, 0.2 ELSE DEFAULT, energy_resolution, 0.8
  IF CMOS EQ 1 THEN DEFAULT, energy_bin, 0.2 ELSE DEFAULT, energy_bin, 0.8
  DEFAULT, cea_let, 0
  DEFAULT, loud, 1
  DEFAULT, no_det, 0
  DEFAULT, int_time, 1.
  
  ; make sure this is a float
  energy_resolution = 1e*energy_resolution
  
  en0 = get_edges(energy_arr, /mean)
  width_e = get_edges(energy_arr, /width)
  val0 = en0[0] - 2*abs(en0[0] - energy_arr[0])
  val1 = en0[-1] + 2*abs(en0[-1] - energy_arr[-1])
  en1 = [val0, en0, val1]
  DEFAULT, energy_edges, en1

  ;----------------------------------------------------------------------------------------------
  ; get effective area (optics+detector efficiency+blanket and shutter)
  ;----------------------------------------------------------------------------------------------
  area = foxsi4_effective_area(energy_arr, shells=shells, al_um=al_um, be_um=be_um, cmos=cmos, pinhole=pinhole, cdte=cdte,  high_res_j_optic=high_res_j_optic, msfc_high_res=msfc_high_res, no_det=no_det, plot=plot, loud=loud, det_thick=det_thick, cea_let=cea_let)
  count_flux = photon_flux*area.eff_area_cm2 
  
  ;----------------------------------------------------------------------------------------------
  ; convolution of the count flux with a gaussian to take into account the spectral resolution
  ;----------------------------------------------------------------------------------------------
  input_flux = count_flux
  sigma = energy_resolution/mean(width_e)/(2.*sqrt(2*alog(2)))
  count_flux = GAUSS_SMOOTH(input_flux, sigma, kernel=kernel, /edge_truncate)
  
  ;----------------------------------------------------------------------------------------------
  ; I am not sure about this next part:
  ; This is some kind of binning, but also takes into account detector low energy threshold
  ;----------------------------------------------------------------------------------------------
  IF CMOS NE 1 THEN BEGIN
    print, 'restricting counts above ', loweth, ' keV'
    sel = where(energy_arr GE loweth)
    photon_flux_sel = photon_flux[sel]
    count_flux_sel = count_flux[sel]
    energy_sel = energy_arr[sel]
    bin_width_in = mean(get_edges(energy_sel,/width))
    en_limits = minmax(energy_sel)
    energy_edges_out = indgen((en_limits[1]-en_limits[0])/energy_bin)*energy_bin+en_limits[0]-0.5*bin_width_in 
    energy_out = get_edges(energy_edges_out,/mean)
    photon_flux_out = interpol(photon_flux_sel, energy_sel, energy_out)
    count_flux_out = interpol(count_flux_sel, energy_sel, energy_out)
  ENDIF ELSE BEGIN
    en_limits = minmax(energy_arr)
    energy_edges_out = indgen((en_limits[1]-en_limits[0])/energy_bin)*energy_bin+en_limits[0] 
    energy_out = get_edges(energy_edges_out,/mean)
    photon_flux_out = interpol(photon_flux, energy_arr, energy_out)
    count_flux_out = interpol(count_flux, energy_arr, energy_out)
  ENDELSE

  ;----------------------------------------------------------------------------------------------
  ; add Poisson noise
  ;----------------------------------------------------------------------------------------------
  IF counting_stat EQ 1 THEN BEGIN
    new_flux = count_flux*int_time
    FOR k=0, n_elements(count_flux_out)-1 DO BEGIN
      IF count_flux_out[k] GT 0 THEN Begin
        new_flux[k] = randomu(seed, 1, poisson=count_flux_out[k]*int_time,/double)
        seed = !NULL    ; This line was added to prevent the issue that Randomu occasionally gives the exact same outputs
                        ; for some runs. In principle, it should give different values each time (and it does so most of 
                        ; the time), but when running simulations repeatedly, sometimes it repeats the values of last
                        ; run. Adding this line seems help; however, this issue may/may not be a universal one regarding
                        ; different IDL versions and operating systems, and the solution may/may not be applicable to all.
      ENDIF ELSE  new_flux[k] = count_flux_out[k]*int_time
    ENDFOR
    count_flux = new_flux/int_time
  ENDIF

  ;----------------------------------------------------------------------------------------------
  ; calculation of errors on the count flux and count rate
  ;----------------------------------------------------------------------------------------------
  error_count_flux = count_flux_out
  FOR k=0, n_elements(count_flux_out)-1 DO BEGIN
    IF count_flux_out[k] GT 0 THEN error_count_flux[k] = stddev(randomu(seed,100,poisson=count_flux_out[k])) ELSE error_count_flux[k] = count_flux_out[k]
  ENDFOR
  
  ebin = get_edges(energy_edges_out, /width)
  ; calculation of count rate
  count_rate = count_flux_out * ebin
  ; calculation of errors on the count rate
  error_count_rate = error_count_flux * ebin

  ;----------------------------------------------------------------------------------------------
  ; plot if needed
  ;---------------------------------------------------------------------------------------------- 
  IF plot EQ 1 THEN BEGIN
    th=3
    window,1
    set_line_color
    !p.multi = [0,2,1]
    plot, energy_out, photon_flux_out, /xlog, /ylog, chars=2, thick=th, xth=th, yth=th, charth=th, title='Photon flux', background=1, color=0    
    plot, energy_out, count_flux_out, /xlog, /ylog, chars=2, thick=th, xth=th, yth=th, charth=th, title='Count flux', background=1, color=0    
    !p.multi = 0
  ENDIF
  
  ;----------------------------------------------------------------------------------------------
  ; create structure to be returned
  ;----------------------------------------------------------------------------------------------
  res = create_struct("energy_keV", energy_out, "photon_flux", photon_flux_out, "count_flux", count_flux_out, "count_rate", count_rate,$
    "error_count_flux", error_count_flux, "error_count_rate", error_count_rate)
  RETURN, res
  
END 

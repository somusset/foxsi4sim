FUNCTION foxsi4_find_optimal_attenuator, energy_edges, photon_flux, area_arcsec=area_arcsec, cmos=cmos
  
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the optimum Al and Be thickness for the detector
  ;    For the CMOS sensor, this is optimized to have less than 5 photons/sec/pixel
  ;    For the CdTe sensor, or Si sensor, this is TBD
  ;    
  ;    To find the optimal attenuation, we start with a thickness of 10 microns and increase the thickness of 10 percent
  ;    at each iteration, until flux is sufficiently attenuated or thickness exceeds 10 mm.
  ;
  ; :inputs:
  ;    energy_edges: an array of energies such as [3,4,5,6,...]
  ;    photon_flux: the corresponding photon flux
  ;    
  ; :outputs:
  ;   The function returns an array of two values containing the Al and Be attenuator thickness required for the given photon flux
  ;
  ; :keywords:
  ;   area_arcsec: area of X-ray emission source in arcsec, default is 100
  ;   cmos: set to 1 to do this analysis for the cmos sensor, default is 1
  ;   
  ; :call:
  ;   foxsi4_effective_area
  ;
  ; :example:
  ;
  ; :history:
  ;   2019/07/23, SMusset (UMN), initial release
  ;
  ; :to be done:
  ;   Add similar analysis for HXR detectors
  ;   
  ; :Remark:
  ;   This function is not currently used in the analysis / flare simulation for FOXSI-4, but it contains useful information
  ;   so I keep it
  ;-
  
  DEFAULT, cmos, 1
  DEFAULT, area_arcsec, 100. ; assume a HXR source of 10*10 arcsec
  
  IF cmos EQ 1 THEN BEGIN
    pixel_meters = 11d-6
    focal_meters = 2.
    pixel_arcsec = atan(pixel_meters/focal_meters)*180/!pi*3600
  ENDIF ELSE BEGIN
    print, 'Other options than CMOS are not currently implemented'
    RETURN, 0
  ENDELSE
  
  ; we need to make sure that we do not get more than 5 photons/pixel/sec
  
  npixels = area_arcsec / (pixel_arcsec^2) ; number of pixels receiving flux
  
  energy_mean = get_edges( energy_edges, /mean )
  e_bins  = get_edges( energy_edges, /width )

  area = foxsi4_effective_area(energy_mean, /cmos)
  count_flux_0 = phflux*area.eff_area_cm2
  totcounts_0 = total(count_flux_0 * e_bins) ; counts/sec

  countsperpixels0 = totcounts_0/npixels ; counts/sec/pixels
  
  IF countsperpixels GT 5. THEN BEGIN
    print, 'We have more than 5 counts/sec/pixel without attenuator'
    al_um_new = 10 ; starting point is 10 microns
    countsperpixels = countsperpixels0
    while countsperpixels GT 5. AND al_um LT 1000. DO BEGIN
      al_um = al_um_new
      area = foxsi4_effective_area(energy_mean, al_um=al_um, /cmos)
      count_flux_att = phflux*area.eff_area_cm2
      totcounts_att = total(count_flux_att * e_bins) ; counts/sec
      countsperpixels = totcounts_att/npixels ; counts/sec/pixels
      al_um_new = al_um*1.1
    endwhile
    print, countsperpixels, 'counts/sec/pixels'
    print, 'minimum Al attenuation needed is ', al_um, ' microns'
    
    be_um_new = 10 ; starting point is 10 microns
    countsperpixels = countsperpixels0
    while countsperpixels GT 5. AND be_um LT 1000. DO BEGIN
      be_um = be_um_new
      area = foxsi4_effective_area(energy_mean, be_um=be_um, /cmos)
      count_flux_att = phflux*area.eff_area_cm2
      totcounts_att = total(count_flux_att * e_bins) ; counts/sec
      countsperpixels = totcounts_att/npixels ; counts/sec/pixels
      be_um_new = be_um*1.1
    endwhile
    print, 'minimum Be attenuation needed is ', be_um, ' microns'
    print, countsperpixels, 'counts/sec/pixels'
  ENDIF

  RETURN, [al_um, be_um]
END
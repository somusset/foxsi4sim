FUNCTION foxsi4_photonflux_on_detector, spectrum_structure, energy_edges=energy_edges
  
  ; this is only for a 10-shell module so far
  count = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.PHOTON_FLUX, no_Det=1, energy_edges=energy_edges)
  count_th = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.thermal_FLUX, no_Det=1, energy_edges=energy_edges)
  count_nth = foxsi4_flare_response_simulation(spectrum_structure.energy_kev, spectrum_structure.nonthermal_FLUX, no_Det=1, energy_edges=energy_edges)

  count_spec = create_struct("energy_keV", count.energy_kev, "count_flux", count.count_flux, "thermal_flux", count_th.count_flux, "nonthermal_flux", count_nth.count_flux)

  RETURN, count_spec

END
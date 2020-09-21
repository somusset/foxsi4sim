FUNCTION foxsi4_get_xray_transmission, thickness_mm, material, energy_arr = energy_arr, $
  plot = plot

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the absorption and transmission in a given material
  ;    Possible materials include: 'al','be,'cdte','mylar','si'
  ;
  ; :inputs:
  ;    thickness_mm: thickness of the material in millimeters
  ;    material: string containing the material abreviation: 'al','be,'cdte','mylar','si'
  ;
  ; :outputs:
  ;   The function returns an structure containing the energy array, the transmission and the absorption
  ;
  ; :keywords:
  ;   energy_arr: an array of energies at which the transmission and absorption are to be calculated
  ;   plot: set to do this analysis for the cmos sensor
  ;
  ; :call:
  ;   This function calls csv table contained in a folder named mass_atten_idl
  ;
  ; :example:
  ;   A = foxsi4_get_xray_transmission(0.01, 'si')
  ;   
  ; :history:
  ;   2019/07/29, SMusset (UMN), initial release
  ;
  ; :to be done:
  ;-
  
  ; load the data
  path = 'mass_atten_idl/' + material + '.csv'
  f = file_search(path)
  IF f EQ '' THEN BEGIN
    print, 'File ' + path + ' not found.'
    print, 'Data for ' + material + ' may not exist?'
    RETURN, -1
  ENDIF
  data = read_csv(path, table_header=header, n_table_header = 4)
  density_cgs = float(strmid(header[3], 11, 4))

  data_energy_keV = data.field1 * 1000.0
  data_attenuation_coeff = data.field2

  IF NOT keyword_set(energy_arr) THEN energy_keV = findgen(60) ELSE $
    energy_keV = energy_arr

  ; interpolate in log space as function is better behaved in that space
  atten_len_um = 10^interpol(alog10(data_attenuation_coeff), alog10(data_energy_keV), alog10(energy_keV))
  ;should load this from the hdf5 file
  path_length_cm = thickness_mm / 10.0
  transmission = exp(-atten_len_um * density_cgs * path_length_cm)
  absorption = 1 - transmission

  IF keyword_set(PLOT) THEN BEGIN
    plot_title = material + ' ' + num2str(thickness_mm) + ' mm'
    plot, energy_keV, absorption, xtitle = 'Energy [keV]', ytitle = 'Efficiency', $
      /nodata, yrange = [0.0, 1.2], charsize = 1.5, title=plot_title
    oplot, energy_keV, absorption, psym = -4
    oplot, energy_keV, transmission, psym = -5
    ssw_legend, ['Transmission', 'Absorption'], linestyle=[1,2], psym=[5,4]
  ENDIF

  result = create_struct("energy_keV", energy_keV, "absorption", absorption, $
    "transmission", transmission)

  RETURN, result
END

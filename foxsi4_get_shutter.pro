FUNCTION foxsi4_get_shutter, energy_arr=energy_arr, be_um=be_um, al_um=al_um, poly_um=poly_um, data_dir=data_dir
  
  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the attenuation efficiency in FOXSI-4 due to FOXSI-2-like thermal blanketing,
  ;    and optional Be and/or Al shutters
  ;    + optional polymide filter
  ;
  ; :inputs:
  ;
  ; :outputs:
  ;   The function returns a structure that contains the energy array and the corresponding attenuation efficiency
  ;
  ; :keywords:
  ;   energy_arr: array of energies for which attenuation is calculated
  ;   be_um: thickness of Be shutter in micrometers, default is 0
  ;   al_um: thickness of Al shutter in micrometers, default is 0
  ;   poly_um: thickness of Polymide filter in micrometers, default is 0
  ;   data_dir: directory where to find the attenuation data. By default this is the calibration data folder in the FOXSI rocket distribution.
  ;  
  ; :call:
  ;   This procedure calls the following routine: 
  ;     read_len_att
  ;   This procedure will open .sav files containing the material information needed to calculate attenuation.
  ;   Those files are in the FOXSI package.
  ;   It can also call data files in the material_data folder
  ;  
  ; :example:
  ;   optical_path = foxsi4_get_shutter(energy_arr = energy_out, al_um=160.)
  ;   
  ; :heritage:
  ;   This procedure is a summary of the procedure get_foxsi_shutter in the FOXSI science software
  ;   
  ; :history:
  ;   2019/07/22, SMusset (UMN), initial release
  ;   2019/07/29, SMusset (UMN), updated values for FOXSI-3 defaults, from JVievering
  ;   2019/08/06, SMusset (UMN), added polymide option
  ;   2020/09/16, SMusset (UoG), changed path to polymide data + update documentation
  ;   2020/10/06, SMusset (UoG), changed default data_dir for compatibility with Mac and Unix
  ;   
  ; :to be done:
  ;-

  default, be_um, 0.0
  default, al_um, 0.0
  default, poly_um, 0.0
  default, data_dir, 'calibration_data/'

  ; New defaults for FOXSI-3 
  material = ['mylar', 'Be', 'Al', 'Kapton']
  th_um = [76.2, 0.0, 2.4, 0.0] ; in order: mylar, be, al, kapton in microns

  ; additional material
  mylar_um = 0.0
  kapton_um = 0.0
  
  add_um = [mylar_um, be_um, al_um, kapton_um]

  ; sum of blanketing and additional material
  total_th_um = th_um + add_um

  f = GETENV('FOXSIPKG')+'/'+data_dir + ["mylar_atten_len.dat","be_atten_len.dat", "al_atten_len.dat", "kapton_atten_len.dat"] ; sophie used GETENV for compatibility with windows
  
  FOR i = 0, n_elements(f)-1 DO BEGIN
    restore, f[i]

    IF keyword_set(energy_arr) THEN BEGIN
      atten_len_um = interpol(result.atten_len_um, result.energy_eV/1000.0, energy_arr)
    ENDIF ELSE BEGIN
      energy_arr = result.energy_eV/1000.0
      atten_len_um =  result.atten_len_um
    ENDELSE

    IF i EQ 0.0 THEN shut_eff = exp(-total_th_um[i]/atten_len_um) ELSE shut_eff = exp(-total_th_um[i]/atten_len_um)*shut_eff

    ; if values get too small
    ;
    index = where(shut_eff LE 1d-30, count)
    IF ((count NE 0) AND (min(index) NE 0)) THEN BEGIN
      tmp = findgen(min(index))
      shut_eff[tmp] = 0.0
    ENDIF

  ENDFOR
  
  IF poly_um NE 0. THEN BEGIN
    res = read_len_att('material_data/polymide')
    atten_len_um = interpol(double(res.ATTEN_LENGTH_MICRONS), double(res.PHOTON_ENERGY_EV)/1000.0, energy_arr)
    shut_eff = exp(-poly_um/atten_len_um)*shut_eff
  ENDIF

  result = create_struct("energy_keV", energy_arr, "shut_eff", shut_eff)
  RETURN, result
  
END
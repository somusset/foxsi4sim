FUNCTION foxsi4_get_pinhole_attenuation_factor, energy_arr=energy_arr

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the attenuation factor for the initial pinhole attenuator (see Dan for details)
  ;
  ; :inputs:
  ;
  ; :outputs:
  ;   The function returns a structure that contains the energy array and the corresponding attenuation factor
  ;
  ; :keywords:
  ;   energy_arr: array of energies for which attenuation is calculated, in keV
  ;
  ; :call:
  ;   This procedure will open a text file containing the attenuation factor at given energies
  ;
  ; :example:
  ;   res = foxsi4_get_pinhole_attenuation_factor(energy_arr = energy_out)
  ;   
  ; :history:
  ;   2019/10/28, SMusset (UMN), initial release
  ;   2020/09/16, SMusset (UoG), change path to file
  ;
  ; :to be done:
  ;-
  
  file = 'C:\Users\SMusset\Documents\GitHub\foxsi4\material_data\pinhole_attenuation_factor.txt'
  read_list_txt, file=file, tab=tab

  energy_att_kev = double(reform(tab[*,0]))
  factor_att = double(reform(tab[*,1]))
  
  IF keyword_set(energy_arr) THEN BEGIN
    factor = interpol(factor_att, energy_att_kev, energy_arr)
  ENDIF ELSE BEGIN
    energy_arr = energy_att_kev
    factor =  factor_att
  ENDELSE

  result = create_struct("energy_keV", energy_arr, "att_factor", factor)
  RETURN, result

END
FUNCTION read_len_att, file

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function reads a data file produced on this website: 
  ;    http://henke.lbl.gov/optical_constants/atten2.html
  ;    where the webpage containing the data as been saved in a file
  ;    The function returns a structure containing the energy in eV, the attenuation length in microns, and info on the material / angle / density
  ;
  ; :inputs:
  ;    file: string with the path to the file to read
  ;
  ; :outputs:
  ;   The function returns a structure containing the energy in eV, the attenuation length in microns, and info on the material / angle / density
  ;
  ; :call:
  ;
  ; :example:
  ;   res = read_len_att(silicon)
  ;   plot,res.photon_energy_ev, res.atten_length_microns
  ;   
  ; :history:
  ;   2019/08/06, SMusset (UMN), initial release
  ;
  ; :to be done:
  ;-
  
  openr, lun, file, /get_lun
  array = ''
  line = ''
  liste = list()
  infor = ''
  readf, lun, line
  print, line
  infor = strtrim(infor+' '+line,2)
  readf, lun, line
  print, line
  sptline = strsplit(line,',',/extract)
  field1 = repstr(repstr(repstr(strtrim(sptline[0],2), ' ', '_'), '(', ''), ')', '')
  field2 = repstr(repstr(repstr(strtrim(sptline[1],2), ' ', '_'), '(', ''), ')', '')
  
  WHILE NOT EOF(lun) DO BEGIN
    readf, lun, line
    array = [array, line]
    sptline = strsplit(line,/extract)
    liste.add, sptline
  ENDWHILE

  tab = liste.toarray()

  FREE_LUN, lun
  
  result = create_struct(field1, reform(TAB[*,0]), field2, reform(TAB[*,1]), "info", infor)

  return, result

END
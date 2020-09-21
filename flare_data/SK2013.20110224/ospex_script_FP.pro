; OSPEX script created Wed Jul 25 16:50:47 2012 by OSPEX writescript method.                
;                                                                                           
;  Call this script with the keyword argument, obj=obj to return the                        
;  OSPEX object reference for use at the command line as well as in the GUI.                
;  For example:                                                                             
;     ospex_script_FP, obj=obj                                                              
;                                                                                           
;  Note that this script simply sets parameters in the OSPEX object as they                 
;  were when you wrote the script, and optionally restores fit results.                     
;  To make OSPEX do anything in this script, you need to add some action commands.          
;  For instance, the command                                                                
;     obj -> dofit, /all                                                                    
;  would tell OSPEX to do fits in all your fit time intervals.                              
;  See the OSPEX methods section in the OSPEX documentation at                              
;  http://hesperia.gsfc.nasa.gov/ssw/packages/spex/doc/ospex_explanation.htm                
;  for a complete list of methods and their arguments.                                      
;                                                                                           
pro ospex_script_FP, obj=obj                                                                
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                       
obj-> set, spex_specfile= 'clean.fits'             
obj-> set, spex_source_angle= 90.0000                                                       
obj-> set, spex_image_full_srm= 1                                                           
obj-> set, spex_fit_time_interval= ['24-Feb-2011 07:29:40.000', $                           
 '24-Feb-2011 07:32:36.000']                                                                
obj-> set, fit_function= 'vth+thick2'                                                       
obj-> set, fit_comp_params= [0.353624, 1.25800, 1.00000, 1.04682, 3.77109, 33000.0, $       
 0.00000, 20.0000, 32000.0]                                                                 
obj-> set, fit_comp_minima= [1.00000e-20, 0.500000, 0.0100000, 1.00000e-10, 1.10000, $      
 1.00000, 1.10000, 1.00000, 100.000]                                                        
obj-> set, fit_comp_maxima= [1.00000e+20, 8.00000, 10.0000, 1.00000e+10, 20.0000, 100000., $
 20.0000, 1000.00, 1.00000e+07]                                                             
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]                         
obj-> set, fit_comp_spectrum= ['full', '']                                                  
obj-> set, fit_comp_model= ['chianti', '']                                                  
obj-> set, spex_roi_infile= 'ospex_roi_FP.sav'     
obj-> set, spex_roi_use= [1L, 2L]                                                           
obj-> set, spex_autoplot_bksub= 0                                                           
obj-> set, spex_autoplot_photons= 1                                                         
obj-> set, spex_autoplot_units= 'Flux'                                                      
obj-> set, spex_fitcomp_plot_photons= 1                                                     
obj-> set, spex_eband= [[10.0000, 15.8489], [15.8489, 25.1189], [25.1189, 39.8107], $       
 [39.8107, 63.0957], [63.0957, 100.000]]                                                    
obj-> set, spex_tband= ['24-Feb-2011 07:29:40.000', '24-Feb-2011 07:32:36.000']             
obj -> set, spex_roi_infile='ospex_roi_FP.sav'     
obj -> restorefit, file='ospex_results_FP.fits'    
end                                                                                         

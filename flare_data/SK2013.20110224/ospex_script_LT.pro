; OSPEX script created Wed Jul 25 16:46:00 2012 by OSPEX writescript method.                
;                                                                                           
;  Call this script with the keyword argument, obj=obj to return the                        
;  OSPEX object reference for use at the command line as well as in the GUI.                
;  For example:                                                                             
;     ospex_script_LT, obj=obj                                                              
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
pro ospex_script_LT, obj=obj                                                                
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                       
obj-> set, spex_specfile= 'clean.fits'             
obj-> set, spex_source_angle= 90.0000                                                       
obj-> set, spex_image_full_srm= 1                                                           
obj-> set, spex_erange= [10.000000D, 48.329304D]                                            
obj-> set, spex_fit_time_interval= ['24-Feb-2011 07:29:40.000', $                           
 '24-Feb-2011 07:32:36.000']                                                                
obj-> set, fit_function= 'vth+thin2'                                                        
obj-> set, fit_comp_params= [0.136227, 1.90501, 1.00000, 0.734875, 3.30131, 33000.0, $      
 0.00000, 20.0000, 32000.0]                                                                 
obj-> set, fit_comp_minima= [1.00000e-20, 0.500000, 0.0100000, 1.00000e-10, 0.100000, $     
 10.0000, 0.100000, 1.00000, 100.000]                                                       
obj-> set, fit_comp_maxima= [1.00000e+20, 8.00000, 10.0000, 1.00000e+15, 20.0000, 500.000, $
 20.0000, 1000.00, 1.00000e+07]                                                             
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]                         
obj-> set, fit_comp_spectrum= ['full', '']                                                  
obj-> set, fit_comp_model= ['chianti', '']                                                  
obj-> set, spex_roi_infile= 'ospex_roi_LT.sav'     
obj-> set, spex_autoplot_bksub= 0                                                           
obj-> set, spex_autoplot_photons= 1                                                         
obj-> set, spex_autoplot_units= 'Flux'                                                      
obj-> set, spex_fitcomp_plot_photons= 1                                                     
obj-> set, spex_eband= [[10.0000, 15.8489], [15.8489, 25.1189], [25.1189, 39.8107], $       
 [39.8107, 63.0957], [63.0957, 100.000]]                                                    
obj-> set, spex_tband= ['24-Feb-2011 07:29:40.000', '24-Feb-2011 07:32:36.000']             
obj -> set, spex_roi_infile='ospex_roi_LT.sav'     
obj -> restorefit, file='ospex_results_LT.fits'    
end                                                                                         

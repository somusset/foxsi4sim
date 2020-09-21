; OSPEX script created Wed Jul 25 16:37:58 2012 by OSPEX writescript method.                                  
;                                                                                                             
;  Call this script with the keyword argument, obj=obj to return the                                          
;  OSPEX object reference for use at the command line as well as in the GUI.                                  
;  For example:                                                                                               
;     ospex_script_FULL, obj=obj                                                                              
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
pro ospex_script_FULL, obj=obj                                                                                
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                                         
obj-> set, $                                                                                                  
 spex_specfile= 'hsi_spectrum_20110224_071600_PILEUP_CORRECTION.fits'
obj-> set, $                                                                                                  
 spex_drmfile= 'hsi_srm_20110224_071600_PILEUP_CORRECTION.fits'      
obj-> set, spex_source_angle= 90.0000                                                                         
obj-> set, spex_source_xy= [-927.922, 276.984]                                                                
obj-> set, spex_fit_time_interval= ['24-Feb-2011 07:29:40.000', $                                             
 '24-Feb-2011 07:32:36.000']                                                                                  
obj-> set, spex_bk_time_interval=['24-Feb-2011 07:16:12.000', '24-Feb-2011 07:19:28.000']                     
obj-> set, mcurvefit_itmax= 30L                                                                               
obj-> set, spex_uncert= 0.0700000                                                                             
obj-> set, fit_function= 'vth+thick2'                                                                         
obj-> set, fit_comp_params= [0.242794, 1.76657, 1.00000, 1.95485, 4.01326, 33000.0, $                         
 0.00000, 20.0000, 32000.0]                                                                                   
obj-> set, fit_comp_minima= [1.00000e-20, 0.500000, 0.0100000, 1.00000e-10, 1.10000, $                        
 1.00000, 1.10000, 1.00000, 100.000]                                                                          
obj-> set, fit_comp_maxima= [1.00000e+20, 8.00000, 10.0000, 1.00000e+10, 20.0000, 100000., $                  
 20.0000, 1000.00, 1.00000e+07]                                                                               
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 0B, 0B]                                           
obj-> set, fit_comp_spectrum= ['full', '']                                                                    
obj-> set, fit_comp_model= ['chianti', '']                                                                    
obj-> set, spex_autoplot_units= 'Flux'                                                                        
obj-> set, spex_fitcomp_plot_bk= 1                                                                            
obj-> set, spex_fitcomp_plot_photons= 1                                                                       
obj-> set, spex_eband= [[4.59000, 6.00000], [6.00000, 12.0000], [12.0000, 25.0000], $                         
 [25.0000, 50.0000], [50.0000, 100.000], [100.000, 185.510]]                                                  
obj-> set, spex_tband= [['24-Feb-2011 07:16:00.000', '24-Feb-2011 07:20:33.000'], $                           
 ['24-Feb-2011 07:20:33.000', '24-Feb-2011 07:25:06.000'], ['24-Feb-2011 07:25:06.000', $                     
 '24-Feb-2011 07:29:39.000'], ['24-Feb-2011 07:29:39.000', '24-Feb-2011 07:34:12.000']]                       
obj -> restorefit, file='ospex_results_FULL.fits'                    
end                                                                                                           

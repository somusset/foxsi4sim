# foxsi4

## Description

This is a set of routines which aim to the simulation of flare spectra, and the simulation of the FOXSI-4 sounding rocket spectral response / count spectra.

Typical flare spectra are simulated using scaling laws described in Battaglia et al 2005.

Real flare spectra are used from RHESSI observations from Simoes et al.

This is the beta version of the distribution and there might be bugs / access problems remaining.

## Example of utilisation of the routines
 
### to optimize an attenuator thickness to the M3 flare

; simulate the flare photon flux  
foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save

; best attenuator for cdte+10 shell  
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, loud=0, totcount_limit=5000)
; result print should be  
	while loop stopped for thickness =       494.141 um
	Al
	total count at the end if        5018.6570
	limit in total count was     5000

; best attenuator for cdte + msfc hi res  
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, loud=0, totcount_limit=5000, msfc=1)  
; this last line should print as a result:
	while loop stopped for thickness =       256.836 um
	Al
	total count at the end if        4977.5642
	limit in total count was     5000

; best attenuator for cmos+msfc high rate  
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cmos=1, al=1, loud=0, msfc=1)  
; result:  
	while loop stopped for thickness =       239.258 um  
	Al  
	total count at the end if        798.54748  
	limit in total count was      800  

; best attenuator for cmos+ nagoya high rate
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cmos=1, al=1, loud=0, high_res_j_optic=1)
; result:
	while loop stopped for thickness =       182.617 um
	Al
	total count at the end if        793.38454
	limit in total count was      800

; best attenuator for cdte + nagoya high rate
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, totcount_limit=5000, loud=0, high_res_j_optic=1)  
; result:  
	while loop stopped for thickness =       180.664 um  
	Al  
	total count at the end if        4957.7845  
	limit in total count was     5000  

### create the effective area plot   
foxsi4_plot_effective_area  

## Producing flare simulation figures  

### Figure 1 = M3 flare

; without noise  
foxsi4_proposal_figure, num=1, int_time=1., counting_stat=0, pinhole=0, highres=1

; with noise  
foxsi4_proposal_figure, num=1, int_time=1., counting_stat=1, pinhole=0, highres=1

### Figure 2 = C3 flare

; without noise  
foxsi4_proposal_figure, num=3, int_time=60., counting_stat=0, pinhole=0, highres=1

; with noise  
foxsi4_proposal_figure, num=3, int_time=60., counting_stat=1, pinhole=0, highres=1

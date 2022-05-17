# FOXSI4sim

This software is written in IDL. It uses the SolarSoft distribution, in particular the X-ray spectroscopy package. It also uses the FOXSI-science distribution assuming it has been installed as described: see https://github.com/foxsi/foxsi-science .

This software has not yet been tested on multiple computers. Data files could be missing, or paths could be wrong. Please report any bug!

## Description

This is a set of routines which aim to the simulation of flare spectra, and the simulation of the FOXSI-4 sounding rocket spectral response / count spectra. The tree showing interaction between the routines can be found in the 'doc' section.

Typical flare spectra are simulated using scaling laws described in Battaglia et al 2005.

Real flare spectra are used from RHESSI observations from Simoes et al.

This is the beta version of the distribution and there might be bugs / access problems remaining.

## Structure

This set of routines can be described in three categories:
1. Simulation of flare photon spectra
2. Simulation of FOXSI-4 spectral response
3. 'Wrappers', scripts to produce a particular figure using the simulations cited above.

Each category is described below.

### Simulation of flare photon spectra

Two approaches have been adopted to simulate flare photon spectra: 
1. the use of general parameters of flare spectra derived from statistical studies of flares,
2. the use of RHESSI observations of individual flares

In the first case, we used the statistical study of Battaglia et al (2005) AA 439, 737. This study gives an idea of the scaling relation between the GOES class of flares and several spectral parameters: temperature and emission measure for the thermal component, and photon spectral index and photon flux at 35 keV for the non-thermal component modeled by a single power law. The paper is available in the 'doc' section of the software.

The photon spectrum of a flare of a chosen GOES class can be produced with those scaling laws by calling the function `foxsi4_flare_simulation_from_goesclass`. Note that those scaling laws will not be representative for microflares.

In the second case, we chose to use RHESSI observations of two flares for which imaging spectroscopy was performed, to have a different spectra for the footpoint and the coronal part of the flare. We choose in particular a M3.5 flare described in Simoes & Kontar (2013) AA 551, A135 and a C2.6 flare described in Simoes et al (2015) AA 577, A68. Those papers are available in the 'doc' section of the software.

The data to reproduce the photon spectra for those flares was provided by the author when the parameters of the spectral analysis were not explicitely provided in the paper.  
The photon spectra can be accessed by calling the following routines: `foxsi4_flare_simulation_m3` and `foxsi4_flare_simulation_c3`.

An additional flare was used at some point: the flare data provided by the Hi-C sounding rocket team. While this flare has been labelled as a C5 flare for some time, it appeared that this is the data from an X-class flare (to be confirmed). The not up-to-date routine to retreive the spectrum of this flare is `foxsi4_flare_simulation_c5_hic`. I would not recommend using it without carefully reviewing what is done there.

### Simulation of the FOXSI4 spectral response

The FOXSI4 spectral response is multiple since there are many different optics and detectors to be considered. The following options are available:  

For optics:
* a 10-shell optic module (data from module 6 in FOXSI2)
* a high resolution module produced at MSFC (modelled as the sum of the two inner shells of a FOXSI2 10-shell module)
* a high resolution module produced at Nagoya University (model data provided by colleages from Nagoya)

For detectors:  
* FOXSI3 CdTe detector with variable thickness (but default thickness is 500 microns) - Note that the electrode absorption is taken into account
* Thick CMOS detector with variable thickness (default is 10 microns of Si)
* other options (such as the TimePix) are not yet implemented in the software

The spectral response also include absorption by the blankets, with the blanketing values from FOXSI-2. The user can also add a shutter by providing the thickness of Al or Be to be included in the response.
Note that a fancy pinhole attenuator is also considered and that the attenuation factor has been estimated by Dan at some point when writting the proposal, and there is the option to use this estimation for the attenuation by a shutter in the software. This is of course not the most up-to-date or realistic estimate, and it would be good to check with Dan to get better estimates in the future.

The routine calculating the FOXSI4 spectral response is the routine `foxsi4_flare_response_simulation`, which work in the following way:
1. Get the effective area (optics + detector efficiency + blanket and optional shutter) using the `foxsi4_effective_area` function
2. Convolve the count flux with a Gaussian with FWHM equal to the detector energy resolution (which is not energy dependent in this simulation)
3. Add Poisson noise (optional)
4. Bin the count spectrum in energy
5. Estimate the errors on the count flux

The routine therefore takes as input a photon flux and returns the observed count flux for the chosen configuration on FOXSI4.

The attenuation for FOXSI4 can be chosen using the function `foxsi4_best_attenuator` which can determine the thickness of attenuation needed to reduce the total count rate to a given threshold for a given flare spectrum.

### Wrappers

* `foxsi4_proposal_figures`: plot different versions of the real flare spectra that have been shown in the FOXSI-4 proposal.
* `foxsi4_real_flare_simulation`: similar to `foxsi4_proposal_figures` but less up to date.
* `foxsi4_goes_flare_plot`: generate typical flare spectra for a few selected GOES classes.
* `foxsi4_typical_flare_simulation`: similar to `foxsi4_goes_flare_plot` but less up to date.
* `foxsi4_flare_simulations`: similar to `foxsi4_goes_flare_plot` but less up to date.
* `foxsi4_plot_effective_area`: plot the effective area for the seven modules with combination of optics and detectors that were considered.
* `foxsi4_simulation_ospex_singledet`: generate simulated count spectrum for a single detector (CdTe/CMOS) and try photon spectrum reconstruction through spectral fitting in OSPEX.
* `foxsi4_simulation_ospex_comb`: photon spectrum reconstruction with OSPEX using a combination of CdTe and CMOS detectors.


## Example of utilisation of the routines
 
### to optimize an attenuator thickness to the M3 flare

Simulate the flare photon flux (for a real M3 or C3 flare)   
```
foxsi4_flare_simulation_m3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save  
; foxsi4_flare_simulation_c3, FP_spectrum, CS_spectrum, FULL_spectrum, energy_edges=energy_edges, save=save  
```
Find the best attenuator for cdte+10 shell  
```
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, loud=0, totcount_limit=5000)  
```
result print should be:
```  
    while loop stopped for thickness =       371.094 um  
    Al  
    total count at the end if        4996.3456  
    limit in total count was     5000  
```

Find best attenuator for cdte + msfc hi res  
```
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, loud=0, totcount_limit=5000, msfc=1)  
```
this last line should print as a result:  
```
	while loop stopped for thickness =       246.094 um  
	Al  
	total count at the end if        4976.2513  
	limit in total count was     5000  
```

Find best attenuator for cmos+msfc high rate  
```
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cmos=1, al=1, loud=0, msfc=1)  
```
The result:  
```
	while loop stopped for thickness =       224.609 um  
	Al  
	total count at the end if        802.40856  
	limit in total count was      800  
```

Find best attenuator for cmos+ nagoya high rate
```
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cmos=1, al=1, loud=0, high_res_j_optic=1)    
```
Expected result:  
```
	while loop stopped for thickness =       163.086 um  
	Al  
	total count at the end if        800.27361  
	limit in total count was      800  
```

Find best attenuator for cdte + nagoya high rate  
```
bestatt = foxsi4_best_attenuator(full_spectrum, energy_edges, cdte=1, al=1, totcount_limit=5000, loud=0, high_res_j_optic=1)    
```
Expected result:  
```
	while loop stopped for thickness =       161.133 um    
	Al  
	total count at the end if        4994.4159
	limit in total count was     5000  
```

### create the effective area plot   
```
foxsi4_plot_effective_area  
```

## Producing flare simulation figures 

Note: need to include energy resolution. This is partially implemented in the code, in the foxsi4_flare_response_simulation routine, but it is not working properly yet - there is the problem of edge effect when smoothing the input spectrum with a Gaussian. This should be look at before using the energy_resolution keyword...   

### Figure 1 = M3 flare

without noise:
```
foxsi4_proposal_figure, num=1, int_time=1., counting_stat=0, pinhole=0, highres=1  
```

with noise:
```  
foxsi4_proposal_figure, num=1, int_time=1., counting_stat=1, pinhole=0, highres=1  
```

### Figure 2 = C3 flare

without noise:
```
foxsi4_proposal_figure, num=3, int_time=60., counting_stat=0, pinhole=0, highres=1
```

with noise:
```
foxsi4_proposal_figure, num=3, int_time=60., counting_stat=1, pinhole=0, highres=1
```

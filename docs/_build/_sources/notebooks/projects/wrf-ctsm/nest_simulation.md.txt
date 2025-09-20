# 4 Nest Simulation

The following scripts are provided by the author for running a **one-way nesting** WRF-CTSM simulation. This is suitable for high-resolution WRF-CTSM simulations. As described in [Using CTSM with WRF (Nested Model Runs)](https://escomp.github.io/CTSM/lilac/specific-atm-models/wrf-nesting.html), **one-way nesting** means that boundary conditions are passed from the outer (parent) domain to the inner (child) domain, but not vice versa.

In a case of 4 nested domains, we run a WRF simulation for the outer 3 domains (i.e., d01, d02, d03) as dynamic downscaling, and then run a WRF-CTSM simulation for the innermost domain (i.e., d04). The workflow is:

- Run WPS for all domains
  - Get `met_em.d0*`, `geo_em.d0*`
- Run WRF for d01, d02, and d03 as dynamic downscaling
  - Get `wrfout_d03_*`
- Run `real.exe` for d03 and d04
  - Rename `met_em.d03.*.nc` as `met_em.d01.*.nc` and rename `met_em.d04.*.nc` as `met_em.d02.*.nc`  for running `real.exe` (here, the original `d03` is the outer domain and the original `d04` is the inner domain) 
  - Get `wrfinput_d02`
- Run `ndown.exe`  for d04
  - To extract data from `wrfout_d03_*` as input for the inner domain
  - Rename `wrfinput_d02` as `wrfndi_d02` for running `ndown.exe`
  - Get `wrfinput_d02` and `wrfbdy_d02`
- Run WRF-CTSM for d04 (single domain)
  - Generate CTSM surface data based on `geo_em.d04`
  - Rename `wrfinput_d02` as `wrfinput_d01` and rename `wrfbdy_d02` as `wrfbdy_d01`.

Please refer to the official tutorials for using `ndown.exe`:

- [Run ndown.exe](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/NestRuns/ndown4.php)
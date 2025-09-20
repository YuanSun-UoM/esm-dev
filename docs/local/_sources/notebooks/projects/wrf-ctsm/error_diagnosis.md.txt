# 6 Error Diagnosis

## NaN found

of NaNs =            1

 Which are NaNs =  F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F T F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F F
 NaN found in field Faxa_bcphidry at gridcell index/lon/lat:          127   358.19271850585938        53.250572204589844     
 ERROR:  ERROR: One or more of the CTSM cap output fields are NaN

**note**: This is the most common error from CTSM simulations, suggesting that CTSM does not get forcings on time. This could be caused by multiple factors, and I could not find a way to avoid it yet. 

**solution**: 

- Increase the time step to leave sufficient time for computing. 

- Decrease threads.

- Restart simulations based on `wrfrst` and ctsm restart files.

  
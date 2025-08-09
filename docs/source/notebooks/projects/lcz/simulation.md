# 3 Simulation

The following scripts are provided by the author for running CESM with LCZs. 

## Modify job script

- `use_lcz`: If true, use 10-LCZ urban land cover representation instead of the default 3-class scheme.

- Define the LCZ-based surface input. Please refer to the last section [2 Surface Input](./inputdata.md). 

- Define the LCZ-based `T_BUILDING_MAX` stream and set the stream start and end time covering the simulation period. 

  ```xml
  echo "use_lcz = .true.">> user_nl_clm
  echo "fsurdat='${SURF}'" >> user_nl_clm
  echo "stream_fldfilename_urbantv = '${INPUT}/project2/CTSM52_tbuildmax_OlesonFeddema_2020_0.9x1.25_simyr1849-2106_c240520.nc'">> user_nl_clm 
  echo "stream_year_first_urbantv = 1849" >> user_nl_clm
  echo "stream_year_last_urbantv = 2106" >> user_nl_clm
  echo "model_year_align_urbantv = 1849" >> user_nl_clm
  ```

  

- (optional) Enable `collapse_urban = .true.` to represent a single dominant LCZ class for each grid cell containing urban fractions.
  - This is cost-efficient for high-resolution simulations. 

## Surface initial data

- Currently, we do not have global initial data that fits well for LCZ urban classes. Thus, we need to spin up the model from a cold start. 
- Generating LCZ-based initial data by interpolating the existing initial data with three urban classes might cause an error. 
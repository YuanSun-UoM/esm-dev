# 3 Simulation

The following scripts are provided by the author for running CESM with the transient urban albedo functionality. 

## 3.1 Modify Job Script

- `transient_urbanalbedo_roof`: If true, roof albedo changes over time.

  - `stream_fldFileName_urbanalbtvroof`: Filename of input stream data for time varying urban roof albedo
  - `stream_meshfile_urbanalbtvroof`: Mesh filename of input stream data for time varying urban roof albedo
  - `stream_year_first_urbanalbtvroof`: First year to loop over for urban time varying roof albedo
  - `stream_year_last_urbanalbtvroof`: Last year to loop over for urban time varying roof albedo
  - `model_year_align_urbanalbtvroof`: Simulation year that aligns with `stream_year_first_urbanalbtvroof` value
  - `urbanalbtvroofmapalgo`: Spatial mapping method from urban time varying roof albedo file to the model resolution.
    - Please note that the spatial mapping method has been updated in the latest CTSM versions. Please refer to [ERROR: map algo copy is not supported](https://bb.cgd.ucar.edu/cesm/threads/error-map-algo-copy-is-not-supported.11495/#post-61402) and [supported mapping algorithms](https://github.com/ESCOMP/CDEPS/blob/main/streams/dshr_stream_mod.F90)
      - `bilinear`
      - `redist`
      - `nn`
      - `consf`
      - `consd`
      - `none`

- `transient_urbanalbedo_improad`: If true, impervious road albedo changes over time.

- `transient_urbanalbedo_wall`: If true, wall albedo changes over time

- Define the albedo stream input. Please refer to the last section [2 Surface Input](./inputdata.md). 

  ```bash
  # For example
  echo "transient_urbanalbedo_roof = .true.">> user_nl_clm
  echo "fsurdat='${SURF}'" >> user_nl_clm
  echo "stream_fldFileName_urbanalbtvroof = '${INPUT}/dyn_alb_roof_0.9x1.25_simyr2020-2025_c240930.nc'">> user_nl_clm 
  echo "stream_meshfile_urbanalbtvroof = '${INPUT}/lnd_mesh.nc'"
  echo "stream_year_first_urbanalbtvroof = 2000" >> user_nl_clm
  echo "stream_year_last_urbanalbtvroof = 2025" >> user_nl_clm
  echo "model_year_align_urbanalbtvroof = 2000" >> user_nl_clm
  echo "urbanalbtvroofmapalgo = 'nn'" >> user_nl_clm
  ```


# 3 Simulation

The following scripts are provided by the author for running CESM with the urban traffic functionality. 

## 3.1 Modify job script

- `urban_traffic`: If true, calculating urban traffic heat flux.

  - `stream_fldFileName_vehicletv`: Filename of input stream data for time varying urban traffic
  - `stream_meshfile_vehicletv`: Mesh filename of input stream data for time varying urban traffic
  - `stream_year_first_vehicletv`: First year to loop over for urban time varying traffic data
  - `stream_year_last_vehicletv`: Last year to loop over for urban time varying traffic data
  - `model_year_align_vehicletv`: Simulation year that aligns with `stream_year_first_vehicletv` value
  - `vehicletvmapalgo`: Mapping method from urban time varying traffic file to the model resolution.
    - Note that the mapping method has been updated in the new CTSM versions. Please refer to [ERROR: map algo copy is not supported](https://bb.cgd.ucar.edu/cesm/threads/error-map-algo-copy-is-not-supported.11495/#post-61402)

- Define the urban traffic stream input. Please refer to the last section [2 Surface Input](./inputdata.md). 

  ```bash
  # For example
  echo "urban_traffic = .true.">> user_nl_clm
  echo "fsurdat='${SURF}'" >> user_nl_clm
  echo "stream_fldFileName_vehicletv = '${INPUT}/urban_traffic_0.9x1.25_simyr2020-2025_c240930.nc'">> user_nl_clm 
  echo "stream_meshfile_vehicletv = '${INPUT}/lnd_mesh.nc'"
  echo "stream_year_first_vehicletv = 2000" >> user_nl_clm
  echo "stream_year_last_vehicletv = 2025" >> user_nl_clm
  echo "model_year_align_vehicletv = 2000" >> user_nl_clm
  echo "vehicletvmapalgo = 'nn'" >> user_nl_clm
  ```


# 2 Surface Input

The following Python scripts are provided by the author for generating LCZ-based Surface Input by modifying the default surface dataset containing three urban classes. 

```python
import rasterio
import xarray as xr
import numpy as np
import geopandas as gpd
from shapely.geometry import Polygon
from pyproj import CRS
from rasterio.warp import transform
from rasterio.features import geometry_mask
import netCDF4 as nc
```

## 2.1 Prepare Default Surface Dataset

- Option 1: Using existing surface data provided by NCAR. [Download](https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/lnd/clm2/surfdata_esmf/)
- Option 2: Using CTSM tools to generate surface data for a certain area and time (series)
  - Generating regional surface input using [mksurfdata_esmf](https://github.com/ESCOMP/CTSM/tree/master/tools/mksurfdata_esmf)
  - Extract regional/single-point surface data from global surface data using [site_and_regional](https://github.com/ESCOMP/CTSM/tree/master/tools/site_and_regional)

The default surface dataset, for example, `surfdata_001x001_MCR_SSP3-7.0_2022_78pfts_c240930.nc`, includes multiple urban parameters. In this dataset, numurbl=3, indicating that three urban land unit types are defined. Our target is to replace default urban parameters by LCZ-based urban parameters with numurbl=10.

## 2.2 Construct Grid Cell Boxes

- Construct the rectangular bounding box for each cell

  ```python
  ds_std = xr.open_dataset('surfdata_001x001_MCR_SSP3-7.0_2022_78pfts_c240930.nc')
  ds_lon = ds_std['LONGXY'][0] 
  ds_lat = ds_std['LATIXY'][:,0]
  lon_min = ds_lon.min()
  lon_max = ds_lon.max()
  lat_min = ds_lat.min()
  lat_max = ds_lat.max()
  gridcell = 0.01
  half_gridcell = gridcell/2
  grid_cells = []
  for lat in ds_lat:
      for lon in ds_lon:
          bbox = Polygon([
              (lon-half_gridcell, lat-half_gridcell),
              (lon+half_gridcell, lat-half_gridcell),
              (lon+half_gridcell, lat-half_gridcell),
              (lon-half_gridcell, lat-half_gridcell)
          ])
          grid_cells.append(bbox)
  gdf = gpd.GeoDataFrame(grid_cells, columns=['geometry'], crs=CRS.from_epsg(4326))    
  ```

- Alternatively, use grid information from `SCRIPgrid_*` file

  ```python
  from shapely.geometry import box
  ds_mesh = xr.open_dataset('SCRIPgrid_001x001_MCR_nomask_c240930.nc')
  grid_cells = []
  for i in range(ds_mesh.dims['grid_size']): 
      lats = ds_mesh['grid_corner_lat'][i].values 
      lons = ds_mesh['grid_corner_lon'][i].values 
      
      minx = lons.min()
      maxx = lons.max()
      miny = lats.min()
      maxy = lats.max()
      
      cell_box = box(minx, miny, maxx, maxy) 
      grid_cells.append(cell_box)
  ```

## 2.2 Calculate LCZ fraction

- We calculate LCZ fractions by aggregating LCZ pixels from a high-resolution LCZ map. 

- Scripts below use a clipped TIFF from [a global 100 m LCZ map](https://doi.org/10.5194/essd-14-3835-2022).

  ```python
  file_path = 'LCZ_MCR.tif' 
  with rasterio.open(file_path) as src:
      band = src.read(1)  # Read the first band
      transform = src.transform  # Transformation matrix (affine)
      crs = src.crs  # Coordinate Reference System
      bounds = src.bounds  # Geospatial bounds (left, bottom, right, top)
  
  band_list = range(1, 18)
  numband = len(band_list) 
  value_counts = {i: [] for i in band_list}
  
  # For each grid cell, count the occurrence of each pixel value (1 to 16)
  for cell in gdf['geometry']:
      # Mask the pixels that fall within the current grid cell
      pixel_mask = geometry_mask([cell], transform=transform, invert=True, out_shape=band.shape)
  
      # Apply the mask to the band data
      masked_pixels = band[pixel_mask]
      # Step 6: Calculate the percentage for each value (1 to 16) in each grid cell
      total_pixels_in_cell = len(masked_pixels)
      
      # Count the occurrences of each band value (1 to 16) in the masked pixels
      for value in band_list:
          count = np.sum(masked_pixels == value)
          percent = 100 * count / total_pixels_in_cell
          value_counts[value].append(percent)  
          
  # Create a 3D array to hold the percentage values
  pct_values = np.zeros((numband, lsmlat, lsmlon), dtype=np.float32)
  for j, value in enumerate(band_list):
      pct_values[j, :, :] = np.array(value_counts[value]).reshape(lsmlat, lsmlon)
  
  # Create xarray DataArray
  pct_da = xr.DataArray(pct_values,dims=["numband", "lsmlat", "lsmlon"],
                        coords={"numband": band_list,"lsmlat": lsmlat,"lsmlon": lsmlon},
                        name="PCT")
  ```

  

## 2.3 Fit CTSM land fraction

- Different from the LCZ classification, CTSM has natural vegetation, crop, glacier, lake, and three urban classes. The sum of land fractions is 100%. That is, 

  ```python
  check_sum = ds_std['PCT_CROP'] + ds_std['PCT_CROP'] + ds_std['PCT_LAKE'] + ds['PCT_URBAN'].sum(dim='numurbl') + ds_std['PCT_OCEAN'] 
  ```

- `PCT_URBAN` is a variable with three dimensions:
  - `numurbl`: number of urban
  - `lsmlat`
  - `lsmlon`
- The rest land classes are variables with two dimensions (lsmlat, lsmlon)

- Since we have calculated LCZ fractions, the `PCT_URBAN` is assigned as:

  ```python
  pct_urban = pct_da['PCT'][0:10]
  ```

## 2.4 Assign LCZ Urban Parameters

- Currently, LCZ urban parameters are assigned from look-up tables that vary by LCZ type (i.e., `numurbl`) but do not account for spatial variations. However, users can customize these parameters using three-dimensional arrays with dimensions (i.e.,  `numurbl`, `lsmlat`, `lsmlon`).

  ```python
  ht_roof = [37.50 , 17.50 , 6.50 , 37.50 , 17.50 , 6.50 , 3.00 , 6.50 , 6.50 , 10.00] 
  em_improad = [0.91, 0.91, 0.91, 0.91, 0.91, 0.91, 0.88, 0.91, 0.91, 0.91]
  em_perroad = [0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95]
  em_roof = [0.91, 0.91, 0.91, 0.91, 0.91, 0.91, 0.88, 0.91, 0.91, 0.91]
  em_wall = [0.90, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90]
  alb_improad = [0.14, 0.14, 0.14, 0.14, 0.14, 0.14, 0.18, 0.14, 0.14, 0.14]
  alb_perroad = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]
  alb_roof = [0.23, 0.28, 0.25, 0.23, 0.23, 0.23, 0.25, 0.25, 0.23, 0.20]
  alb_wall = [0.30, 0.25, 0.25, 0.30, 0.30, 0.30, 0.35, 0.30, 0.30, 0.25]
  canyon_hwr = [2.5, 1.25, 1.25, 0.75, 0.50, 0.50, 0.90, 0.50, 0.15, 0.35 ]
  tbuilding_min = [291, 291, 291, 291, 291, 291, 291, 291, 291, 291]
  thick_roof = [0.30, 0.30, 0.20, 0.30, 0.25, 0.20, 0.10, 0.20, 0.15, 0.10]
  thick_wall = [0.30, 0.25, 0.25, 0.20, 0.20, 0.20, 0.10, 0.20, 0.20, 0.10]
  tk_improad = [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]
  tk_roof = [1.70 , 1.70, 1.09 , 1.25 , 1.70 , 1.09 , 1.09 , 1.07 , 1.09 , 2.00]
  tk_wall = [1.27 , 2.60 , 1.66 , 1.45 , 1.88 , 1.66 , 1.00 , 1.07 , 1.66 , 1.42]
  cv_improad = [1.80, 1.80, 1.80, 1.80, 1.80, 1.80, 1.80, 1.80, 1.80, 1.80]
  cv_roof = [1.32 , 1.32 , 1.32 , 1.80 , 1.32 , 1.32 , 2.00 , 2.11 , 1.32 , 2.00]
  cv_wall = [1.54 , 1.54 , 1.54 , 2.00 , 1.54 , 1.54 , 2.00 , 2.11 , 1.54 , 1.59]
  wtroad_perv = [0.10 , 0.20 , 0.33 , 0.50 , 0.43 , 0.43 , 0.60 , 0.25 , 0.82 , 0.60]
  wtlunit_roof=[0.53 , 0.61 , 0.65 , 0.46 , 0.43 , 0.50 , 0.88 , 0.47 , 0.50 , 0.45]
  nlev_improad = [3 , 2 , 2 , 3 , 2 , 2 , 2 , 2 , 2 , 2] 
  ```

- Generate LCZ-based surface data 

  ```python
  output_file = 'surfdata_001x001_MCR_LCZ_2022_78pfts_c240930.nc'
  if os.path.exists(output_file):
      os.remove(output_file)
  
  numurbl = 10
  lsmlat = len(ds_std.lsmlat)
  lsmlon = len(ds_std.lsmlon)
  numrad = len(ds_std.numrad)
  nlevurb = len(ds_std.nlevurb)
  
  urban_variables = {
      'EM_IMPROAD': em_improad,
      'EM_PERROAD': em_perroad,
      'EM_ROOF': em_roof,
      'EM_WALL': em_wall,
      'CANYON_HWR': canyon_hwr,
      'T_BUILDING_MIN': tbuilding_min,
      'THICK_ROOF': thick_roof,
      'THICK_WALL': thick_wall,
      'WTROAD_PERV': wtroad_perv,
      'WTLUNIT_ROOF': wtlunit_roof,
      'NLEV_IMPROAD': nlev_improad
  }
  
  alb_variables = {
      'ALB_IMPROAD_DIR': alb_improad,
      'ALB_IMPROAD_DIF': alb_improad,
      'ALB_PERROAD_DIR': alb_perroad,
      'ALB_PERROAD_DIF': alb_perroad,
      'ALB_ROOF_DIR': alb_roof,
      'ALB_ROOF_DIF': alb_roof,
      'ALB_WALL_DIR': alb_wall,
      'ALB_WALL_DIF': alb_wall
  }
  
  tk_cv_variables = {
      'TK_IMPROAD': tk_improad,
      'TK_ROOF': tk_roof,
      'TK_WALL': tk_wall,
      'CV_IMPROAD': cv_improad,
      'CV_ROOF': cv_roof,
      'CV_WALL': cv_wall
  }
  
  with nc.Dataset(input_file, mode='r') as ds_std_nc:
      with nc.Dataset(output_file, mode='w',format='NETCDF3_CLASSIC') as ds_lcz_nc:
          for dim_name in ds_std_nc.dimensions:
              if dim_name != 'numurbl':
                 ds_lcz_nc.createDimension(dim_name, ds_std_nc.dimensions[dim_name].size)
          
          for var_name in ds_std_nc.variables:
              if var_name == 'mxsoil_color':
                  ds_lcz_nc.createVariable(var_name, 'i4', ())
                  ds_lcz_nc.variables[var_name][:] = 20
              else:
                  if 'numurbl' not in ds_std_nc[var_name].dimensions:
                      var = ds_std_nc.variables[var_name]
                      ds_lcz_nc.createVariable(var_name, var.datatype, var.dimensions)
                      
                      if len(var.dimensions) == 1:
                          ds_lcz_nc[var_name][:] = var[:]
                      elif len(var.dimensions) == 2:
                          ds_lcz_nc[var_name][:,:] = var[:,:]
                      elif len(var.dimensions) == 3:
                          ds_lcz_nc[var_name][:,:,:] = var[:,:,:]   
                      elif len(var.dimensions) == 4:
                          ds_lcz_nc[var_name][:,:,:,:] = var[:,:,:,:]         
          # Add 'numurbl' dimension with size 10 to the output dataset
          ds_lcz_nc.createDimension('numurbl', numurbl)
          for var_name, var_values in urban_variables.items():
              ds_lcz_nc.createVariable(var_name, ds_std_nc.variables[var_name].datatype, ('numurbl', 'lsmlat', 'lsmlon'))
              ds_lcz_nc.variables[var_name][:,:,:] = np.tile(np.array(var_values)[:, np.newaxis, np.newaxis], (1, lsmlat, lsmlon))
          for var_name, var_values in alb_variables.items():
              ds_lcz_nc.createVariable(var_name, ds_std_nc.variables[var_name].datatype, ('numrad', 'numurbl', 'lsmlat', 'lsmlon'))
              ds_lcz_nc.variables[var_name][:,:,:,:] = np.tile(np.array(var_values)[np.newaxis, :, np.newaxis, np.newaxis], (numrad, 1, lsmlat, lsmlon))
          for var_name, var_values in tk_cv_variables.items():
              ds_lcz_nc.createVariable(var_name, ds_std_nc.variables[var_name].datatype, ('nlevurb', 'numurbl', 'lsmlat', 'lsmlon'))
              ds_lcz_nc.variables[var_name][:,:,:,:] = np.tile(np.array(var_values)[np.newaxis, :, np.newaxis, np.newaxis], (nlevurb, 1, lsmlat, lsmlon))
          ds_lcz_nc.createVariable('HT_ROOF', ds_std_nc.variables['HT_ROOF'].datatype, ('numurbl', 'lsmlat', 'lsmlon'))    
          ds_lcz_nc.variables['HT_ROOF'][:,:,:] = np.round(ht_roof['HT_ROOF'][:,:,:],2)
          ds_lcz_nc.createVariable('WIND_HGT_CANYON', ds_std_nc.variables['WIND_HGT_CANYON'].datatype, ('numurbl', 'lsmlat', 'lsmlon'))    
          ds_lcz_nc.variables['WIND_HGT_CANYON'][:,:,:] = ds_lcz_nc.variables['HT_ROOF'][:,:,:] / 2
          ds_lcz_nc.createVariable('PCT_URBAN', ds_std_nc.variables['PCT_URBAN'].datatype, ('numurbl', 'lsmlat', 'lsmlon'))
          ds_lcz_nc.variables['PCT_URBAN'][:,:,:] = pct_urban[:,:,:]
          
          # manipulate non-urban fraction
          ds_lcz_nc.variables['PCT_CROP'][:,:] = ds_crop['PCT_CROP'][:,:]
          ds_lcz_nc.variables['PCT_NATVEG'][:,:] = 100 - ds_lcz_nc.variables['PCT_URBAN'][:,:,:].sum(axis =0) - ds_lcz_nc.variables['PCT_CROP'][:,:]
          ds_lcz_nc.variables['PCT_LAKE'][:,:] = 0
          ds_lcz_nc.variables['PCT_WETLAND'][:,:] = 0
          ds_lcz_nc.variables['PCT_GLACIER'][:,:] = 0
          ds_lcz_nc.variables['PCT_OCEAN'][:,:] = 0 
          for var_name in ds_std_nc.variables:
              ds_lcz_nc.variables[var_name].setncatts(ds_std_nc.variables[var_name].__dict__)
  ```

  **Note:** After changing the urban fraction, we need to manipulate the rest of the fractions to ensure the sum of all fractions is 100%. 

- In addition to surface data, CTSM requires separate data for the time-varying `T_BUILDING_MAX` stream (maximum building indoor temperature) for calculating air conditioning flux.

  ```python
  ds_std_tmax = xr.open_dataset(f'{home_path}dataset/inputdata/lnd/clm2/urbandata/CTSM52_tbuildmax_OlesonFeddema_2020_0.9x1.25_simyr1849-2106_c200605.nc')
  ds_template = ds_all.isel(time=slice(171, 177)) # 2020-2025
  output_filename = f'CTSM52_tbuildmax_LCZ_0.9x1.25_simyr2020-2025_c240930.nc'
  if os.path.exists(output_filename):
      os.remove(output_filename)
  
  time_units = "days since 0000-01-01 00:00:00"
  calendar = "noleap"
  time_values = nc.date2num(ds_template['time'], units=time_units, calendar=calendar) 
  time_bnds_units = "days since 2020-01-01 00:00:00"
  time_bnds_values = nc.date2num(ds_template['time_bnds'], units=time_bnds_units, calendar=calendar)
  
  with nc.Dataset(output_filename, 'w', format='NETCDF3_CLASSIC') as output:
      output.createDimension('lat', ds_template['lat'].size)
      output.createDimension('lon', ds_template['lon'].size)
      output.createDimension('time', None)
      output.createDimension('nv', ds_template['nv'].size)
      
      lat = output.createVariable('lat', 'f4', ('lat',))
      lat.long_name = ds_template['lat'].long_name
      lat.units = ds_template['lat'].units
      lat[:] = ds_template['lat']
      
      lon = output.createVariable('lon', 'f4', ('lon',))
      lon.long_name = ds_template['lon'].long_name
      lon.units = ds_template['lon'].units
      lon[:] = ds_template['lon']
  
      time = output.createVariable('time', 'f4', ('time',))
      time.long_name = ds_template['time'].long_name
      time.calendar = calendar
      time.units = time_units
      time[:] = time_values
      
      time_bnds = output.createVariable('time_bnds', 'f4', ('time', 'nv'))
      time_bnds.long_name = ds_template['time_bnds'].long_name
      time_bnds.calendar = calendar
      time_bnds.units = time_bnds_units
      time_bnds[:,:] = time_bnds_values
  
      year = output.createVariable('year', 'i4', ('time',))
      year.long_name = ds_template['year'].long_name
      year.units = ds_template['year'].units
      year[:] = ds_template['year']
  
      latitudes = output.createVariable('LATIXY', 'f4', ('lat','lon'))
      latitudes.long_name = ds_template['LATIXY'].long_name
      latitudes.units = ds_template['LATIXY'].units
      latitudes[:,:] = ds_template['LATIXY']
  
      longitudes = output.createVariable('LONGXY', 'f4', ('lat','lon'))
      longitudes.long_name = ds_template['LONGXY'].long_name
      longitudes.units = ds_template['LONGXY'].units
      longitudes[:,:] = ds_template['LONGXY']
  
      area = output.createVariable('area', 'f4', ('lat','lon'))
      area.long_name = ds_template['area'].long_name
      area.units = ds_template['area'].units
      area[:,:] = ds_template['area']
  
      landmask = output.createVariable('LANDMASK', 'i4', ('lat','lon'))
      landmask.long_name = ds_template['LANDMASK'].long_name
      landmask.units = ds_template['LANDMASK'].units
      landmask[:,:] = ds_template['LANDMASK']
      
      for i in range(numurbl):
        lcz_string = f'LCZ{i+1}'
        T_BUILDING_LCZ = output.createVariable(f'tbuildmax_{lcz_string}', 'f4', ('time','lat','lon'))
        T_BUILDING_LCZ.long_name = f'maximum interior building temperature for {lcz_string} class'
        T_BUILDING_LCZ.units = 'K'
        T_BUILDING_LCZ[:,:,:] = 350
  ```

  **Note:** 350 K is a dummy value for maximum indoor temperature, effectively disabling air conditioning. Users should assign more realistic T_BUILDING_MAX values tailored to each LCZ class.


# 2 Input Data

The following Python scripts are provided by the author for generating a separate urban albedo stream file.

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

- Taking transient urban albedo as an example, the new stream file has three variables: `dyn_alb_roof_TBD`, `dyn_alb_roof_HD`, and `dyn_alb_roof_MD`

## 2.1 For Global Simulations

- To generate global urban albedo stream data, we take an existing stream file as a template.

```python
ds_std_tmax = xr.open_dataset(f'{home_path}dataset/inputdata/lnd/clm2/urbandata/CTSM52_tbuildmax_OlesonFeddema_2020_0.9x1.25_simyr1849-2106_c200605.nc')
ds_template = ds_all.isel(time=slice(171, 177)) # 2020-2025
output_filename = f'dyn_alb_roof_0.9x1.25_simyr2020-2025_c240930.nc'
if os.path.exists(output_filename):
    os.remove(output_filename)

time_units = "days since 0000-01-01 00:00:00"
calendar = "noleap"
time_values = nc.date2num(ds_template['time'], units=time_units, calendar=calendar) 
time_bnds_units = "days since 2020-01-01 00:00:00" # time band
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
    
    for urban_class in ['TBD', 'HD', 'MD']:
        var_name = f'dyn_alb_roof_{urban_class}'
        var = output.createVariable(var_name, 'f4', ('time', 'lat', 'lon'))
        var.long_name = f'prescribed urban albedo for {urban_class} class'
        var.units = 'unitless'
        var[:, :, :] = albedo_3d_capped
```

- albedo_3d_capped is 3D (time, lat, lon) albedo array. Users could set the albedo varying by time (e.g., year, month, day) and location (i.e., lat, lon).

## 2.3 For Regional Simulations

-  To generate a regional urban albedo stream, we could specify the lat and lon information from the surface data.

```python
ds_def = xr.open_dataset('surfdata_1.2x1.2_SSP5-8.5_2035_78pfts_c250811.nc')

calendar = "noleap"
time_bnds_yearly = ds_template_tv['time_bnds'].values  # shape (time, 2)
time_monthly = []
time_bnds_monthly = []
# below is a time list by month
for start, end in time_bnds_yearly:
    year_start = start.year
    year_end = end.year  # typically start of next year
    for year in range(year_start, year_end):
        for month in range(1, 13):
            # Append monthly time (start of month)
            t_start = cftime.DatetimeNoLeap(year, month, 1)
            time_monthly.append(t_start)
            
            # Compute monthly bounds
            if month == 12:
                t_end = cftime.DatetimeNoLeap(year + 1, 1, 1)
            else:
                t_end = cftime.DatetimeNoLeap(year, month + 1, 1)
            time_bnds_monthly.append([t_start, t_end])

# Convert to numpy array
time_monthly = np.array(time_monthly, dtype=object)
time_bnds_monthly = np.array(time_bnds_monthly, dtype=object)
time_units = "days since 0000-01-01 00:00:00"
calendar = "noleap"
time_values = date2num(time_monthly, units=time_units, calendar=calendar)
time_bnds_values = date2num(time_bnds_monthly, units=time_units, calendar=calendar)

if os.path.exists(tv_output_filename2):
    os.remove(tv_output_filename2)

with nc.Dataset(tv_output_filename2, 'w', format='NETCDF3_CLASSIC') as output:
    output.createDimension('lat', len(lat))
    output.createDimension('lon', len(lon))
    output.createDimension('time', None) # set time as unlimited
    output.createDimension('nv', ds_template_tv['nv'].size)
    
    lat_var = output.createVariable('lat', 'f4', ('lat',))
    lat_var.long_name = ds_template_tv['lat'].long_name
    lat_var.units = ds_template_tv['lat'].units
    lat_var[:] = lat

    lon_var = output.createVariable('lon', 'f4', ('lon',))
    lon_var.long_name = ds_template_tv['lon'].long_name
    lon_var.units = ds_template_tv['lon'].units
    lon_var[:] = lon

    time = output.createVariable('time', 'f4', ('time',)) # f8 is double
    time.long_name = ds_template_tv['time'].long_name
    time.calendar = calendar
    time.units = time_units
    time[:] = time_values
    
    time_bnds = output.createVariable('time_bnds', 'f4', ('time', 'nv'))
    time_bnds.long_name = ds_template_tv['time_bnds'].long_name
    time_bnds.calendar = calendar
    time_bnds.units = time_units
    time_bnds[:,:] = time_bnds_values

    year = output.createVariable('year', 'i4', ('time',))
    year.long_name = ds_template_tv['year'].long_name
    year.units = ds_template_tv['year'].units
    year[:] = ds_template_tv['year']

    latitudes = output.createVariable('LATIXY', 'f4', ('lat','lon'))
    latitudes.long_name = ds_template_tv['LATIXY'].long_name
    latitudes.units = ds_template_tv['LATIXY'].units
    latitudes[:,:] = ds_def['LATIXY']

    longitudes = output.createVariable('LONGXY', 'f4', ('lat','lon'))
    longitudes.long_name = ds_template_tv['LONGXY'].long_name
    longitudes.units = ds_template_tv['LONGXY'].units
    longitudes[:,:] = ds_def['LONGXY']

    area = output.createVariable('area', 'f4', ('lat','lon'))
    area.long_name = ds_template_tv['area'].long_name
    area.units = ds_template_tv['area'].units
    #area[:,:] = ds_domain['area']
    area[:,:] = 1.44 # 1.2 km

    landmask = output.createVariable('LANDMASK', 'i4', ('lat','lon'))
    landmask.long_name = ds_template_tv['LANDMASK'].long_name
    landmask.units = ds_template_tv['LANDMASK'].units
    landmask[:,:] = ds_domain['mask']

    for urban_class in ['TBD', 'HD', 'MD']:
        var_name = f'dyn_alb_roof_{urban_class}'
        var = output.createVariable(var_name, 'f4', ('time', 'lat', 'lon'))
        var.long_name = f'prescribed urban albedo for {urban_class} class'
        var.units = 'unitless'
        var[:, :, :] = albedo_3d_capped
```


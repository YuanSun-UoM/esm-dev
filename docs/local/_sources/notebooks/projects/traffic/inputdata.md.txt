# 2 Input Data

The following Python scripts are provided by the author for generating a separate urban traffic stream file.

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

- The new traffic stream file has seven variables:

  - Annual average daily mean traffic volume over urban classes
    -  `vehicle_flow_TBD`
    -  `vehicle_flow_HD`
    -  `vehicle_flow_MD`
  - Percentage of vehicle types (sum up to 100%)
    - `vehicle_percent_PETROL`
    - `vehicle_percent_DIESEL`
    - `vehicle_percent_ELECTRIC`
    - `vehicle_percent_HYBRID`

  

# 3 Simulation

> The following scripts are provided by the author for running WRF-CTSM in a **single-domain** configuration.

> Guidance for running nested, multi-domain simulations is provided in a separate section.

```
export CASERUN_DIR=${CASE_DIR}${CASENAME}/runs/
export WRFARCHIVE_DIR=${CASERUN_DIR}archive/
export LILAC_DIR=${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/lilac/ctsm_build_dir/runtime_inputs/
cd ${CTSMINPUT_DIR}
cp ${LILAC_DIR}lilac_in .
cp ${LILAC_DIR}lnd_in .
```

## 3.1 Run `make_runtime_inputs`

- edit `${LILAC_DIR}/ctsm.cfg`

  - From

    ```
    # CTSM's domain file
    lnd_domain_file   = FILL_THIS_IN
    
    # CTSM's surface dataset
    fsurdat           = FILL_THIS_IN
    
    # The finidat (initial conditions) file does not absolutely need to be
    # specified, but in most cases, you should specify your own finidat file
    # rather than using one of the out-of-the-box ones.
    finidat           = UNSET
    ```

  - To:

    ```
    # CTSM's domain file
    lnd_domain_file   = '/home/yuansun/wrf/cases/TestSingleDomain/input/ctsm/domain.lnd.wrf2clm_lnd_noneg_wrf2clm_ocn_noneg.250510.nc'
    
    # CTSM's surface dataset
    fsurdat           = '/home/yuansun/wrf/cases/TestSingleDomain/input/ctsm/surfdata_1.2x1.2_SSP5-8.5_2022_78pfts_c250607.nc'
    
    # The finidat (initial conditions) file does not absolutely need to be
    # specified, but in most cases, you should specify your own finidat file
    # rather than using one of the out-of-the-box ones.
    finidat           = UNSET
    ```

  - Note: `ctsm.cfg` defines the CTSM namelist, with default values referring to [namelist_defaults_ctsm.xml](https://github.com/ESCOMP/CTSM/blob/master/bld/namelist_files/namelist_defaults_ctsm.xml).
  - `finidat = UNSET` will automatically use model default initialization data, where interpolation of initial data for CTSM is enabled by `use_init_interp = .true.` .

- Modify `${LILAC_DIR}/lilac.in`

  - From:

    ```
    &lilac_atmcap_input
     atm_mesh_filename = 'FILL_THIS_IN'
    /
    &lilac_lnd_input
     lnd_mesh_filename = 'FILL_THIS_IN'
    /
    ```

  - To:

    ```
    &lilac_atmcap_input
     atm_mesh_filename = '/home/yuansun/wrf/cases/TestSingleDomain/input/ctsm/mask_lnd_mesh.nc'
    /
    &lilac_lnd_input
     lnd_mesh_filename = '/home/yuansun/wrf/cases/TestSingleDomain/input/ctsm/lnd_mesh.nc'
    /
    ```

- Modify `${LILAC_DIR}/user_nl_ctsm

- Then, run `make_runtime_inputs` to generate `lnd.in`

  ```bash
  cd ${LILAC_DIR}
  ./make_runtime_inputs > make_runtime_inputs.log 2>&1
  
  mv lnd_in lilac_in drv_flds_in lnd_modelio.nml ${CTSMINPUT_DIR}
  ```

  - Note: running `make_runtime_inputs` to generate `lnd.in` is recommended instead of directly modifying `lnd.in`.

## 3.2 Modify `namelist.input`

Please refer to official resources:

- [WRF user guide](https://www2.mmm.ucar.edu/wrf/users/wrf_users_guide/build/html/index.html)
- [WRF-ARW online tutorials](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/)

## 3.3 Run WRF-CTSM

```bash
#!/bin/bash
ulimit -s unlimited
set -e
# set basic environment
WORK_ROOT="/home/yuansun/"
INROOT=${WORK_ROOT}/software
COMPILER=gcc
export MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
export ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
export HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
export PNETCDFDIR=${INROOT}/${COMPILER}/pnetcdf/1.12.3
export NETCDFCDIR=${INROOT}/${COMPILER}/netcdf-c/4.9.2
export NETCDFFDIR=${INROOT}/${COMPILER}/netcdf-fortran/4.6.1
export PIODIR=${INROOT}/${COMPILER}/pio/2.6.6
export ESMFDIR=${INROOT}/${COMPILER}/esmf/8.8.1
export JASPERDIR=${INROOT}/${COMPILER}/jasper/4.2.5
export LIBPNGDIR=${INROOT}/${COMPILER}/libpng/1.6.39
export LD_LIBRARY_PATH=$ZLIBDIR/lib:$HDF5DIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$MPICHDIR/lib:$PNETCDFDIR/lib:$PIODIR/lib:$ESMFDIR/lib:$JASPERDIR/lib:$LIBPNGDIR/lib:$LD_LIBRARY_PATH
export PATH=$HDF5DIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$MPICHDIR/bin:$PNETCDFDIR/bin:$ESMFDIR/bin:$JASPERDIR/bin:$PATH
export CPATH=$ZLIBDIR/include:$HDF5DIR/include:$NETCDFCDIR/include:$NETCDFFDIR/include:$MPICHDIR/include:$PNETCDFDIR/include:$PIODIR/include:$ESMFDIR/include:$JASPERDIR/include:$LIBPNGDIR/include:$CPATH
export MANPATH=$ZLIBDIR/share/man:$HDF5DIR/share/man:$NETCDFCDIR/share/man:$NETCDFFDIR/share/man:$MPICHDIR/share/man:$PNETCDFDIR/share/man:$JASPERDIR/share/man:$LIBPNGDIR/share/man:$MANPATH
export CC=gcc-9
export CXX=g++-9
export FC=gfortran-9
export FCFLAGS="-I$ESMFDIR/mod -I$ESMFDIR/include -I$NETCDFCDIR/include -I$NETCDFFDIR/include -I$PNETCDFDIR/include -I$PIODIR/include -I$ESMFDIR/include -I$JASPERDIR/include -I$LIBPNGDIR/include"
export CPPFLAGS="$FCFLAGS"
export LDFLAGS="-L$ZLIBDIR/lib -L$HDF5DIR/lib -L$NETCDFCDIR/lib -L$NETCDFFDIR/lib -L$MPICHDIR/lib -L$PNETCDFDIR/lib -L$PIODIR/lib -L$ESMFDIR/lib -L$ESMFDIR/lib -L$JASPERDIR/lib -L$LIBPNGDIR/lib"
export LIBRARY_PATH=$LD_LIBRARY_PATH

# set model path
export CESM_ROOT="${WORK_ROOT}cesm"
export WRF_ROOT="${WORK_ROOT}wrf"
export WRFNAME=WRF-CTSM
export CTSMNAME=CTSMdev
export CASE_DIR=${WRF_ROOT}/cases/
export CASENAME="TestSingleDomain"
export CASERUN_DIR=${CASE_DIR}${CASENAME}/runs/
export CASEINPUT_DIR=${CASE_DIR}${CASENAME}/input/
export CTSMINPUT_DIR=${CASEINPUT_DIR}ctsm/
export WRFINPUT_DIR=${CASEINPUT_DIR}wrf/

# add scripts to the run path
cd ${sub_dir}
mkdir init_generated_files
ln -sf ${WRF_ROOT}/${WRFNAME}/run/wrf.exe .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/CAMtr_volume_mixing_ratio.RCP8.5 CAMtr_volume_mixing_ratio
ln -sf ${WRF_ROOT}/${WRFNAME}/run/*.TBL .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/ozone* .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/*_DATA .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/tr* .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/*.txt .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/*.tbl .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/aerosol_* .
ln -sf ${WRF_ROOT}/${WRFNAME}/run/*.bin .
ln -sf ${WRFINPUT_DIR}namelist.input .
ln -sf ${CTSMINPUT_DIR}lnd_in .
ln -sf ${CTSMINPUT_DIR}lilac_in .
ln -sf ${CTSMINPUT_DIR}drv_flds_in .
ln -sf ${CTSMINPUT_DIR}lnd_modelio.nml .

# run 
export OMP_NUM_THREADS=6
mpirun -np 6 ./wrf.exe 2>&1 | tee wrf_bash.log 
```


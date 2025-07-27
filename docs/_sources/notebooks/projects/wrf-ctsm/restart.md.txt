# 5 Restart Simulation

> The following scripts are provided by the author to restart a WRF-CTSM simulation.

> This procedure is **experimental** and not officially documented by the CTSM or WRF development teams; therefore, it comes **without any guarantee**. 
>
> Please check the conversation on the [WRF-CSTM restart issue](https://bb.cgd.ucar.edu/cesm/threads/ctsm-restart-using-lilac-coupler.11510/).

## 5.1 Set CTSM Restart

### Modify `lnd_in`

- Change initial data

  - From:

    ```
     finidat = '/work/n02/n02/yuansun/cesm/cesm_inputdata/lnd/clm2/initdata_esmf/ctsm5.3/clmi.f19_interp_from.I1850Clm50BgcCrop-ciso.1366-01-01.0.9x1.25_gx1v7_simyr1850_c240223.nc'
    ```

  - To:

    ```
    nrevsn = '/work/n02/n02/yuansun/wrf/runs/wrf_GM3d/configuration/CTSM/input/restart_/ctsm_lilac0.clm2.r.2022-03-10-00000.nc'
    ```

- Turn off interplotation

  - From: 

    ```
    use_init_interp = .true.
    ```

  - To:

    ```
    use_init_interp = .false.
    ```

### Modify `lilac_in`

- change `caseid` to be different from the previous simulation

  - From:

    ```
    caseid = 'ctsm_lilac'
    ```

  - To:

    ```
    caseid = 'ctsm_lilac1'
    ```

### Manipulate Restart Data

- In case we want to restart based on `wrfrst_d01_2022-03-04_00:00:00`, we need to change the time for `*.clm2.r.*` and `*.lilac.r.*` .

  ```
  export RESTART_DATE="2022-03-10"
  export start_ymd=20220310
  
  ncap2 -O -s "timemgr_rst_start_ymd=${start_ymd}; timemgr_rst_ref_ymd=${start_ymd}" ${PREV_RESTART_DIR}${PREV_LILAC_NAME}.clm2.r.${RESTART_DATE}-00000.nc ${runs_ctsm}/input/restart_${NUM_RESTART}/${PREV_LILAC_NAME}.clm2.r.${RESTART_DATE}-00000.nc
  
  ncap2 -O -s "start_ymd=${start_ymd}" ${PREV_RESTART_DIR}${PREV_LILAC_NAME}.lilac.r.${RESTART_DATE}-00000.nc ${runs_ctsm}/input/restart_${NUM_RESTART}/${PREV_LILAC_NAME}.lilac.r.${RESTART_DATE}-00000.nc
  ```

## 5.2 Run `real.exe`

- Modify `namelist.input` by setting `start_` to the restart time. 
- Use `real.exe` to generate a new `wrfbdy.d01` and `wrfinput.d01` aligning with the restart time. 

## 5.3 Run WRF-CTSM Restart Simulation

- Modify `namelist.input` to inform a restart simulation

  - From:

    ```
    restart                             = .false.,
    ```

  - To:

    ```
    restart                             = .true.,
    ```

- In the job scripyt, add the modified `lnd_in`, `lilac_in`, `*clm2.r.*`, `*.lilac.r.*` as well as repointer file into the case run directory

  ```bash
  ln -sf ${PREV_RESTART_DIR}rpointer.lilac .
  ln -sf ${PREV_RESTART_DIR}rpointer.lnd.${RESTART_DATE}-00000 ./rpointer.lnd
  ln -sf ${runs_ctsm}/input/restart_${NUM_RESTART}/${PREV_LILAC_NAME}.clm2.r.${RESTART_DATE}-00000.nc .
  ln -sf ${runs_ctsm}/input/restart_${NUM_RESTART}/${PREV_LILAC_NAME}.lilac.r.${RESTART_DATE}-00000.nc .
  ```

  
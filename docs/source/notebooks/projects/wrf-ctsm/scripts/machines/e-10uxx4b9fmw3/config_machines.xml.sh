<machine MACH="e-10uxx4b9fmw3">
     <DESC>e-10uxx4b9fmw3 linux workstation, os is Linux, 36 pes/node</DESC>
     <OS>LINUX</OS>
     <COMPILERS>gnu</COMPILERS>
     <MPILIBS>mpich</MPILIBS>
     <CIME_OUTPUT_ROOT>/home/yuansun/cesm/runs</CIME_OUTPUT_ROOT>
     <DIN_LOC_ROOT>/home/yuansun/cesm/inputdata</DIN_LOC_ROOT>
     <DIN_LOC_ROOT_CLMFORC>/home/yuansun/cesm/inputdata/atm/datm7</DIN_LOC_ROOT_CLMFORC>
     <DOUT_S_ROOT>/home/yuansun/cesm/archive</DOUT_S_ROOT>
     <GMAKE>make</GMAKE>
     <GMAKE_J>36</GMAKE_J>
     <BATCH_SYSTEM>none</BATCH_SYSTEM>
     <SUPPORTED_BY>yuan.sun -at- manchester.ac.uk</SUPPORTED_BY>
     <MAX_TASKS_PER_NODE>36</MAX_TASKS_PER_NODE>
     <MAX_MPITASKS_PER_NODE>36</MAX_MPITASKS_PER_NODE>
     <PROJECT_REQUIRED>FALSE</PROJECT_REQUIRED>
     <mpirun mpilib="default">
      <executable>mpiexec</executable>
      <arguments>
        <arg name="num_tasks">-n $TOTALPES</arg>
        <arg name="labelstdout">-prepend-rank</arg>
      </arguments>
     </mpirun>
     <module_system type="none"/>
     <environment_variables>
      <env name="HDF5_DIR">/home/yuansun/software/gcc/hdf5/1.12.3</env>
      <env name="NetCDF_C_PATH">/home/yuansun/software/gcc/netcdf-c/4.9.2</env>
      <env name="NetCDF_Fortran_PATH">/home/yuansun/software/gcc/netcdf-fortran/4.6.1</env>
      <env name="MPI_PATH">/home/yuansun/software/gcc/mpich/4.0.2</env>
      <env name="PNETCDF_PATH">/home/yuansun/software/gcc/pnetcdf/1.12.3</env>
      <env name="ESMFMKFILE">/home/yuansun/software/gcc/esmf/8.8.1/lib/esmf.mk</env>
      <env name="PIO_VERSION_MAJOR">2</env>
      <env name="PIO_LIBDIR">/home/yuansun/software/gcc/pio/2.6.6/lib</env>
      <env name="PIO_INCDIR">/home/yuansun/software/gcc/pio/2.6.6/include</env>
      <env name="PIO_TYPENAME_VALID_VALUES">netcdf,pnetcdf,netcdf4p</env>
      <env name="PIO">/home/yuansun/software/gcc/pio/2.6.6</env>
     </environment_variables>
  </machine>
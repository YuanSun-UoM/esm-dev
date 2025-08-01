# 1 Installation

The following scripts are provided by the author for installing WRF-CTSM on a Linux workstation. Users should adapt these scripts to suit their own systems. For example, users on HPC systems may choose to load pre-installed modules (e.g., compiler, MPI, and libraries) rather than building them from source.

## 1.1 Preparation

### Install libraries

- [GCC](https://gcc.gnu.org/)
  - `gcc-8` or `gcc-9` is recommended. 
- [git-lfs](https://git-lfs.com/)
- [ncl](https://www.ncl.ucar.edu/Download/)
- [nco](https://nco.sourceforge.net/#bld)
- [mpich-4_0_2.sh](scripts/software/mpich-4_0_2.sh)
- [zlib-1_3_1.sh](scripts/software/zlib-1_3_1.sh)
- [hdf5-1_12_3.sh](scripts/software/hdf5-1_12_3.sh)
- [pnetcdf-1_12_3.sh](scripts/software/pnetcdf-1_12_3.sh)
- [netcdfc-4_9_2.sh](scripts/software/netcdfc-4_9_2.sh)
- [netcdff-4_6_1.sh](scripts/software/netcdff-4_6_1.sh)
- [pio-2_6_6.sh](scripts/software/pio-2_6_6.sh)
- [esmf-8_8_1.sh](scripts/software/esmf-8_8_1.sh)
- [jasper-4_2_5.sh](scripts/software/jasper-4_2_5.sh)
- [libpng-1_6_39.sh](scripts/software/libpng-1_6_39.sh)
- [lapack-3_9_0.sh](scripts/software/lapack-3_9_0.sh)

### Set environment

```bash
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
```

### Check the environment (optional)

- Check `git-lfs`

  ```bash
  git lfs version
  ```

- Check `gcc-9`

  ```bash
  which gcc-9
  ```

- Check `ncl`

  ```
  which ncl
  ```
  
- Check `nco`

  ```bash
  ncks --version
  ```
  
- Check `netcdf-c`

  ```bash
  nc-config --version
  nc-config --all
  ```

- Check `netcdf-fortran`

  ```bash
  nf-config --all
  ```


## 1.2 Source Code Download

### Download WRF code

```bash
export WRF_ROOT="${WORK_ROOT}wrf"
export WRFNAME=WRF-CTSM
cd ${WRF_ROOT}
git clone https://github.com/wrf-model/WRF.git ${WRFNAME} 
cd ${WRFNAME}
git checkout release-v4.7.0
```

### Modify WRF code

- According to [CTSM-Norway tutorial](https://metos-uio.github.io/CTSM-Norway-Documentation/wrf-ctsm/), modify `${WRF_ROOT}/${WRFNAME}/phys/module_sf_mynn.F`, around Line 1149, 

  - From:

    ```fortran
       Q2(I)=QSFCMR(I)+(QV1D(I)-QSFCMR(I))*PSIQ2/PSIQ
       Q2(I)= MAX(Q2(I), MIN(QSFCMR(I), QV1D(I)))
       Q2(I)= MIN(Q2(I), 1.05*QV1D(I))
    
       IF ( debug_code ) THEN
          yesno = 0
          IF (HFX(I) > 1200. .OR. HFX(I) < -700.)THEN
                print*,"SUSPICIOUS VALUES IN MYNN SFCLAYER",&
                I,J, "HFX: ",HFX(I)
                yesno = 1
          ENDIF
    ```

  - To:

    ```fortran
       Q2(I)=QSFCMR(I)+(QV1D(I)-QSFCMR(I))*PSIQ2/PSIQ
       Q2(I)= MAX(Q2(I), MIN(QSFCMR(I), QV1D(I)))
       Q2(I)= MIN(Q2(I), 1.05*QV1D(I))
       
    !YS
       IF (Q2(I) .LT. 0.0) THEN
           print*,"DEBUG: NEGATIVE Q2 VALUE IN MYNN SFCLAYER",&
           I,J, "Q2: ",Q2(I)
           print*,"WARNING: NEGATIVE Q2 SET TO ZERO"
           Q2(I)=0.0
       ENDIF
       IF (QSFC(I) .LT. 0.0) THEN
           print*,"DEBUG: NEGATIVE QSFC VALUE IN MYNN SFCLAYER",&
           I,J, "QSFC: ",QSFC(I)
       ENDIF
    !YS
    
       IF ( debug_code ) THEN
          yesno = 0
          IF (HFX(I) > 1200. .OR. HFX(I) < -700.)THEN
                print*,"SUSPICIOUS VALUES IN MYNN SFCLAYER",&
                I,J, "HFX: ",HFX(I)
                yesno = 1
          ENDIF
    ```


### Download CTSM code

```bash
export CTSMNAME=CTSMdev
cd ${WRF_ROOT}/${WRFNAME}
git clone https://github.com/ESCOMP/CTSM ${CTSMNAME}
cd ${CTSMNAME}
git checkout ctsm5.3.024
./bin/git-fleximod update
```

### Modify CTSM code

- Modify `${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/src/cpl/lilac/lnd_comp_esmf.F90`, around Line 38,

  - From:

    ```fortran
       use clm_varctl        , only : nsrStartup, nsrContinue
    ```

  - To:

    ```fortran
       !YS
       !use clm_varctl        , only : nsrStartup, nsrContinue
       use clm_varctl        , only : nsrStartup, nsrContinue, nsrBranch
       !YS
    ```

- According to [WRF-CTSM restart issue](https://bb.cgd.ucar.edu/cesm/threads/ctsm-restart-using-lilac-coupler.11510/), modify `${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/src/cpl/lilac/lnd_comp_esmf.F90`, around Line 293,

  - From:

    ```fortran
        if (trim(starttype) == trim('startup')) then
           nsrest = nsrStartup
        else if (trim(starttype) == trim('continue') ) then
           nsrest = nsrContinue
    ```

  - To:

    ```fortran
        if (trim(starttype) == trim('startup')) then
           nsrest = nsrStartup
        else if (trim(starttype) == trim('continue') ) then
    !YS    
           !nsrest = nsrContinue
           nsrest = nsrBranch
    !YS       
    ```
  
- According to [CTSM-Norway tutorial](https://metos-uio.github.io/CTSM-Norway-Documentation/wrf-ctsm/), modify `${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/src/cpl/utils/lnd_import_export_utils.F90`, around Line 131,

  - From:
    ```fortran
         if ( wateratm2lndbulk_inst%forc_q_not_downscaled_grc(g) < 0.0_r8 )then
              call shr_sys_abort( subname//&
              '         ERROR: Bottom layer specific humidty sent from the atmosphere model is less than zero' )
         end if 
    ```

  - To:

    ```fortran
         !YS       
         !if ( wateratm2lndbulk_inst%forc_q_not_downscaled_grc(g) < 0.0_r8 )then
             !call shr_sys_abort( subname//&
             !        ' ERROR: Bottom layer specific humidty sent from the atmosphere model is less than zero' )
         !end if
         !YS 
    ```
  
- According to [using the CTSM lake model](https://github.com/ESCOMP/CTSM/discussions/1832), modify ``${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/tools/create_scrip_file.ncl` by adding:

  ```
  lake_depth = wrf_file->LAKE_DEPTH(0,:,:) 
  lu_index = wrf_file->LU_INDEX(0,:,:) 
  lakemask = where(lu_index.eq.21, 1,0) 
  landmask = where (lakemask.eq.1,1,landmask)
  ```

- According to [CTSM-Norway tutorial](https://metos-uio.github.io/CTSM-Norway-Documentation/wrf-ctsm/), modify `${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/tools/site_and_regional/mkunitymap.ncl`, around Line 74:

  - From:

    ```
      if ( n_a .ne. n_b )then
         print( "ERROR: dimensions of input SCRIP grid files is NOT the same!" );
         exit
      end if
      
      if ( any(ncb->grid_imask .ne. 1.0d00) )then
         print( "ERROR: the mask of the second file isn't identically 1!" );
         print( "(second file should be land grid file)");
         exit
      end if
      
      chkvars = (/ "grid_center_lat", "grid_center_lon", "grid_corner_lat", "grid_corner_lon" /);
    ```

  - To:

    ```
      if ( n_a .ne. n_b )then
         print( "ERROR: dimensions of input SCRIP grid files is NOT the same!" );
         exit
      end if
    ;YS  
    ;  if ( any(ncb->grid_imask .ne. 1.0d00) )then
    ;     print( "ERROR: the mask of the second file isn't identically 1!" );
    ;     print( "(second file should be land grid file)");
    ;     exit
    ;  end if
    ;YS  
      chkvars = (/ "grid_center_lat", "grid_center_lon", "grid_corner_lat", "grid_corner_lon" /);
    ```

### Download WPS code

```bash
export WPSNAME=WPS
cd ${WRF_ROOT}
git clone https://github.com/wrf-model/WPS ${WPSNAME} 
cd ${WPSNAME}
git checkout v4.3
```

## 1.3 Build Model

### Build CTSM

- Customize machine configuration files under `${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/ccs_config/machines/${MACHINENAME}`

  - [config_machines.xml](../scripts/machines/e-10uxx4b9fmw3/config_machines.xml.sh)
  - [MACHINEANME.cmake](../scripts/machines/e-10uxx4b9fmw3/e-10uxx4b9fmw3.cmake.sh)

- Compile CTSM code

  ```bash
  export MACHINENAME=e-10uxx4b9fmw3
  cd ${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/lilac/
  ./build_ctsm ctsm_build_dir --machine ${MACHINENAME} --compiler gnu >build_ctsm.log 2>&1
  ```

- Check if compiled successully. The end of `build_ctsm.log` should be:

  ```
  clm built in 42.152718 seconds
  Initial setup complete; it is now safe to work with the runtime inputs in
  /home/yuansun/wrf/WRFnoleap-CTSMbranch/CTSMdev/lilac/ctsm_build_dir/runtime_inputs
  ```

- Set CTSM path for building WRF-CTSM

  ```bash
  source ctsm_build_dir/ctsm_build_environment.sh
  export WRF_CTSM_MKFILE=${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/lilac/ctsm_build_dir/ctsm.mk
  export WRF_EM_CORE=1
  export NETCDF_classic=1
  export WRFIO_NCD_LARGE_FILE_SUPPORT=1
  ```


### Build mksurfdata_esmf

- Compile mksurfdata_esmf

  ```
  cd ${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/tools/mksurfdata_esmf
  ./gen_mksurfdata_build --machine ${MACHINENAME} >gen_mksurfdata_build.log 2>&1
  ```

- Check if compiled successfully. The end of `gen_mksurfdata_build.log` should be:

  ```
  Successfully created input namelist file surfdata.namelist
  ```

### Build geo_domain

- According to [CTSM-Norway tutorial](https://metos-uio.github.io/CTSM-Norway-Documentation/wrf-ctsm/), build the `gen_domain` tool:

  ```
  cd ${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/tools
  touch configure_wrf-ctsm
  ```

- Copy scripts below to `configure_wrf-ctsm`:

  ```
  #!/usr/bin/env python3
  
  """This script writes CIME build information to a directory.
  
  The pieces of information that will be written include:
  
  1. Machine-specific build settings (i.e. the "Macros" file).
  2. File-specific build settings (i.e. "Depends" files).
  3. Environment variable loads (i.e. the env_mach_specific files).
  
  The .env_mach_specific.sh and .env_mach_specific.csh files are specific to a
  given compiler, MPI library, and DEBUG setting. By default, these will be the
  machine's default compiler, the machine's default MPI library, and FALSE,
  respectively. These can be changed by setting the environment variables
  COMPILER, MPILIB, and DEBUG, respectively.
  """
  
  # pylint: disable=W1505
  
  import os
  import sys
  
  real_file_dir = os.path.dirname(os.path.realpath(__file__))
  cimeroot = os.path.abspath(os.path.join(real_file_dir, ".."))
  sys.path.insert(0, cimeroot)
  
  from CIME.Tools.standard_script_setup import *
  from CIME.utils import expect, get_model
  from CIME.BuildTools.configure import configure
  from CIME.XML.machines import Machines
  
  logger = logging.getLogger(__name__)
  
  
  def parse_command_line(args):
      """Command line argument parser for configure."""
      description = __doc__
      parser = argparse.ArgumentParser(description=description)
      CIME.utils.setup_standard_logging_options(parser)
  
      parser.add_argument(
          "--machine", help="The machine to create build information for."
      )
      parser.add_argument(
          "--machines-dir",
          help="The machines directory to take build information "
          "from. Overrides the CIME_MODEL environment variable, "
          "and must be specified if that variable is not set.",
      )
      parser.add_argument(
          "--macros-format",
          action="append",
          choices=["Makefile", "CMake"],
          help="The format of Macros file to generate. If "
          "'Makefile' is passed in, a file called 'Macros.make' "
          "is generated. If 'CMake' is passed in, a file called "
          "'Macros.cmake' is generated. This option can be "
          "specified multiple times to generate multiple files. "
          "If not used at all, Macros generation is skipped. "
          "Note that Depends files are currently always in "
          "Makefile format, regardless of this option.",
      )
      parser.add_argument(
          "--output-dir",
          default=os.getcwd(),
          help="The directory to write files to. If not "
          "specified, defaults to the current working directory.",
      )
  
      parser.add_argument(
          "--compiler",
          "-compiler",
          help="Specify a compiler. "
          "To see list of supported compilers for each machine, use the utility query_config in this directory",
      )
  
      parser.add_argument(
          "--mpilib",
          "-mpilib",
          help="Specify the mpilib. "
          "To see list of supported mpilibs for each machine, use the utility query_config in this directory. "
          "The default is the first listing in MPILIBS in config_machines.xml",
      )
  
      parser.add_argument(
          "--clean",
          action="store_true",
          help="Remove old Macros and env files before attempting to create new ones",
      )
  
      parser.add_argument(
          "--comp-interface",
          default="mct",
          help="""The cime driver/cpl interface to use.""",
      )
  
      argcnt = len(args)
      args = parser.parse_args()
      CIME.utils.parse_args_and_handle_standard_logging_options(args)
  
      opts = {}
      if args.machines_dir is not None:
          machines_file = os.path.join(args.machines_dir, "config_machines.xml")
          machobj = Machines(infile=machines_file, machine=args.machine)
      else:
          model = get_model()
          if model is not None:
              machobj = Machines(machine=args.machine)
          else:
              expect(
                  False,
                  "Either --mach-dir or the CIME_MODEL environment "
                  "variable must be specified!",
              )
  
      opts["machobj"] = machobj
  
      if args.macros_format is None:
          opts["macros_format"] = []
      else:
          opts["macros_format"] = args.macros_format
  
      expect(
          os.path.isdir(args.output_dir),
          "Output directory '%s' does not exist." % args.output_dir,
      )
  
      opts["output_dir"] = args.output_dir
  
      # Set compiler.
      if args.compiler is not None:
          compiler = args.compiler
      elif "COMPILER" in os.environ:
          compiler = os.environ["COMPILER"]
      else:
          compiler = machobj.get_default_compiler()
          os.environ["COMPILER"] = compiler
      expect(
          opts["machobj"].is_valid_compiler(compiler),
          "Invalid compiler vendor given in COMPILER environment variable: %s" % compiler,
      )
      opts["compiler"] = compiler
      opts["os"] = machobj.get_value("OS")
      opts["comp_interface"] = args.comp_interface
  
      if args.clean:
          files = [
              "Macros.make",
              "Macros.cmake",
              "env_mach_specific.xml",
              ".env_mach_specific.sh",
              ".env_mach_specific.csh",
              "Depends.%s" % compiler,
              "Depends.%s" % args.machine,
              "Depends.%s.%s" % (args.machine, compiler),
          ]
          for file_ in files:
              if os.path.isfile(file_):
                  logger.warn("Removing file %s" % file_)
                  os.remove(file_)
          if argcnt == 2:
              opts["clean_only"] = True
              return opts
  
      # Set MPI library.
      if args.mpilib is not None:
          mpilib = args.mpilib
      elif "MPILIB" in os.environ:
          mpilib = os.environ["MPILIB"]
      else:
          mpilib = machobj.get_default_MPIlib(attributes={"compiler": compiler})
          os.environ["MPILIB"] = mpilib
  
      expect(
          opts["machobj"].is_valid_MPIlib(mpilib, attributes={"compiler": compiler}),
          "Invalid MPI library name given in MPILIB environment variable: %s" % mpilib,
      )
      opts["mpilib"] = mpilib
  
      # Set DEBUG flag.
      if "DEBUG" in os.environ:
          expect(
              os.environ["DEBUG"].lower() in ("true", "false"),
              "Invalid DEBUG environment variable value (must be 'TRUE' or "
              "'FALSE'): %s" % os.environ["DEBUG"],
          )
          debug = os.environ["DEBUG"].lower() == "true"
      else:
          debug = False
          os.environ["DEBUG"] = "FALSE"
      opts["debug"] = debug
  
      return opts
  
  
  def _main():
      opts = parse_command_line(sys.argv)
      if "clean_only" not in opts or not opts["clean_only"]:
          configure(
              opts["machobj"],
              opts["output_dir"],
              opts["macros_format"],
              opts["compiler"],
              opts["mpilib"],
              opts["debug"],
              opts["comp_interface"],
              opts["os"],
          )
  
  
  if __name__ == "__main__":
      _main()
  ```

- Run the scripts

  ```
  chmod +x configure_wrf-ctsm
  
  cd ${WRF_ROOT}/${WRFNAME}/${CTSMNAME}/tools/mapping/gen_domain_files/src/
  ../../../configure_wrf-ctsm --machine ${MACHINENAME} --compiler gnu --mpilib mpich --macros-format Makefile 
  
  . ./.env_mach_specific.sh ; make 
  ```

### Build WRF

- Create a configuration file named `configure.wrf`

  ```bash
  export NETCDF_C=/home/yuansun/software/gcc/netcdf-c/4.9.2
  export NETCDF=/home/yuansun/software/gcc/netcdf-fortran/4.6.1
  cd ${WRF_ROOT}/${WRFNAME}
  ./clean -a
  ./configure
  # - 34: (dmpar: distributed memory parallelization)
  # - 1: nesting option (basic)
  ```

- Modify `configure.wrf`

  - Link libraries:

    - From: 

      ```
       LIB_EXTERNAL    = \
                            -L$(WRF_SRC_ROOT_DIR)/external/io_netcdf -lwrfio_nf -L/home/yuansun/software/gcc/netcdf-fortran/4.6.1/lib -lnetcdff -lnetcdf     
      ```

    - To: 

      ```
      LIB_EXTERNAL    = \
                            -L$(WRF_SRC_ROOT_DIR)/external/io_netcdf -lwrfio_nf \
                            -L /home/yuansun/software/gcc/netcdf-c/4.9.2/lib -L /home/yuansun/software/gcc/netcdf-fortran/4.6.1/lib -lnetcdff -lnetcdf \
                            -L /home/yuansun/software/gcc/hdf5/1.12.3/lib -lhdf5_hl -lhdf5 \
                            -L /home/yuansun/software/gcc/pnetcdf/1.12.3/lib -lpnetcdf \
                            -L /home/yuansun/software/gcc/jasper/4.2.5/lib -ljasper \
                            -L /home/yuansun/software/gcc/libpng/1.6.39/lib -lpng \
                            -L /home/yuansun/software/gcc/zlib/1.3.1/lib -lz \
                            -L /home/yuansun/software/gcc/lapack/3.9.0 -llapack -lblas \
                            -lgomp -lm -ldl 
      ```

  - Setting:

    - From:

      ```
      SFC             =       gfortran
      SCC             =       gcc
      CCOMP           =       gcc
      
      DM_CC           =       mpicc -cc=$(SCC)
      CC              =       $(DM_CC)
      
      ARCH_LOCAL      =       -DNONSTANDARD_SYSTEM_SUBR  -DWRF_USE_CTSM -DNO_IEEE_MODULE -DNO_ISO_C_SUPPORT -DNO_FLUSH_SUPPORT -DNO_GAMMA_SUPPORT
      
      FCCOMPAT        =        -fallow-argument-mismatch -fallow-invalid-boz
      ```

    - To:

      ```
      SFC             =       gfortran-9
      SCC             =       gcc-9
      CCOMP           =       gcc-9
      
      DM_CC           =       mpicc
      CC              =       $(DM_CC) -DFSEEKO64_OK 
      
      ARCH_LOCAL      =       -DNONSTANDARD_SYSTEM_SUBR  -DWRF_USE_CTSM
      FCCOMPAT        = 
      ```

  - Adding include path

    - From:

      ```
      INCLUDE_MODULES =    $(MODULE_SRCH_FLAG) \
                           $(ESMF_MOD_INC) $(ESMF_LIB_FLAGS) \
                            -I$(WRF_SRC_ROOT_DIR)/main \
                            -I$(WRF_SRC_ROOT_DIR)/external/io_netcdf \
                            -I$(WRF_SRC_ROOT_DIR)/external/io_int \
                            -I$(WRF_SRC_ROOT_DIR)/frame \
                            -I$(WRF_SRC_ROOT_DIR)/share \
                            -I$(WRF_SRC_ROOT_DIR)/phys \
                            -I$(WRF_SRC_ROOT_DIR)/wrftladj \
                            -I$(WRF_SRC_ROOT_DIR)/chem -I$(WRF_SRC_ROOT_DIR)/inc \
                            -I$(NETCDFPATH)/include \
                            $(CTSM_INCLUDES)
      HDF5PATH        =
      PNETCDFPATH     =
      ```

    - To:

      ```
      INCLUDE_MODULES =    $(MODULE_SRCH_FLAG) \
                           $(ESMF_MOD_INC) $(ESMF_LIB_FLAGS) \
                            -I$(WRF_SRC_ROOT_DIR)/main \
                            -I$(WRF_SRC_ROOT_DIR)/external/io_netcdf \
                            -I$(WRF_SRC_ROOT_DIR)/external/io_int \
                            -I$(WRF_SRC_ROOT_DIR)/frame \
                            -I$(WRF_SRC_ROOT_DIR)/share \
                            -I$(WRF_SRC_ROOT_DIR)/phys \
                            -I$(WRF_SRC_ROOT_DIR)/wrftladj \
                            -I$(WRF_SRC_ROOT_DIR)/chem -I$(WRF_SRC_ROOT_DIR)/inc \
                            -I$(NETCDFPATH)/include \
                            -I${HDF5PATH}/include \
                            -I${JASPERPATH}/include \
                            -I${PNETCDFPATH}/include \
                            -I${LIBPNGPATH}/include \
                             $(CTSM_INCLUDES)
                             
      HDF5PATH        =    /home/yuansun/software/gcc/hdf5/1.12.3                     PNETCDFPATH     =    /home/yuansun/software/gcc/pnetcdf/1.12.3
      JASPERPATH      =    /home/yuansun/software/gcc/jasper/4.2.5
      LIBPNGPATH      =    /home/yuansun/software/gcc/libpng/1.6.39
      LAPACKPATH      =    /home/yuansun/software/gcc/lapack/3.9.0
      ```

- Compile WRF (taking around 20 minutes)

  ```bash
  nohup ./compile em_real 2>&1 > compile.log &
  ```

- Check if compiled successfully by listing excutable files. Must be four files:  `ndown.exe`, `real.exe`, `tc.exe`, `wrf. exe`

  ```bash
  ls main/*exe 
  ```

### Build WPS

- Compile WPS

  ```bash
  export WRF_DIR=${WRF_ROOT}/${WRFNAME}
  ./clean -a
  ./configure
  # - 3
  ./compile >& compile.log
  ```

- Check if compiled successfully by listing excutable files. Must be three files: `geogrid.exe`  `metgrid.exe `, `ungrib.exe`

  ```bash
  ls *exe
  ```

  
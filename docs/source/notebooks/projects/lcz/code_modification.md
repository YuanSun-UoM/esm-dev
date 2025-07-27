# 1 Code Modification

> The following scripts are provided by the author to enable urban LCZ (Local Climate Zone) classification within the [Community Terrestrial Systems Model (CTSM)](https://github.com/ESCOMP/CTSM), the land component of CESM. These scripts are intended for a specific version of CTSM, and we recommend **manual code modification** to ensure compatibility.

## 1.1 Use Modified Code Based on CTSM5.2.005

The author provides modified source files based on CTSM version 5.2.005. Users may directly replace the corresponding original files in their CTSM codebase with the modified versions listed below.

### Download Source Code

```bash
export CTSMNAME=CTSMdev
cd ${WRF_ROOT}/${WRFNAME}
git clone --branch ctsm5.2.025 https://github.com/ESCOMP/CTSM ${CTSMNAME}
cd ${CTSMNAME}
./manage_externals/checkout_externals
./manage_externals/checkout_externals -S
```

- **Note:** ctsm5.2.025 is provided for the existing code modification. Users should manually modify the code based on the specific version of CTSM they are using.

### Replace Modified Files

- [‎bld/namelist_files/namelist_definition_ctsm.xml](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/bld/namelist_files/namelist_definition_ctsm.xml)

- [src/main/landunit_varcon.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/landunit_varcon.F90)
- [src/main/initGridCellsMod.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/initGridCellsMod.F90)
- [src/main/subgridMod.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/subgridMod.F90)
- [src/main/LandunitType.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/LandunitType.F90)
- [src/cpl/share_esmf/UrbanTimeVarType.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/cpl/share_esmf/UrbanTimeVarType.F90)
- [src/cpl/mct/UrbanTimeVarType.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/cpl/mct/UrbanTimeVarType.F90)
- [src/dyn_subgrid/dynInitColumnsMod.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/dyn_subgrid/dynInitColumnsMod.F90)
- [src/main/clm_varctl.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/clm_varctl.F90)
- [src/main/controlMod.F90](https://github.com/envdes/code_CESM_LCZ/blob/main/1_code_modification/src/main/controlMod.F90)

## 1.2 Manual Code Modifications for Specific CTSM Versions

For a specific CTSM version, users need to manually modify the source code, which requires a basic understanding of the Fortran programming language. 

**Modified code sections are denoted using the following markers:**

```fortran
!YS
MODIFICATION
!YS
```

### Download Source Code

```
export CTSMNAME=CTSMdev
cd ${WRF_ROOT}/${WRFNAME}
git clone https://github.com/ESCOMP/CTSM ${CTSMNAME}
cd ${CTSMNAME}
git checkout ctsm5.3.024
./bin/git-fleximod update
```

- **Note:** The latest CTSM updates model infrastructure and removes the `mct` coupler. 

### Code Modification

- Modify `bld/namelist_files/namelist_definition_ctsm.xml` at the bottom line,

  - From:

    ```xml
    <entry id="max_tillage_depth" type="real" category="physics"
           group="tillage_inparm" valid_values="" value="0.26d00">
    Maximum depth to till soil (m). Default 0.26; original (Graham et al., 2021) value was unintentionally 0.32.
    </entry>
    
    </namelist_definition>
    ```

  - To:

    ```xml
    <entry id="max_tillage_depth" type="real" category="physics"
           group="tillage_inparm" valid_values="" value="0.26d00">
    Maximum depth to till soil (m). Default 0.26; original (Graham et al., 2021) value was unintentionally 0.32.
    </entry>
    !YS
    <!-- ========================================================================================  -->
    <!-- Namelist options related to the urban land-unit                                           -->
    <!-- ========================================================================================  -->
    <entry id="use_lcz" type="logical" category="clm_physics"
           group="clm_inparm" valid_values="" value=".false.">
    If TRUE, urban local climate zone landunits will be activated (Currently NOT implemented).
    </entry>
    !YS
    </namelist_definition>
    ```

- In `src/cpl/share_esmf/UrbanTimeVarType.F90`

  - After around Line 18 `  use GridcellType    , only : grc`, add:

    ```fortran
    !YS
      use clm_varctl      , only : use_lcz  
    !YS 
    ```

  - After around Line 80 `end if`, add:

    ```fortran
    !YS
        if (use_lcz) then
           stream_varname_MAX = 10
        else
           stream_varname_MAX = 3
        end if
    !YS
    ```

  - After around Line 124 `use UrbanParamsType  , only : urban_explicit_ac`, add:

    ```fortran
    !YS
        use landunit_varcon  , only : isturb_lcz1, isturb_lcz2, isturb_lcz3, &
                                     isturb_lcz4, isturb_lcz5, isturb_lcz6, &
                                     isturb_lcz7, isturb_lcz8, isturb_lcz9, &
                                     isturb_lcz10
    !YS 
    ```

  - After around Line 167 `stream_meshfile_urbantv    = ' '`, change

    - From:

      ```fortran
          stream_varnames(1) = "tbuildmax_TBD"
          stream_varnames(2) = "tbuildmax_HD"
          stream_varnames(3) = "tbuildmax_MD"
      ```

    - To:

      ```fortran
      !YS    
         if(.not. use_lcz) then
           stream_varnames(isturb_tbd -6) = "tbuildmax_TBD"
           stream_varnames(isturb_hd -6)  = "tbuildmax_HD"
           stream_varnames(isturb_md -6)  = "tbuildmax_MD"
         else if(use_lcz) then
           stream_varnames(isturb_lcz1 -6) = "tbuildmax_LCZ1"
           stream_varnames(isturb_lcz2 -6) = "tbuildmax_LCZ2"
           stream_varnames(isturb_lcz3 -6) = "tbuildmax_LCZ3"
           stream_varnames(isturb_lcz4 -6) = "tbuildmax_LCZ4"
           stream_varnames(isturb_lcz5 -6) = "tbuildmax_LCZ5"
           stream_varnames(isturb_lcz6 -6) = "tbuildmax_LCZ6"
           stream_varnames(isturb_lcz7 -6) = "tbuildmax_LCZ7"
           stream_varnames(isturb_lcz8 -6) = "tbuildmax_LCZ8"
           stream_varnames(isturb_lcz9 -6) = "tbuildmax_LCZ9"
           stream_varnames(isturb_lcz10-6) = "tbuildmax_LCZ10"  
         end if
      !YS
      ```

- In `src/dyn_subgrid/dynInitColumnsMod.F90`

  - After around Line 129, change

    - From:

      ```fortran
          case(isturb_MIN:isturb_MAX)
      ```

    - To:

      ```fortran
      !YS    case(isturb_MIN:isturb_MAX)
      !YS
          case(isturb_MIN:)
      !YS
      ```

- In `src/main/clm_varctl.F90` 

  - After around Line 413 `logical, public :: use_biomass_heat_storage = .false. ! true => include biomass heat storage in canopy energy budget`, add:

    ```fortran
    !YS  
      !----------------------------------------------------------
      ! urban landunit based on LCZs
      !----------------------------------------------------------
      
      logical, public :: use_lcz = .false.
    !YS  
    ```

- In `src/main/controlMod.F90`

  -  After around Line 215 `z0param_method, use_z0m_snowmelt`, add:

    ```fortran
    !YS    
        ! flag for urban LCZs
        namelist /clm_inparm/ use_lcz
    !YS 
    ```

  -  After Line 896 `end if`, add

    ```fortran
    !YS
        ! urban landunit
        call mpi_bcast(use_lcz, 1, MPI_LOGICAL, 0, mpicom, ier)
    !YS
    ```

- In `src/main/initGridCellsMod.F90`

  - After around Line 63 `use shr_const_mod     , only : SHR_CONST_PI`, add:

    ```fortran
    !YS    
        use clm_varctl        , only : use_lcz
        use landunit_varcon   , only : isturb_lcz1,isturb_lcz2,isturb_lcz3,isturb_lcz4,&
                                       isturb_lcz5,isturb_lcz6,isturb_lcz7,isturb_lcz8,&
                                       isturb_lcz9,isturb_lcz10 
    !YS
    ```

  - After around Line 139 `end do`, change

    - From:

      ```fortran
          ! Determine urban tall building district landunit
          do gdc = bounds_clump%begg,bounds_clump%endg
             call set_landunit_urban( &
                  ltype=isturb_tbd, gi=gdc, li=li, ci=ci, pi=pi)
      
          end do
      
          ! Determine urban high density landunit
          do gdc = bounds_clump%begg,bounds_clump%endg
             call set_landunit_urban( &
                  ltype=isturb_hd, gi=gdc, li=li, ci=ci, pi=pi)
          end do
      
          ! Determine urban medium density landunit
          do gdc = bounds_clump%begg,bounds_clump%endg
             call set_landunit_urban( &
                  ltype=isturb_md, gi=gdc, li=li, ci=ci, pi=pi)
          end do
      ```

    - To:

      ```fortran
      !YS
          if (.not. use_lcz) then
              ! Determine urban tall building district landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                      ltype=isturb_tbd, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban high density landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                      ltype=isturb_hd, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban medium density landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                      ltype=isturb_md, gi=gdc, li=li, ci=ci, pi=pi)
              end do
          else if (use_lcz) then
              ! Determine urban LCZ1 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz1, gi=gdc, li=li, ci=ci, pi=pi)
              end do
         
              ! Determine urban LCZ2 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz2, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ3 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz3, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ4 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz4, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ5 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz5, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ6 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz6, gi=gdc, li=li, ci=ci, pi=pi)
              end do
            
              ! Determine urban LCZ7 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz7, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ8 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz8, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ9 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz9, gi=gdc, li=li, ci=ci, pi=pi)
              end do
      
              ! Determine urban LCZ10 landunit
              do gdc = bounds_clump%begg,bounds_clump%endg
                 call set_landunit_urban( &
                        ltype=isturb_lcz10, gi=gdc, li=li, ci=ci, pi=pi)
              end do
          end if   
      !YS
      ```

  - After around Line 593 `use pftconMod       , only : noveg`, add:

    ```fortran
    !YS 
        use clm_varctl      , only : use_lcz
        use landunit_varcon , only : isturb_lcz1, isturb_lcz2, isturb_lcz3, &
                                     isturb_lcz4, isturb_lcz5, isturb_lcz6, &
                                     isturb_lcz7, isturb_lcz8, isturb_lcz9, &
                                     isturb_lcz10
        use subgridMod      , only : subgrid_get_info_urban_lcz1, subgrid_get_info_urban_lcz2, &
                                     subgrid_get_info_urban_lcz3, subgrid_get_info_urban_lcz4, &
                                     subgrid_get_info_urban_lcz5, subgrid_get_info_urban_lcz6, &
                                     subgrid_get_info_urban_lcz7, subgrid_get_info_urban_lcz8, &
                                     subgrid_get_info_urban_lcz9, subgrid_get_info_urban_lcz10 
    !YS    
    ```

  - After around Line 628 `! Set decomposition properties, and set variables specific to urban density type`, change

    - From:

      ```fortran
          select case (ltype)
          case (isturb_tbd)
             call subgrid_get_info_urban_tbd(gi, &
                  npatches=npatches, ncols=ncols, nlunits=nlunits)
          case (isturb_hd)
             call subgrid_get_info_urban_hd(gi, &
                  npatches=npatches, ncols=ncols, nlunits=nlunits)
          case (isturb_md)
             call subgrid_get_info_urban_md(gi, &
                  npatches=npatches, ncols=ncols, nlunits=nlunits)
          case default
             write(iulog,*)' set_landunit_urban: unknown ltype: ', ltype
             call endrun(msg=errMsg(sourcefile, __LINE__))
          end select
      ```

    - To:

      ```fortran
      !YS
          if (.not. use_lcz) then 
              select case (ltype)   
              case (isturb_tbd)
                 call subgrid_get_info_urban_tbd(gi, &
                      npatches=npatches, ncols=ncols, nlunits=nlunits)
              case (isturb_hd)
                 call subgrid_get_info_urban_hd(gi, &
                      npatches=npatches, ncols=ncols, nlunits=nlunits)
              case (isturb_md)
                 call subgrid_get_info_urban_md(gi, &
                      npatches=npatches, ncols=ncols, nlunits=nlunits)
              case default
                  write(iulog,*)' set_landunit_urban: unknown ltype: ', ltype
                  call endrun(msg=errMsg(sourcefile, __LINE__))                
              end select        
          else if (use_lcz) then
             select case (ltype)
             case (isturb_lcz1)
                  call subgrid_get_info_urban_lcz1(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz2)
                  call subgrid_get_info_urban_lcz2(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz3)
                  call subgrid_get_info_urban_lcz3(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz4)
                  call subgrid_get_info_urban_lcz4(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz5)
                  call subgrid_get_info_urban_lcz5(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz6)
                  call subgrid_get_info_urban_lcz6(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits) 
             case (isturb_lcz7)
                  call subgrid_get_info_urban_lcz7(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz8)
                  call subgrid_get_info_urban_lcz8(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz9)
                  call subgrid_get_info_urban_lcz9(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)
             case (isturb_lcz10)
                  call subgrid_get_info_urban_lcz10(gi, &
                       npatches=npatches, ncols=ncols, nlunits=nlunits)     
             case default
                  write(iulog,*)' set_landunit_urban: unknown ltype: ', ltype
                  call endrun(msg=errMsg(sourcefile, __LINE__))
             end select                                           
          end if
      !YS
      ```

- In `src/main/landunit_varcon.F90`

  - After around Line 8 `#include "shr_assert.h"`, add

    ```fortran
    !YS
      use clm_varctl      , only : use_lcz
    !YS
    ```

  - After around Line 30 `integer, parameter, public :: isturb_md  = 9  !urban md     landunit type`, change

    - From:

      ```fortran
        integer, parameter, public :: isturb_MAX = 9  !maximum urban type index
        integer, parameter, public :: max_lunit  = 9  !maximum value that lun%itype can have
                                              !(i.e., largest value in the above list)  
      
        integer, parameter, public                   :: landunit_name_length = 40  ! max length of landunit names
        character(len=landunit_name_length), public  :: landunit_names(max_lunit)  ! name of each landunit type
        ! parameters that depend on the above constants
      
        integer, parameter, public :: numurbl = isturb_MAX - isturb_MIN + 1   ! number of urban landunits  
      ```

    - To:

      ```fortran
      !YS  integer, parameter, public :: isturb_MAX = 9  !maximum urban type index
      !YS  integer, parameter, public :: max_lunit  = 9  !maximum value that lun%itype can have
                                              !(i.e., largest value in the above
      !YS  integer, parameter, public                   :: landunit_name_length = 40  ! max length of landunit names
      !YS  character(len=landunit_name_length), public  :: landunit_names(max_lunit)  ! name of each landunit type
      !YS
        ! 10 lCZs urban landunits  
        integer, parameter, public :: isturb_lcz1  = 7     !LCZ 1      urban landunit type
        integer, parameter, public :: isturb_lcz2  = 8     !LCZ 2      urban landunit type
        integer, parameter, public :: isturb_lcz3  = 9     !LCZ 3      urban landunit type
        integer, parameter, public :: isturb_lcz4  = 10    !LCZ 4      urban landunit type
        integer, parameter, public :: isturb_lcz5  = 11    !LCZ 5      urban landunit type
        integer, parameter, public :: isturb_lcz6  = 12    !LCZ 6      urban landunit type
        integer, parameter, public :: isturb_lcz7  = 13    !LCZ 7      urban landunit type
        integer, parameter, public :: isturb_lcz8  = 14    !LCZ 8      urban landunit type
        integer, parameter, public :: isturb_lcz9  = 15    !LCZ 9      urban landunit type
        integer, parameter, public :: isturb_lcz10 = 16    !LCZ 10     urban landunit type
        integer, parameter, public :: landunit_name_length = 40  ! max length of landunit names
        integer, public            :: max_lunit                  !maximum value that lun%itype can have
        integer, public            :: isturb_MAX                 !maximum urban type index
        integer, public            :: numurbl 
        character(len=landunit_name_length), allocatable, public  :: landunit_names(:)  ! name of each landunit type
      !YS
        ! parameters that depend on the above constants
      !YS  integer, parameter, public :: numurbl = isturb_MAX - isturb_MIN + 1   ! number of urban landunits  
      ```

  - After around Line 86 `character(len=*), parameter :: subname = 'landunit_varcon_init'`, add:

    ```fortran
    !YS
        ! parameters that depend on the above constants
        
        if (.not. use_lcz) then
           max_lunit = 9
           isturb_MAX = 9
        else if (use_lcz) then
           max_lunit = 16
           isturb_MAX = 16
        end if 
    
        numurbl = isturb_MAX - isturb_MIN + 1 
        allocate(landunit_names(max_lunit)) 
    !YS
    ```

  - After around Line 155 `landunit_names(istwet) = 'wetland'`, change

    - From:

      ```fortran
          landunit_names(isturb_tbd) = 'urban_tbd'
          landunit_names(isturb_hd) = 'urban_hd'
          landunit_names(isturb_md) = 'urban_md'
      ```

    - To:

      ```fortran
      !YS
          if (.not. use_lcz) then
             landunit_names(isturb_tbd) = 'urban_tbd'
             landunit_names(isturb_hd) = 'urban_hd'
             landunit_names(isturb_md) = 'urban_md'
          else if (use_lcz) then
             landunit_names(isturb_lcz1)  = 'urban_lcz1'
             landunit_names(isturb_lcz2)  = 'urban_lcz2'
             landunit_names(isturb_lcz3)  = 'urban_lcz3'
             landunit_names(isturb_lcz4)  = 'urban_lcz4'
             landunit_names(isturb_lcz5)  = 'urban_lcz5'
             landunit_names(isturb_lcz6)  = 'urban_lcz6'
             landunit_names(isturb_lcz7)  = 'urban_lcz7'
             landunit_names(isturb_lcz8)  = 'urban_lcz8'
             landunit_names(isturb_lcz9)  = 'urban_lcz9'
             landunit_names(isturb_lcz10) = 'urban_lcz10'
             !landunit_names(isturb_lcz11) = 'urban_lcz11'
          end if
      !YS
      ```

- In `src/main/subgridMod.F90`

  - After around Line 20 `use FatesInterfaceTypesMod, only : fates_maxElementsPerSite`, add:

    ```fortran
    !YS
      use clm_varctl     , only : use_lcz
      use landunit_varcon, only : isturb_lcz1, isturb_lcz2, isturb_lcz3, isturb_lcz4, &
                                  isturb_lcz5, isturb_lcz6, isturb_lcz7, &
                                  isturb_lcz8, isturb_lcz9, isturb_lcz10
    !YS
    ```

  - After around Line 47 `public :: urban_landunit_exists ! returns true if the urban landunit should be created in memory`, add:

    ```fortran
    !YS
      public :: subgrid_get_info_urban_lcz1
      public :: subgrid_get_info_urban_lcz2
      public :: subgrid_get_info_urban_lcz3
      public :: subgrid_get_info_urban_lcz4
      public :: subgrid_get_info_urban_lcz5
      public :: subgrid_get_info_urban_lcz6
      public :: subgrid_get_info_urban_lcz7
      public :: subgrid_get_info_urban_lcz8
      public :: subgrid_get_info_urban_lcz9
      public :: subgrid_get_info_urban_lcz10
    !YS  
    ```

  - After around Line 95, change

    - From:

      ```fortran
          call subgrid_get_info_urban_tbd(gi, npatches_temp, ncols_temp, nlunits_temp)
          call accumulate_counters()
      
          call subgrid_get_info_urban_hd(gi, npatches_temp, ncols_temp, nlunits_temp)
          call accumulate_counters()
      
          call subgrid_get_info_urban_md(gi, npatches_temp, ncols_temp, nlunits_temp)
          call accumulate_counters()
      ```

    - To:

      ```fortran
      !YS
          if (.not. use_lcz) then
             call subgrid_get_info_urban_tbd(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_hd(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_md(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
          else if (use_lcz) then
             call subgrid_get_info_urban_lcz1(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz2(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz3(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz4(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz5(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz6(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz7(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz8(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz9(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
             call subgrid_get_info_urban_lcz10(gi, npatches_temp, ncols_temp, nlunits_temp)
             call accumulate_counters()
          end if 
      !YS
      ```

  - After aound Line 370 `end subroutine subgrid_get_info_urban_md`, add:

    ```fortran
    !YS
      subroutine subgrid_get_info_urban_lcz1(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz1 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz1 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz1 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz1 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz1'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz1, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz1
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz2(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz2 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz2 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz2 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz2 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz2'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz2, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz2  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz3(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz3 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz3 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz3 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz3 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz3'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz3, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz3  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz4(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz4 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz4 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz4 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz4 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz4'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz4, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz4  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz5(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz5 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz5 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz5 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz5 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz5'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz5, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz5  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz6(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz6 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz6 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz6 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz6 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz6'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz6, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz6
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz7(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz7 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz7 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz7 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz7 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz7'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz7, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz7  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz8(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz8 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz8 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz8 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz8 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz8'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz8, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz8  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz9(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz9 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz9 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz9 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz9 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz9'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz9, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz9  
    
    !-----------------------------------------------------------------------
      subroutine subgrid_get_info_urban_lcz10(gi, npatches, ncols, nlunits)
        !
        ! !DESCRIPTION:
        ! Obtain properties for urban lcz10 landunit in this grid cell
        !
        ! !ARGUMENTS:
        integer, intent(in)  :: gi        ! grid cell index
        integer, intent(out) :: npatches  ! number of urban lcz10 patches in this grid cell
        integer, intent(out) :: ncols     ! number of urban lcz10 columns in this grid cell
        integer, intent(out) :: nlunits   ! number of urban lcz10 landunits in this grid cell
        !
        ! !LOCAL VARIABLES:
    
        character(len=*), parameter :: subname = 'subgrid_get_info_urban_lcz10'
        !-----------------------------------------------------------------------
    
        call subgrid_get_info_urban(gi, isturb_lcz10, npatches, ncols, nlunits)
    
      end subroutine subgrid_get_info_urban_lcz10 
    !YS
    ```

    

  
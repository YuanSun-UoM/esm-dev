# 1 Code Modification

The following scripts are provided by the author to enable transient urban albedo representation with the [Community Terrestrial Systems Model (CTSM)](https://github.com/ESCOMP/CTSM), the land component of CESM. These scripts are intended for a specific version of CTSM, and we recommend **manual code modification** to ensure compatibility.

## 1.1 Method 1: Use Modified Code Based on `clm5.0.30`

The author provides modified source files based on CLM version `clm5.0.30`. Users may directly replace the corresponding original files in their CLM codebase with the modified versions listed below.

### Download Source Code

```bash
export CTSMNAME=CLM
cd ${WRF_ROOT}/${WRFNAME}
git clone --branch clm5.0.30 https://github.com/ESCOMP/CTSM ${CTSMNAME}
cd ${CTSMNAME}
./manage_externals/checkout_externals
./manage_externals/checkout_externals -S
```

- **Note:** clm5.0.30 is provided for the existing code modification. Users should manually modify the code based on the specific version of CTSM they are using.

### Copy/Replace Modified files

- [src/biogeophys/UrbanDynAlbMod.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/biogeophys/UrbanDynAlbMod.F90)
- [src/biogeophys/UrbanAlbedoMod.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/biogeophys/UrbanAlbedoMod.F90)
- [src/biogeophys/UrbanParamsType.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/biogeophys/UrbanParamsType.F90)

- [src/main/clm_varctl.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/main/clm_varctl.F90)
- [src/main/controlMod.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/main/controlMod.F90)
- [src/main/clm_driver.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/main/clm_driver.F90)
- [bld/CLMBuildNamelist.pm](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/bld/CLMBuildNamelist.pm)
- [bld/namelist_files/namelist_defaults_clm4_5.xml](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/bld/namelist_defaults_clm4_5.xml)
- [bld/namelist_files/namelist_definition_clm4_5.xml](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/bld/namelist_definition_clm4_5.xml)
- [src/main/clm_instMod.F90](https://github.com/envdes/code_DynamicUrbanAlbedo/blob/main/1_code_modification/src/main/clm_instMod.F90)

## 1.2 Method 2: Manual Code Modifications for Specific CTSM Versions

For a specific CTSM version, users need to manually modify the source code, which requires a basic understanding of the Fortran programming language. 

For a specific CTSM version, users need to manually modify the source code, which requires a basic understanding of the Fortran programming language. 

**Modified code sections are denoted using the following markers:**

```fortran
!YS
MODIFICATION CODE
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

- **Note:** The latest CTSM updates model infrastructure and removes the `mct` coupler. The `UrbanDynAlbMod.F90` should be put under the folder of `src/cpl/share_esmf`

### Code Modification

- Under `src/cpl/share_esmf`, create a new F90 `UrbanDynAlbMod.F90`

  ```fortran
  module UrbanDynAlbMod
  !----------------------------------------------------------------------- 
  !
  !DESCRIPTION:
  !Transient Urban Albedo Input Stream Data
  !The time-varing urban albedo is read in using this module (a stream)
  !
  !USES:
   use ESMF            , only : ESMF_LogFoundError, ESMF_LOGERR_PASSTHRU, ESMF_Finalize, ESMF_END_ABORT
   use dshr_strdata_mod, only : shr_strdata_type
   use shr_kind_mod    , only : r8 => shr_kind_r8, CL => shr_kind_CL
   use shr_log_mod     , only : errMsg => shr_log_errMsg
   use abortutils      , only : endrun
   use decompMod       , only : bounds_type, subgrid_level_landunit
   use clm_varctl      , only : iulog, FL => fname_len
   use LandunitType    , only : lun
   use GridcellType    , only : grc
   use clm_varcon      , only : spval
   use landunit_varcon , only : isturb_MIN, isturb_MAX         ! isturb_MIN = 7, isturb_MAX = 9 or isturb_MAX = 16 (use_lcz=.true.)
   use clm_varpar      , only : numrad
   use UrbanParamsType , only : transient_urbanalbedo_roof
   use UrbanParamsType , only : transient_urbanalbedo_improad
   use UrbanParamsType , only : transient_urbanalbedo_wall
   ! 
   implicit none
   save
   private
   
   ! !PUBLIC TYPE
   type, public :: urbanalbtv_type
      ! urban wall albedo inputs
      real(r8), public, pointer :: dyn_alb_roof_dir        (:,:) ! dynamic lun direct  roof albedo
      real(r8), public, pointer :: dyn_alb_roof_dif        (:,:) ! dynamic lun diffuse roof albedo
      real(r8), public, pointer :: dyn_alb_improad_dir     (:,:) ! dynamic lun direct roof albedo
      real(r8), public, pointer :: dyn_alb_improad_dif     (:,:) ! dynamic lun diffuse roof albedo
      real(r8), public, pointer :: dyn_alb_wall_dir        (:,:) ! dynamic lun direct wall albedo
      real(r8), public, pointer :: dyn_alb_wall_dif        (:,:) ! dynamic lun diffuse wall albedo
      ! 
      type(shr_strdata_type)    :: sdat_urbanalbtvroof         ! urban time varying roof albedo data stream
      type(shr_strdata_type)    :: sdat_urbanalbtvimproad      ! urban time varying improad albedo data stream
      type(shr_strdata_type)    :: sdat_urbanalbtvwall         ! urban time varying wall albedo data stream
      
     contains
       ! !PUBLIC MEMBER FUNCTIONS:
       procedure, public :: dynalbinit                         ! Allocate and initialize urbanalbtv
       procedure, public :: urbanalbtvroof_init                ! Initialize urban wall albedo time varying stream
       procedure, public :: urbanalbtvroof_interp              ! Interpolate urban roof alebdo time varying stream
       procedure, public :: urbanalbtvimproad_init             ! Initialize urban improad albedo time varying stream
       procedure, public :: urbanalbtvimproad_interp           ! Interpolate urban improad alebdo time varying stream
       procedure, public :: urbanalbtvwall_init                ! Initialize urban wall albedo time varying stream
       procedure, public :: urbanalbtvwall_interp              ! Interpolate urban wall alebdo time varying stream
   end type urbanalbtv_type
  
    integer      , private              :: stream_varname_MIN       ! minimum index
    integer      , private              :: stream_varname_MAX       ! maximum index
    character(30), private, pointer     :: stream_var_name_roof(:)
    character(30), private, pointer     :: stream_var_name_improad(:)
    character(30), private, pointer     :: stream_var_name_wall(:)
  
    character(len=*), parameter, private :: sourcefile = &
         __FILE__
  
    !----------------------------------------------------------------------- 
   contains
    !-----------------------------------------------------------------------
    !
    subroutine dynalbinit(this, bounds, NLFilename)
    !
    ! !DESCRIPTION:
    ! Initialize data stream information for dynamic urban albedo
    !
    ! !USES:
    use shr_infnan_mod   , only : nan => shr_infnan_nan, assignment(=)
    use histFileMod      , only : hist_addfld2d
    use clm_varctl       , only : use_lcz
    !
    ! !ARGUMENTS:
    class(urbanalbtv_type)                 :: this
    type(bounds_type)      , intent(in)    :: bounds
    character(len=*)       , intent(in)    :: NLFilename   ! Namelist filename
    !
    ! !LOCAL VARIABLES:  
    integer             :: begl, endl
    !---------------------------------------------------------------------
    !
    begl = bounds%begl; endl = bounds%endl                        ! beginning and ending landunit index
    !
    ! Determine the minimum and maximum indices
    stream_varname_MIN = 1
    if (use_lcz) then
        stream_varname_MAX = 10
    else
        stream_varname_MAX = 3
    end if
    ! 
    ! Allocate urbanalbtv data structures
    ! 
    allocate(this%dyn_alb_roof_dir        (begl:endl,numrad))   ; this%dyn_alb_roof_dir        (:,:) = nan
    allocate(this%dyn_alb_roof_dif        (begl:endl,numrad))   ; this%dyn_alb_roof_dif        (:,:) = nan 
    allocate(this%dyn_alb_improad_dir     (begl:endl,numrad))   ; this%dyn_alb_improad_dir     (:,:) = nan   
    allocate(this%dyn_alb_improad_dif     (begl:endl,numrad))   ; this%dyn_alb_improad_dif     (:,:) = nan
    allocate(this%dyn_alb_wall_dir        (begl:endl,numrad))   ; this%dyn_alb_wall_dir        (:,:) = nan   
    allocate(this%dyn_alb_wall_dif        (begl:endl,numrad))   ; this%dyn_alb_wall_dif        (:,:) = nan
    allocate(stream_var_name_roof(stream_varname_MIN:stream_varname_MAX))
    allocate(stream_var_name_improad(stream_varname_MIN:stream_varname_MAX))
    allocate(stream_var_name_wall(stream_varname_MIN:stream_varname_MAX))
  
    if (transient_urbanalbedo_roof) then 
       call this%urbanalbtvroof_init(bounds, NLFilename)
       call this%urbanalbtvroof_interp(bounds)
       ! Add history fields
       call hist_addfld2d (fname='DYNALB_ROOF_DIR', units='',      &
              avgflag='A', long_name='time varing urban roof albedo dir',  type2d='numrad', &
              ptr_lunit=this%dyn_alb_roof_dir, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
       call hist_addfld2d (fname='DYNALB_ROOF_DIF', units='',      &
              avgflag='A', long_name='time varing urban roof albedo dif',  type2d='numrad',  &
              ptr_lunit=this%dyn_alb_roof_dif, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
    end if
    
    if (transient_urbanalbedo_improad) then    
       call this%urbanalbtvimproad_init(bounds, NLFilename)
       call this%urbanalbtvimproad_interp(bounds)
       ! Add history fields
       call hist_addfld2d (fname='DYNALB_IMPROAD_DIR', units='',      &
              avgflag='A', long_name='time varing urban improad albedo dir',  type2d='numrad', &
              ptr_lunit=this%dyn_alb_improad_dir, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
       call hist_addfld2d (fname='DYNALB_IMPROAD_DIF', units='',      &
              avgflag='A', long_name='time varing urban improad albedo dif',  type2d='numrad',  &
              ptr_lunit=this%dyn_alb_improad_dif, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
    end if
    
    if (transient_urbanalbedo_wall) then
       call this%urbanalbtvwall_init(bounds, NLFilename)
       call this%urbanalbtvwall_interp(bounds)
       ! Add history fields 
       call hist_addfld2d (fname='DYNALB_WALL_DIR', units='',      &
              avgflag='A', long_name='time varing urban wall albedo dir',  type2d='numrad', &
              ptr_lunit=this%dyn_alb_wall_dir, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
       call hist_addfld2d (fname='DYNALB_WALL_DIF', units='',      &
              avgflag='A', long_name='time varing urban wall albedo dif',  type2d='numrad',  &
              ptr_lunit=this%dyn_alb_wall_dif, default='inactive', set_nourb=spval, &
              l2g_scale_type='unity')
    end if   
    
   end subroutine dynalbinit
  
   !---------------------------------------------------------------------
   subroutine urbanalbtvroof_init(this, bounds, NLFileName)
     !
     ! !DESCRIPTION:
     ! Initialize data stream information for urban time varying roof albedo
     !
     ! !USES:
     use clm_nlUtilsMod   , only : find_nlgroup_name
     use spmdMod          , only : masterproc, mpicom, iam
     use shr_mpi_mod      , only : shr_mpi_bcast
     use dshr_strdata_mod , only : shr_strdata_init_from_inline
     use lnd_comp_shr     , only : mesh, model_clock
     use clm_varctl       , only : use_lcz
     use landunit_varcon  , only : isturb_tbd, isturb_hd, isturb_md          
     use landunit_varcon  , only : isturb_lcz1, isturb_lcz2, isturb_lcz3, &
                                   isturb_lcz4, isturb_lcz5, isturb_lcz6, &
                                   isturb_lcz7, isturb_lcz8, isturb_lcz9, &
                                   isturb_lcz10
     !
     ! !ARGUMENTS:
     implicit none
     class(urbanalbtv_type)         :: this
     type(bounds_type), intent(in)  :: bounds
     character(len=*),  intent(in)  :: NLFilename   ! Namelist filename
     ! 
     ! !LOCAL VARIABLES:
     integer            :: n
     integer            :: stream_year_first_urbanalbtvroof            ! first year in urban roof albedo tv stream to use
     integer            :: stream_year_last_urbanalbtvroof             ! last year in urban roof albedo tv stream to use
     integer            :: model_year_align_urbanalbtvroof             ! align stream_year_first_urbanalbtvroof with this model year
     integer            :: nu_nml                                      ! unit for namelist file 
     integer            :: nml_error                                   ! namelist i/o error flag
     character(len=CL)  :: stream_fldFileName_urbanalbtvroof           ! urban roof albedo time-varying streams filename
     character(len=FL)  :: stream_meshfile_urbanalbtvroof              ! urban roof albedo time-varying mesh filename
     character(len=CL)  :: urbanalbtvroofmapalgo = 'nn'                ! mapping alogrithm for urban ac
     character(len=CL)  :: urbanalbtvroof_tintalgo = 'linear'          ! time interpolation alogrithm 
     integer            :: rc                                          ! error code
     character(*), parameter :: subName = "('urbanalbtvroof_init')"
     !-----------------------------------------------------------------------
     namelist /urbanalbtvroof_streams/       &
          stream_year_first_urbanalbtvroof,  &  
          stream_year_last_urbanalbtvroof,   &  
          model_year_align_urbanalbtvroof,   &  
          urbanalbtvroofmapalgo,             &  
          stream_fldFileName_urbanalbtvroof, &  
          stream_meshfile_urbanalbtvroof,    &          
          urbanalbtvroof_tintalgo  
     !-----------------------------------------------------------------------       
     !               
     ! Default values for namelist
     stream_year_first_urbanalbtvroof  = 1      ! first year in stream to use
     stream_year_last_urbanalbtvroof   = 1      ! last  year in stream to use
     model_year_align_urbanalbtvroof   = 1      ! align stream_year_first_urbanalbtvroof with this model year
     stream_fldFileName_urbanalbtvroof = ' '
     stream_meshfile_urbanalbtvroof    = ' '
     
     ! create the field list for urban albedo fields
     if (.not. use_lcz) then 
        stream_var_name_roof(isturb_tbd -6) = "dyn_alb_roof_TBD"
        stream_var_name_roof(isturb_hd -6)  = "dyn_alb_roof_HD"
        stream_var_name_roof(isturb_md -6)  = "dyn_alb_roof_MD"   
     else
        stream_var_name_roof(isturb_lcz1 -6) = "dyn_alb_roof_LCZ1"
        stream_var_name_roof(isturb_lcz2 -6) = "dyn_alb_roof_LCZ2"
        stream_var_name_roof(isturb_lcz3 -6) = "dyn_alb_roof_LCZ3"
        stream_var_name_roof(isturb_lcz4 -6) = "dyn_alb_roof_LCZ4"
        stream_var_name_roof(isturb_lcz5 -6) = "dyn_alb_roof_LCZ5"
        stream_var_name_roof(isturb_lcz6 -6) = "dyn_alb_roof_LCZ6"
        stream_var_name_roof(isturb_lcz7 -6) = "dyn_alb_roof_LCZ7"
        stream_var_name_roof(isturb_lcz8 -6) = "dyn_alb_roof_LCZ8"
        stream_var_name_roof(isturb_lcz9 -6) = "dyn_alb_roof_LCZ9"
        stream_var_name_roof(isturb_lcz10-6) = "dyn_alb_roof_LCZ10"
     end if
  
     ! Read urbanalbtvroof_streams namelist
     if (masterproc) then
        open( newunit=nu_nml, file=trim(NLFilename), status='old', iostat=nml_error )
        call find_nlgroup_name(nu_nml, 'urbanalbtvroof_streams', status=nml_error)
        if (nml_error == 0) then
           read(nu_nml, nml=urbanalbtvroof_streams,iostat=nml_error) 
           if (nml_error /= 0) then
              call endrun(msg='ERROR reading urbanalbtvroof_streams namelist'//errMsg(sourcefile, __LINE__))
           end if
        else
            call endrun(subname // ':: ERROR finding urbanalbtvroof_streams namelist')   
        end if
        close(nu_nml)
     endif
  
     call shr_mpi_bcast(stream_year_first_urbanalbtvroof  , mpicom)
     call shr_mpi_bcast(stream_year_last_urbanalbtvroof   , mpicom)
     call shr_mpi_bcast(model_year_align_urbanalbtvroof   , mpicom)
     call shr_mpi_bcast(stream_fldFileName_urbanalbtvroof , mpicom)
     call shr_mpi_bcast(stream_meshfile_urbanalbtvroof    , mpicom)
     call shr_mpi_bcast(urbanalbtvroof_tintalgo           , mpicom)
     
     if (masterproc) then
         write(iulog,*) ' '
         write(iulog,*) 'Attemping to read time varying urban roof albedo parameters......'
         write(iulog,'(a)') 'urbanalbtvroof_streams settings:'
         write(iulog,'(a,i8)') '  stream_year_first_urbanalbtvroof  = ',stream_year_first_urbanalbtvroof
         write(iulog,'(a,i8)') '  stream_year_last_urbanalbtvroof   = ',stream_year_last_urbanalbtvroof
         write(iulog,'(a,i8)') '  model_year_align_urbanalbtvroof   = ',model_year_align_urbanalbtvroof
         write(iulog,'(a,a)' ) '  stream_fldFileName_urbanalbtvroof = ',stream_fldFileName_urbanalbtvroof
         write(iulog,'(a,a)' ) '  stream_meshfile_urbanalbtvroof    = ',stream_meshfile_urbanalbtvroof
         write(iulog,'(a,a)' ) '  urbanalbtvroof_tintalgo           = ',urbanalbtvroof_tintalgo
         write(iulog,*) 'Read in urbanalbtvroof_streams namelist from:',trim(NLFilename)
         do n = stream_varname_MIN,stream_varname_MAX
            write(iulog,'(a,a)' ) '  stream_var_name_roof         = ',trim(stream_var_name_roof(n))
         end do
     endif
      
      call shr_strdata_init_from_inline(this%sdat_urbanalbtvroof,                  &
           my_task             = iam,                                              &
           logunit             = iulog,                                            &
           compname            = 'LND',                                            &
           model_clock         = model_clock,                                      &
           model_mesh          = mesh,                                             &
           stream_meshfile     = trim(stream_meshfile_urbanalbtvroof),             &
           stream_lev_dimname  = 'null',                                           &
           stream_mapalgo      = trim(urbanalbtvroofmapalgo),                      &
           stream_filenames    = (/trim(stream_fldfilename_urbanalbtvroof)/),      &
           stream_fldlistFile  = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_fldListModel = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_yearFirst    = stream_year_first_urbanalbtvroof,                 &
           stream_yearLast     = stream_year_last_urbanalbtvroof,                  &
           stream_yearAlign    = model_year_align_urbanalbtvroof,                  &
           stream_offset       = 0,                                                &
           stream_taxmode      = 'extend',                                         &
           stream_dtlimit      = 1.0e30_r8,                                        &
           stream_tintalgo     = urbanalbtvroof_tintalgo,                          &
           stream_name         = 'Urban time varying roof albedo data',            &
           rc                  = rc)
  
     if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
     end if
      
    end subroutine urbanalbtvroof_init
  
    !==============================================================================
   
    subroutine urbanalbtvroof_interp(this, bounds)
      ! !DESCRIPTION:
      ! Interpolate data stream information for urban time varying albedo.
      ! 
      ! !USES:
      use clm_time_manager  , only : get_curr_date
      use clm_instur        , only : urban_valid
      use dshr_methods_mod  , only : dshr_fldbun_getfldptr
      use dshr_strdata_mod  , only : shr_strdata_advance
      use shr_infnan_mod    , only : nan => shr_infnan_nan, assignment(=)
      ! 
      ! !ARGUMENTS:
      ! 
      class(urbanalbtv_type)           :: this
      type(bounds_type), intent(in)    :: bounds
      !
      ! !LOCAL VARIABLES:
      !
      logical :: found
      integer :: l, ig, g, ip, n, ib    
      integer :: year    ! year (0, ...) for nstep+1
      integer :: mon     ! month (1, ..., 12) for nstep+1
      integer :: day     ! day of month (1, ..., 31) for nstep+1
      integer :: sec     ! seconds into current date for nstep+1
      integer :: mcdate  ! Current model date (yyyymmdd)
      integer :: lindx   ! landunit index
      integer :: gindx   ! gridcell index
      integer :: lsize
      integer :: rc
      real(r8), pointer :: dataptr1d(:)
      real(r8), pointer :: dataptr2d(:,:)
      ! 
      !-----------------------------------------------------------------------
      ! 
      ! Advance sdat stream
      !
      call get_curr_date(year, mon, day, sec)
      !
      ! packing the date into an integer
      mcdate = year*10000 + mon*100 + day
  
      call shr_strdata_advance(this%sdat_urbanalbtvroof, ymd=mcdate, tod=sec, logunit=iulog, istr='hdmdyn', rc=rc)
      if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
      end if
      !
      ! Create 2d array for all stream variable data
      lsize = bounds%endg - bounds%begg + 1
      allocate(dataptr2d(lsize, stream_varname_MIN:stream_varname_MAX))
      do n = stream_varname_MIN,stream_varname_MAX
         call dshr_fldbun_getFldPtr(this%sdat_urbanalbtvroof%pstrm(1)%fldbun_model, trim(stream_var_name_roof(n)), &
              fldptr1=dataptr1d, rc=rc)
         if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
            call ESMF_Finalize(endflag=ESMF_END_ABORT)
         end if
         ! Note that the size of dataptr1d includes ocean points so it will be around 3x larger than lsize
         ! So an explicit loop is required here
         do g = 1,lsize
            dataptr2d(g,n) = dataptr1d(g)
         end do
      end do
  
      ! Determine this%tbuilding_max (and this%p_ac, if applicable) for all landunits
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            ! Note that since l is within [begl, endl] bounds, we can assume
            ! lun%gricell(l) is within [begg, endg]
            ig = lun%gridcell(l) - bounds%begg + 1
            do ib = 1,numrad 
               do n = stream_varname_MIN,stream_varname_MAX
                  if (stream_var_name_roof((lun%itype(l)-6)) == stream_var_name_roof(n)) then
                     this%dyn_alb_roof_dir(l,ib) = dataptr2d(ig,n)
                     this%dyn_alb_roof_dif(l,ib) = dataptr2d(ig,n)
                  end if
               end do
            end do 
         else
             do ib = 1,numrad
                this%dyn_alb_roof_dir(l,ib) = spval
                this%dyn_alb_roof_dif(l,ib) = spval  
             end do  
         end if
      end do
      deallocate(dataptr2d)
  
      ! Error check
      found = .false.
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            do g = bounds%begg,bounds%endg
               if (g == lun%gridcell(l)) exit
            end do
            ! Check for valid urban data
            do ib = 1,numrad
               if ( .not. urban_valid(g) .or. (this%dyn_alb_roof_dir(l,ib) <= 0._r8) .or. (this%dyn_alb_roof_dif(l,ib) <= 0._r8)) then
                  found = .true.
                  gindx = g
                  lindx = l
                  exit
               end if
            end do   
         end if
      end do
      if ( found ) then
         write(iulog,*)'ERROR: no valid urban data for g= ',gindx
         write(iulog,*)'landunit type:   ',lun%itype(lindx)
         write(iulog,*)'urban_valid:     ',urban_valid(gindx)
         write(iulog,*)'dyn_alb_roof_dir:  ',this%dyn_alb_roof_dir(lindx,:)
         write(iulog,*)'dyn_alb_roof_dif:  ',this%dyn_alb_roof_dif(lindx,:)
         call endrun(subgrid_index=lindx, subgrid_level=subgrid_level_landunit, &
              msg=errmsg(sourcefile, __LINE__))
      end if
  
    end subroutine urbanalbtvroof_interp
  
   !---------------------------------------------------------------------
   subroutine urbanalbtvwall_init(this, bounds, NLFilename)
     !
     ! !DESCRIPTION:
     ! Initialize data stream information for urban time varying wall albedo
     !
     ! !USES:
     use clm_nlUtilsMod   , only : find_nlgroup_name
     use spmdMod          , only : masterproc, mpicom, iam
     use shr_mpi_mod      , only : shr_mpi_bcast
     use dshr_strdata_mod , only : shr_strdata_init_from_inline
     use lnd_comp_shr     , only : mesh, model_clock
     use clm_varctl       , only : use_lcz
     use landunit_varcon  , only : isturb_tbd, isturb_hd, isturb_md          
     use landunit_varcon  , only : isturb_lcz1, isturb_lcz2, isturb_lcz3, &
                                   isturb_lcz4, isturb_lcz5, isturb_lcz6, &
                                   isturb_lcz7, isturb_lcz8, isturb_lcz9, &
                                   isturb_lcz10
     !
     ! !ARGUMENTS:
     implicit none
     class(urbanalbtv_type)         :: this
     type(bounds_type), intent(in)  :: bounds
     character(len=*),  intent(in)  :: NLFilename   ! Namelist filename
     ! 
     ! !LOCAL VARIABLES:
     integer            :: n
     integer            :: stream_year_first_urbanalbtvwall            ! first year in urban wall albedo tv stream to use
     integer            :: stream_year_last_urbanalbtvwall             ! last year in urban wall albedo tv stream to use
     integer            :: model_year_align_urbanalbtvwall             ! align stream_year_first_urbanalbtvwall with this model year
     integer            :: nu_nml                                      ! unit for namelist file 
     integer            :: nml_error                                   ! namelist i/o error flag
     character(len=CL)  :: stream_fldFileName_urbanalbtvwall           ! urban wall albedo time-varying streams filename
     character(len=FL)  :: stream_meshfile_urbanalbtvwall              ! urban wall albedo time-varying mesh filename
     character(len=CL)  :: urbanalbtvwallmapalgo = 'nn'                ! mapping alogrithm for urban ac
     character(len=CL)  :: urbanalbtvwall_tintalgo = 'linear'          ! time interpolation alogrithm 
     integer            :: rc                                          ! error code
     character(*), parameter :: subName = "('urbanalbtvwall_init')"
     !-----------------------------------------------------------------------
     namelist /urbanalbtvwall_streams/       &
          stream_year_first_urbanalbtvwall,  &  
          stream_year_last_urbanalbtvwall,   &  
          model_year_align_urbanalbtvwall,   &  
          urbanalbtvwallmapalgo,             &  
          stream_fldFileName_urbanalbtvwall, &     
          stream_meshfile_urbanalbtvwall,    &  
          urbanalbtvwall_tintalgo  
     !-----------------------------------------------------------------------       
     !               
     ! Default values for namelist
     stream_year_first_urbanalbtvwall  = 1      ! first year in stream to use
     stream_year_last_urbanalbtvwall   = 1      ! last  year in stream to use
     model_year_align_urbanalbtvwall   = 1      ! align stream_year_first_urbanalbtvwall with this model year
     stream_fldFileName_urbanalbtvwall = ' '
     stream_meshfile_urbanalbtvwall    = ' '
     
     ! create the field list for urban albedo fields
     if (.not. use_lcz) then 
        stream_var_name_roof(isturb_tbd -6) = "dyn_alb_roof_TBD"
        stream_var_name_roof(isturb_hd -6)  = "dyn_alb_roof_HD"
        stream_var_name_roof(isturb_md -6)  = "dyn_alb_roof_MD"   
     else
        stream_var_name_roof(isturb_lcz1 -6) = "dyn_alb_roof_LCZ1"
        stream_var_name_roof(isturb_lcz2 -6) = "dyn_alb_roof_LCZ2"
        stream_var_name_roof(isturb_lcz3 -6) = "dyn_alb_roof_LCZ3"
        stream_var_name_roof(isturb_lcz4 -6) = "dyn_alb_roof_LCZ4"
        stream_var_name_roof(isturb_lcz5 -6) = "dyn_alb_roof_LCZ5"
        stream_var_name_roof(isturb_lcz6 -6) = "dyn_alb_roof_LCZ6"
        stream_var_name_roof(isturb_lcz7 -6) = "dyn_alb_roof_LCZ7"
        stream_var_name_roof(isturb_lcz8 -6) = "dyn_alb_roof_LCZ8"
        stream_var_name_roof(isturb_lcz9 -6) = "dyn_alb_roof_LCZ9"
        stream_var_name_roof(isturb_lcz10-6) = "dyn_alb_roof_LCZ10"
     end if
  
     ! Read urbanalbtvwall_streams namelist
     if (masterproc) then
        open( newunit=nu_nml, file=trim(NLFilename), status='old', iostat=nml_error )
        call find_nlgroup_name(nu_nml, 'urbanalbtvwall_streams', status=nml_error)
        if (nml_error == 0) then
           read(nu_nml, nml=urbanalbtvwall_streams,iostat=nml_error) 
           if (nml_error /= 0) then
              call endrun(msg='ERROR reading urbanalbtvwall_streams namelist'//errMsg(sourcefile, __LINE__))
           end if
        else
            call endrun(subname // ':: ERROR finding urbanalbtvwall_streams namelist')   
        end if
        close(nu_nml)
     endif
  
     call shr_mpi_bcast(stream_year_first_urbanalbtvwall  , mpicom)
     call shr_mpi_bcast(stream_year_last_urbanalbtvwall   , mpicom)
     call shr_mpi_bcast(model_year_align_urbanalbtvwall   , mpicom)
     call shr_mpi_bcast(stream_fldFileName_urbanalbtvwall , mpicom)
     call shr_mpi_bcast(stream_meshfile_urbanalbtvwall    , mpicom)
     call shr_mpi_bcast(urbanalbtvwall_tintalgo           , mpicom)
     
     if (masterproc) then
         write(iulog,*) ' '
         write(iulog,*) 'Attemping to read time varying urban wall albedo parameters......'
         write(iulog,'(a)') 'urbanalbtvwall_streams settings:'
         write(iulog,'(a,i8)') '  stream_year_first_urbanalbtvwall  = ',stream_year_first_urbanalbtvwall
         write(iulog,'(a,i8)') '  stream_year_last_urbanalbtvwall   = ',stream_year_last_urbanalbtvwall
         write(iulog,'(a,i8)') '  model_year_align_urbanalbtvwall   = ',model_year_align_urbanalbtvwall
         write(iulog,'(a,a)' ) '  stream_fldFileName_urbanalbtvwall = ',stream_fldFileName_urbanalbtvwall
         write(iulog,'(a,a)' ) '  stream_meshfile_urbanalbtvwall    = ',stream_meshfile_urbanalbtvwall
         write(iulog,'(a,a)' ) '  urbanalbtvwall_tintalgo           = ',urbanalbtvwall_tintalgo
         write(iulog,*) 'Read in urbanalbtvwall_streams namelist from:',trim(NLFilename)
         do n = stream_varname_MIN,stream_varname_MAX
            write(iulog,'(a,a)' ) '  stream_var_name_roof         = ',trim(stream_var_name_roof(n))
         end do
     endif
      
      call shr_strdata_init_from_inline(this%sdat_urbanalbtvwall,                  &
           my_task             = iam,                                              &
           logunit             = iulog,                                            &
           compname            = 'LND',                                            &
           model_clock         = model_clock,                                      &
           model_mesh          = mesh,                                             &
           stream_meshfile     = trim(stream_meshfile_urbanalbtvwall),             &
           stream_lev_dimname  = 'null',                                           &
           stream_mapalgo      = trim(urbanalbtvwallmapalgo),                      &
           stream_filenames    = (/trim(stream_fldfilename_urbanalbtvwall)/),      &
           stream_fldlistFile  = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_fldListModel = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_yearFirst    = stream_year_first_urbanalbtvwall,                 &
           stream_yearLast     = stream_year_last_urbanalbtvwall,                  &
           stream_yearAlign    = model_year_align_urbanalbtvwall,                  &
           stream_offset       = 0,                                                &
           stream_taxmode      = 'extend',                                         &
           stream_dtlimit      = 1.0e30_r8,                                        &
           stream_tintalgo     = urbanalbtvwall_tintalgo,                          &
           stream_name         = 'Urban time varying roof albedo data',            &
           rc                  = rc)
  
     if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
     end if
      
    end subroutine urbanalbtvwall_init
  
    !==============================================================================
   
    subroutine urbanalbtvwall_interp(this, bounds)
      ! !DESCRIPTION:
      ! Interpolate data stream information for urban time varying albedo.
      ! 
      ! !USES:
      use clm_time_manager  , only : get_curr_date
      use clm_instur        , only : urban_valid
      use dshr_methods_mod  , only : dshr_fldbun_getfldptr
      use dshr_strdata_mod  , only : shr_strdata_advance
      use shr_infnan_mod    , only : nan => shr_infnan_nan, assignment(=)
      ! 
      ! !ARGUMENTS:
      ! 
      class(urbanalbtv_type)           :: this
      type(bounds_type), intent(in)    :: bounds
      !
      ! !LOCAL VARIABLES:
      !
      logical :: found
      integer :: l, ig, g, ip, n, ib    
      integer :: year    ! year (0, ...) for nstep+1
      integer :: mon     ! month (1, ..., 12) for nstep+1
      integer :: day     ! day of month (1, ..., 31) for nstep+1
      integer :: sec     ! seconds into current date for nstep+1
      integer :: mcdate  ! Current model date (yyyymmdd)
      integer :: lindx   ! landunit index
      integer :: gindx   ! gridcell index
      integer :: lsize
      integer :: rc
      real(r8), pointer :: dataptr1d(:)
      real(r8), pointer :: dataptr2d(:,:)
      ! 
      !-----------------------------------------------------------------------
      ! 
      ! Advance sdat stream
      !
      call get_curr_date(year, mon, day, sec)
      !
      ! packing the date into an integer
      mcdate = year*10000 + mon*100 + day
  
      call shr_strdata_advance(this%sdat_urbanalbtvwall, ymd=mcdate, tod=sec, logunit=iulog, istr='hdmdyn', rc=rc)
      if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
      end if
      !
      ! Create 2d array for all stream variable data
      lsize = bounds%endg - bounds%begg + 1
      allocate(dataptr2d(lsize, stream_varname_MIN:stream_varname_MAX))
      do n = stream_varname_MIN,stream_varname_MAX
         call dshr_fldbun_getFldPtr(this%sdat_urbanalbtvwall%pstrm(1)%fldbun_model, trim(stream_var_name_wall(n)), &
              fldptr1=dataptr1d, rc=rc)
         if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
            call ESMF_Finalize(endflag=ESMF_END_ABORT)
         end if
         ! Note that the size of dataptr1d includes ocean points so it will be around 3x larger than lsize
         ! So an explicit loop is required here
         do g = 1,lsize
            dataptr2d(g,n) = dataptr1d(g)
         end do
      end do
  
      ! Determine this%tbuilding_max (and this%p_ac, if applicable) for all landunits
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            ! Note that since l is within [begl, endl] bounds, we can assume
            ! lun%gricell(l) is within [begg, endg]
            ig = lun%gridcell(l) - bounds%begg + 1
            do ib = 1,numrad 
               do n = stream_varname_MIN,stream_varname_MAX
                  if (stream_var_name_wall((lun%itype(l)-6)) == stream_var_name_wall(n)) then
                     this%dyn_alb_roof_dir(l,ib) = dataptr2d(ig,n)
                     this%dyn_alb_roof_dif(l,ib) = dataptr2d(ig,n)
                  end if
               end do
            end do 
         else
             do ib = 1,numrad
                this%dyn_alb_roof_dir(l,ib) = spval
                this%dyn_alb_roof_dif(l,ib) = spval  
             end do  
         end if
      end do
      deallocate(dataptr2d)
  
      ! Error check
      found = .false.
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            do g = bounds%begg,bounds%endg
               if (g == lun%gridcell(l)) exit
            end do
            ! Check for valid urban data
            do ib = 1,numrad
               if ( .not. urban_valid(g) .or. (this%dyn_alb_roof_dir(l,ib) <= 0._r8) .or. (this%dyn_alb_roof_dif(l,ib) <= 0._r8)) then
                  found = .true.
                  gindx = g
                  lindx = l
                  exit
               end if
            end do   
         end if
      end do
      if ( found ) then
         write(iulog,*)'ERROR: no valid urban data for g= ',gindx
         write(iulog,*)'landunit type:   ',lun%itype(lindx)
         write(iulog,*)'urban_valid:     ',urban_valid(gindx)
         write(iulog,*)'dyn_alb_roof_dir:  ',this%dyn_alb_roof_dir(lindx,:)
         write(iulog,*)'dyn_alb_roof_dif:  ',this%dyn_alb_roof_dif(lindx,:)
         call endrun(subgrid_index=lindx, subgrid_level=subgrid_level_landunit, &
              msg=errmsg(sourcefile, __LINE__))
      end if
  
    end subroutine urbanalbtvwall_interp
  
   !---------------------------------------------------------------------
   subroutine urbanalbtvimproad_init(this, bounds, NLFilename)
     !
     ! !DESCRIPTION:
     ! Initialize data stream information for urban time varying impervious road albedo
     !
     ! !USES:
     use clm_nlUtilsMod   , only : find_nlgroup_name
     use spmdMod          , only : masterproc, mpicom, iam
     use shr_mpi_mod      , only : shr_mpi_bcast
     use dshr_strdata_mod , only : shr_strdata_init_from_inline
     use lnd_comp_shr     , only : mesh, model_clock
     use clm_varctl       , only : use_lcz
     use landunit_varcon  , only : isturb_tbd, isturb_hd, isturb_md          
     use landunit_varcon  , only : isturb_lcz1, isturb_lcz2, isturb_lcz3, &
                                   isturb_lcz4, isturb_lcz5, isturb_lcz6, &
                                   isturb_lcz7, isturb_lcz8, isturb_lcz9, &
                                   isturb_lcz10
     !
     ! !ARGUMENTS:
     implicit none
     class(urbanalbtv_type)         :: this
     type(bounds_type), intent(in)  :: bounds
     character(len=*),  intent(in)  :: NLFilename   ! Namelist filename
     ! 
     ! !LOCAL VARIABLES:
     integer            :: n
     integer            :: stream_year_first_urbanalbtvimproad            ! first year in urban impervious road albedo tv stream to use
     integer            :: stream_year_last_urbanalbtvimproad             ! last year in urban impervious road albedo tv stream to use
     integer            :: model_year_align_urbanalbtvimproad             ! align stream_year_first_urbanalbtvimproad with this model year
     integer            :: nu_nml                                      ! unit for namelist file 
     integer            :: nml_error                                   ! namelist i/o error flag
     character(len=CL)  :: stream_fldFileName_urbanalbtvimproad           ! urban impervious road albedo time-varying streams filename
     character(len=FL)  :: stream_meshfile_urbanalbtvimproad              ! urban impervious road albedo time-varying mesh filename
     character(len=CL)  :: urbanalbtvimproadmapalgo = 'nn'                ! mapping alogrithm for urban ac
     character(len=CL)  :: urbanalbtvimproad_tintalgo = 'linear'          ! time interpolation alogrithm 
     integer            :: rc                                          ! error code
     character(*), parameter :: subName = "('urbanalbtvimproad_init')"
     !-----------------------------------------------------------------------
     namelist /urbanalbtvimproad_streams/       &
          stream_year_first_urbanalbtvimproad,  &  
          stream_year_last_urbanalbtvimproad,   &  
          model_year_align_urbanalbtvimproad,   &  
          urbanalbtvimproadmapalgo,             &  
          stream_fldFileName_urbanalbtvimproad, &   
          stream_meshfile_urbanalbtvimproad,    &   
          urbanalbtvimproad_tintalgo  
     !-----------------------------------------------------------------------       
     !               
     ! Default values for namelist
     stream_year_first_urbanalbtvimproad  = 1      ! first year in stream to use
     stream_year_last_urbanalbtvimproad   = 1      ! last  year in stream to use
     model_year_align_urbanalbtvimproad   = 1      ! align stream_year_first_urbanalbtvimproad with this model year
     stream_fldFileName_urbanalbtvimproad = ' '
     stream_meshfile_urbanalbtvimproad    = ' '
     
     ! create the field list for urban albedo fields
     if (.not. use_lcz) then 
        stream_var_name_roof(isturb_tbd -6) = "dyn_alb_roof_TBD"
        stream_var_name_roof(isturb_hd -6)  = "dyn_alb_roof_HD"
        stream_var_name_roof(isturb_md -6)  = "dyn_alb_roof_MD"   
     else
        stream_var_name_roof(isturb_lcz1 -6) = "dyn_alb_roof_LCZ1"
        stream_var_name_roof(isturb_lcz2 -6) = "dyn_alb_roof_LCZ2"
        stream_var_name_roof(isturb_lcz3 -6) = "dyn_alb_roof_LCZ3"
        stream_var_name_roof(isturb_lcz4 -6) = "dyn_alb_roof_LCZ4"
        stream_var_name_roof(isturb_lcz5 -6) = "dyn_alb_roof_LCZ5"
        stream_var_name_roof(isturb_lcz6 -6) = "dyn_alb_roof_LCZ6"
        stream_var_name_roof(isturb_lcz7 -6) = "dyn_alb_roof_LCZ7"
        stream_var_name_roof(isturb_lcz8 -6) = "dyn_alb_roof_LCZ8"
        stream_var_name_roof(isturb_lcz9 -6) = "dyn_alb_roof_LCZ9"
        stream_var_name_roof(isturb_lcz10-6) = "dyn_alb_roof_LCZ10"
     end if
  
     ! Read urbanalbtvimproad_streams namelist
     if (masterproc) then
        open( newunit=nu_nml, file=trim(NLFilename), status='old', iostat=nml_error )
        call find_nlgroup_name(nu_nml, 'urbanalbtvimproad_streams', status=nml_error)
        if (nml_error == 0) then
           read(nu_nml, nml=urbanalbtvimproad_streams,iostat=nml_error) 
           if (nml_error /= 0) then
              call endrun(msg='ERROR reading urbanalbtvimproad_streams namelist'//errMsg(sourcefile, __LINE__))
           end if
        else
            call endrun(subname // ':: ERROR finding urbanalbtvimproad_streams namelist')   
        end if
        close(nu_nml)
     endif
  
     call shr_mpi_bcast(stream_year_first_urbanalbtvimproad  , mpicom)
     call shr_mpi_bcast(stream_year_last_urbanalbtvimproad   , mpicom)
     call shr_mpi_bcast(model_year_align_urbanalbtvimproad   , mpicom)
     call shr_mpi_bcast(stream_fldFileName_urbanalbtvimproad , mpicom)
     call shr_mpi_bcast(stream_meshfile_urbanalbtvimproad    , mpicom)
     call shr_mpi_bcast(urbanalbtvimproad_tintalgo           , mpicom)
     
     if (masterproc) then
         write(iulog,*) ' '
         write(iulog,*) 'Attemping to read time varying urban impervious road albedo parameters......'
         write(iulog,'(a)') 'urbanalbtvimproad_streams settings:'
         write(iulog,'(a,i8)') '  stream_year_first_urbanalbtvimproad  = ',stream_year_first_urbanalbtvimproad
         write(iulog,'(a,i8)') '  stream_year_last_urbanalbtvimproad   = ',stream_year_last_urbanalbtvimproad
         write(iulog,'(a,i8)') '  model_year_align_urbanalbtvimproad   = ',model_year_align_urbanalbtvimproad
         write(iulog,'(a,a)' ) '  stream_fldFileName_urbanalbtvimproad = ',stream_fldFileName_urbanalbtvimproad
         write(iulog,'(a,a)' ) '  stream_meshfile_urbanalbtvimproad    = ',stream_meshfile_urbanalbtvimproad
         write(iulog,'(a,a)' ) '  urbanalbtvimproad_tintalgo           = ',urbanalbtvimproad_tintalgo
         write(iulog,*) 'Read in urbanalbtvimproad_streams namelist from:',trim(NLFilename)
         do n = stream_varname_MIN,stream_varname_MAX
            write(iulog,'(a,a)' ) '  stream_var_name_roof         = ',trim(stream_var_name_roof(n))
         end do
     endif
      
      call shr_strdata_init_from_inline(this%sdat_urbanalbtvimproad,                  &
           my_task             = iam,                                                 &
           logunit             = iulog,                                               &
           compname            = 'LND',                                               &
           model_clock         = model_clock,                                         &
           model_mesh          = mesh,                                                &
           stream_meshfile     = trim(stream_meshfile_urbanalbtvimproad),             &
           stream_lev_dimname  = 'null',                                              &
           stream_mapalgo      = trim(urbanalbtvimproadmapalgo),                      &
           stream_filenames    = (/trim(stream_fldfilename_urbanalbtvimproad)/),      &
           stream_fldlistFile  = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_fldListModel = stream_var_name_roof(stream_varname_MIN:stream_varname_MAX), &
           stream_yearFirst    = stream_year_first_urbanalbtvimproad,                 &
           stream_yearLast     = stream_year_last_urbanalbtvimproad,                  &
           stream_yearAlign    = model_year_align_urbanalbtvimproad,                  &
           stream_offset       = 0,                                                   &
           stream_taxmode      = 'extend',                                            &
           stream_dtlimit      = 1.0e30_r8,                                           &
           stream_tintalgo     = urbanalbtvimproad_tintalgo,                          &
           stream_name         = 'Urban time varying roof albedo data',               &
           rc                  = rc)
  
     if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
     end if
      
    end subroutine urbanalbtvimproad_init
  
    !==============================================================================
   
    subroutine urbanalbtvimproad_interp(this, bounds)
      ! !DESCRIPTION:
      ! Interpolate data stream information for urban time varying albedo.
      ! 
      ! !USES:
      use clm_time_manager  , only : get_curr_date
      use clm_instur        , only : urban_valid
      use dshr_methods_mod  , only : dshr_fldbun_getfldptr
      use dshr_strdata_mod  , only : shr_strdata_advance
      use shr_infnan_mod    , only : nan => shr_infnan_nan, assignment(=)
      ! 
      ! !ARGUMENTS:
      ! 
      class(urbanalbtv_type)           :: this
      type(bounds_type), intent(in)    :: bounds
      !
      ! !LOCAL VARIABLES:
      !
      logical :: found
      integer :: l, ig, g, ip, n, ib    
      integer :: year    ! year (0, ...) for nstep+1
      integer :: mon     ! month (1, ..., 12) for nstep+1
      integer :: day     ! day of month (1, ..., 31) for nstep+1
      integer :: sec     ! seconds into current date for nstep+1
      integer :: mcdate  ! Current model date (yyyymmdd)
      integer :: lindx   ! landunit index
      integer :: gindx   ! gridcell index
      integer :: lsize
      integer :: rc
      real(r8), pointer :: dataptr1d(:)
      real(r8), pointer :: dataptr2d(:,:)
      ! 
      !-----------------------------------------------------------------------
      ! 
      ! Advance sdat stream
      !
      call get_curr_date(year, mon, day, sec)
      !
      ! packing the date into an integer
      mcdate = year*10000 + mon*100 + day
  
      call shr_strdata_advance(this%sdat_urbanalbtvimproad, ymd=mcdate, tod=sec, logunit=iulog, istr='hdmdyn', rc=rc)
      if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
         call ESMF_Finalize(endflag=ESMF_END_ABORT)
      end if
      !
      ! Create 2d array for all stream variable data
      lsize = bounds%endg - bounds%begg + 1
      allocate(dataptr2d(lsize, stream_varname_MIN:stream_varname_MAX))
      do n = stream_varname_MIN,stream_varname_MAX
         call dshr_fldbun_getFldPtr(this%sdat_urbanalbtvimproad%pstrm(1)%fldbun_model, trim(stream_var_name_improad(n)), &
              fldptr1=dataptr1d, rc=rc)
         if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, line=__LINE__, file=__FILE__)) then
            call ESMF_Finalize(endflag=ESMF_END_ABORT)
         end if
         ! Note that the size of dataptr1d includes ocean points so it will be around 3x larger than lsize
         ! So an explicit loop is required here
         do g = 1,lsize
            dataptr2d(g,n) = dataptr1d(g)
         end do
      end do
  
      ! Determine this%tbuilding_max (and this%p_ac, if applicable) for all landunits
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            ! Note that since l is within [begl, endl] bounds, we can assume
            ! lun%gricell(l) is within [begg, endg]
            ig = lun%gridcell(l) - bounds%begg + 1
            do ib = 1,numrad 
               do n = stream_varname_MIN,stream_varname_MAX
                  if (stream_var_name_improad((lun%itype(l)-6)) == stream_var_name_improad(n)) then
                     this%dyn_alb_roof_dir(l,ib) = dataptr2d(ig,n)
                     this%dyn_alb_roof_dif(l,ib) = dataptr2d(ig,n)
                  end if
               end do
            end do 
         else
             do ib = 1,numrad
                this%dyn_alb_roof_dir(l,ib) = spval
                this%dyn_alb_roof_dif(l,ib) = spval  
             end do  
         end if
      end do
      deallocate(dataptr2d)
  
      ! Error check
      found = .false.
      do l = bounds%begl,bounds%endl
         if (lun%urbpoi(l)) then
            do g = bounds%begg,bounds%endg
               if (g == lun%gridcell(l)) exit
            end do
            ! Check for valid urban data
            do ib = 1,numrad
               if ( .not. urban_valid(g) .or. (this%dyn_alb_roof_dir(l,ib) <= 0._r8) .or. (this%dyn_alb_roof_dif(l,ib) <= 0._r8)) then
                  found = .true.
                  gindx = g
                  lindx = l
                  exit
               end if
            end do   
         end if
      end do
      if ( found ) then
         write(iulog,*)'ERROR: no valid urban data for g= ',gindx
         write(iulog,*)'landunit type:   ',lun%itype(lindx)
         write(iulog,*)'urban_valid:     ',urban_valid(gindx)
         write(iulog,*)'dyn_alb_roof_dir:  ',this%dyn_alb_roof_dir(lindx,:)
         write(iulog,*)'dyn_alb_roof_dif:  ',this%dyn_alb_roof_dif(lindx,:)
         call endrun(subgrid_index=lindx, subgrid_level=subgrid_level_landunit, &
              msg=errmsg(sourcefile, __LINE__))
      end if
  
    end subroutine urbanalbtvimproad_interp
  
  end module UrbanDynAlbMod
  ```

  

- Modify `bld/CLMBuildNamelist.pm` at around Line 5191 by adding `urbanalbtvroof_streams urbanalbtvimproad_streams urbanalbtvwall_streams`:

  - From:

    ```perl
      @groups = qw(clm_inparm ndepdyn_nml popd_streams urbantv_streams light_streams
                   soil_moisture_streams lai_streams atm2lnd_inparm lnd2atm_inparm clm_canopyhydrology_inparm cnphenology
                   cropcal_streams
                   clm_soilhydrology_inparm dynamic_subgrid cnvegcarbonstate
                   finidat_consistency_checks dynpft_consistency_checks
                   clm_initinterp_inparm century_soilbgcdecompcascade
                   soilhydrology_inparm luna friction_velocity mineral_nitrogen_dynamics
                   soilwater_movement_inparm rooting_profile_inparm
                   soil_resis_inparm  bgc_shared canopyfluxes_inparm aerosol
                   clmu_inparm clm_soilstate_inparm clm_nitrogen clm_snowhydrology_inparm hillslope_hydrology_inparm hillslope_properties_inparm
                   cnprecision_inparm clm_glacier_behavior crop_inparm irrigation_inparm
                   surfacealbedo_inparm water_tracers_inparm tillage_inparm);
    ```

  - to:

    ```perl
      @groups = qw(clm_inparm ndepdyn_nml popd_streams urbantv_streams light_streams
                   urbanalbtvroof_streams urbanalbtvimproad_streams urbanalbtvwall_streams
                   soil_moisture_streams lai_streams atm2lnd_inparm lnd2atm_inparm clm_canopyhydrology_inparm cnphenology
                   cropcal_streams
                   clm_soilhydrology_inparm dynamic_subgrid cnvegcarbonstate
                   finidat_consistency_checks dynpft_consistency_checks
                   clm_initinterp_inparm century_soilbgcdecompcascade
                   soilhydrology_inparm luna friction_velocity mineral_nitrogen_dynamics
                   soilwater_movement_inparm rooting_profile_inparm
                   soil_resis_inparm  bgc_shared canopyfluxes_inparm aerosol
                   clmu_inparm clm_soilstate_inparm clm_nitrogen clm_snowhydrology_inparm hillslope_hydrology_inparm hillslope_properties_inparm
                   cnprecision_inparm clm_glacier_behavior crop_inparm irrigation_inparm
                   surfacealbedo_inparm water_tracers_inparm tillage_inparm);
    ```

- Modify `bld/namelist_files/namelist_defaults_ctsm.xml` at the bottom line:

  - From:

    ```xml
    <use_original_tillage_phases>.false.</use_original_tillage_phases>
    <max_tillage_depth>0.26d00</max_tillage_depth>
    </namelist_defaults>
    ```

  - To:

    ```xml
    <use_original_tillage_phases>.false.</use_original_tillage_phases>
    <max_tillage_depth>0.26d00</max_tillage_depth>
    <!--!YS-->
    <!-- Default urban albedo -->
    <transient_urbanalbedo_roof>.false.</transient_urbanalbedo_roof>
    <transient_urbanalbedo_improad>.false.</transient_urbanalbedo_improad>
    <transient_urbanalbedo_wall>.false.</transient_urbanalbedo_wall>
    </namelist_defaults>
    ```

    - This is to disable functionalities by default and enable them manually by adding, for example, `transient_urbanalbedo_roof = .true.` to the `user_nl_clm`.

- Modify `bld/namelist_files/namelist_definition_ctsm.xml` by adding:

  ```xml
  <!-- ========================================================================================  -->
  <!-- !YS Namelist options related to the transient urban albedo                                          -->
  <!-- ========================================================================================  -->
  <entry id="transient_urbanalbedo_roof" type="logical" category="clm_physics"
         group="clmu_inparm" valid_values="" value=".false." >
  If TRUE, time-varying urban roof albedo will be activated (Currently NOT implemented).
  </entry>
  
  <entry id="transient_urbanalbedo_improad" type="logical" category="clm_physics"
         group="clmu_inparm" valid_values="" value=".false." >
  If TRUE, time-varying urban improad albedo will be activated (Currently NOT implemented).
  </entry>
  
  <entry id="transient_urbanalbedo_wall" type="logical" category="clm_physics"
         group="clmu_inparm" valid_values="" value=".false." >
  If TRUE, time-varying urban wall albedo will be activated (Currently NOT implemented).
  </entry>
  
  <!-- ========================================================================================  -->
  <!-- urbanalbtv*_streams Namelist (when CLM4_5/CLM5_0 is active)                                   -->
  <!-- ========================================================================================  -->
  
  <!-- urban time varying roof albedo-->
  <entry id="stream_year_first_urbanalbtvroof" type="integer" category="datasets"
         group="urbanalbtvroof_streams" valid_values="" >
  First year to loop over for urban time varying roof albedo
  </entry>
  
  <entry id="stream_year_last_urbanalbtvroof" type="integer" category="datasets"
         group="urbanalbtvroof_streams" valid_values="" >
  Last year to loop over for urban time varying roof albedo
  </entry>
  
  <entry id="model_year_align_urbanalbtvroof" type="integer" category="datasets"
         group="urbanalbtvroof_streams" valid_values="" >
  Simulation year that aligns with stream_year_first_urbanalbtvroof value
  </entry>
  
  <entry id="stream_fldfilename_urbanalbtvroof" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvroof_streams" valid_values="" >
  Filename of input stream data for time varying urban roof albedo
  </entry>
  
  <entry id="stream_meshfile_urbanalbtvroof" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvroof_streams" valid_values="" >
  Mesh filename of input stream data for time varying urban roof albedo
  </entry>
  
  <entry id="urbanalbtvroof_tintalgo" type="char*80" category="datasets"
         group="urbanalbtvroof_streams" valid_values="linear,nearest,lower,upper" >
  Time interpolation method to use with urban time varying roof albedo streams
  </entry>
  
  <entry id="urbanalbtvroofmapalgo" type="char*256" category="datasets"
         group="urbanalbtvroof_streams" valid_values="bilinear,nn,nnoni,nnonj,spval,copy" >
  Mapping method from urban time varying roof albedo file to the model resolution
      bilinear = bilinear interpolation
      nn       = nearest neighbor
      nnoni    = nearest neighbor on the "i" (longitude) axis
      nnonj    = nearest neighbor on the "j" (latitude) axis
      spval    = set to special value
      copy     = copy using the same indices
  </entry>
  
  <!-- urban time varying improad albedo-->
  <entry id="stream_year_first_urbanalbtvimproad" type="integer" category="datasets"
         group="urbanalbtvimproad_streams" valid_values="" >
  First year to loop over for urban time varying improad albedo
  </entry>
  
  <entry id="stream_year_last_urbanalbtvimproad" type="integer" category="datasets"
         group="urbanalbtvimproad_streams" valid_values="" >
  Last year to loop over for urban time varying improad albedo
  </entry>
  
  <entry id="model_year_align_urbanalbtvimproad" type="integer" category="datasets"
         group="urbanalbtvimproad_streams" valid_values="" >
  Simulation year that aligns with stream_year_first_urbanalbtvimproad value
  </entry>
  
  <entry id="stream_fldfilename_urbanalbtvimproad" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvimproad_streams" valid_values="" >
  Filename of input stream data for time varying urban improad albedo
  </entry>
  
  <entry id="stream_meshfile_urbanalbtvimproad" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvimproad_streams" valid_values="" >
  mesh filename of input stream data for time varying urban improad albedo
  </entry>
  
  <entry id="urbanalbtvimproad_tintalgo" type="char*80" category="datasets"
         group="urbanalbtvimproad_streams" valid_values="linear,nearest,lower,upper" >
  Time interpolation method to use with urban time varying improad albedo streams
  </entry>
  
  <entry id="urbanalbtvimproadmapalgo" type="char*256" category="datasets"
         group="urbanalbtvimproad_streams" valid_values="bilinear,nn,nnoni,nnonj,spval,copy" >
  Mapping method from urban time varying improad albedo file to the model resolution
      bilinear = bilinear interpolation
      nn       = nearest neighbor
      nnoni    = nearest neighbor on the "i" (longitude) axis
      nnonj    = nearest neighbor on the "j" (latitude) axis
      spval    = set to special value
      copy     = copy using the same indices
  </entry>
  
  <!-- urban time varying wall albedo-->
  <entry id="stream_year_first_urbanalbtvwall" type="integer" category="datasets"
         group="urbanalbtvwall_streams" valid_values="" >
  First year to loop over for urban time varying wall albedo
  </entry>
  
  <entry id="stream_year_last_urbanalbtvwall" type="integer" category="datasets"
         group="urbanalbtvwall_streams" valid_values="" >
  Last year to loop over for urban time varying wall albedo
  </entry>
  
  <entry id="model_year_align_urbanalbtvwall" type="integer" category="datasets"
         group="urbanalbtvwall_streams" valid_values="" >
  Simulation year that aligns with stream_year_first_urbanalbtvwall value
  </entry>
  
  <entry id="stream_fldfilename_urbanalbtvwall" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvwall_streams" valid_values="" >
  Filename of input stream data for time varying urban wall albedo
  </entry>
  
  <entry id="stream_meshfile_urbanalbtvwall" type="char*256" category="datasets"
         input_pathname="abs" group="urbanalbtvwall_streams" valid_values="" >
  mesh filename of input stream data for time varying urban wall albedo
  </entry>
  
  <entry id="urbanalbtvwall_tintalgo" type="char*80" category="datasets"
         group="urbanalbtvwall_streams" valid_values="linear,nearest,lower,upper" >
  Time interpolation method to use with urban time varying wall albedo streams
  </entry>
  
  <entry id="urbanalbtvwallmapalgo" type="char*256" category="datasets"
         group="urbanalbtvwall_streams" valid_values="bilinear,nn,nnoni,nnonj,spval,copy" >
  Mapping method from urban time varying wall albedo file to the model resolution
      bilinear = bilinear interpolation
      nn       = nearest neighbor
      nnoni    = nearest neighbor on the "i" (longitude) axis
      nnonj    = nearest neighbor on the "j" (latitude) axis
      spval    = set to special value
      copy     = copy using the same indices
  </entry>
  ```

- Modify `src/biogeophys/UrbanAlbedoMod.F90`

  - After around Line 24 `use PatchType         , only : patch `, add:

    ```fortran
    !YS
      use UrbanDynAlbMod    , only : urbanalbtv_type    
    !YS   
    ```

  - After around Line 51, change

    - From:

      ```fortran
        subroutine UrbanAlbedo (bounds, num_urbanl, filter_urbanl, &
             num_urbanc, filter_urbanc, num_urbanp, filter_urbanp, &
             waterstatebulk_inst, waterdiagnosticbulk_inst, urbanparams_inst, solarabs_inst, surfalb_inst) 
             waterstatebulk_inst, waterdiagnosticbulk_inst, urbanparams_inst, solarabs_inst, surfalb_inst) 
      ```

    - To:

      ```fortran
        subroutine UrbanAlbedo (bounds, num_urbanl, filter_urbanl, &
             num_urbanc, filter_urbanc, num_urbanp, filter_urbanp, &
             waterstatebulk_inst, waterdiagnosticbulk_inst, urbanparams_inst, solarabs_inst, surfalb_inst) 
             waterstatebulk_inst, waterdiagnosticbulk_inst, urbanparams_inst, solarabs_inst, surfalb_inst, &
      !YS
             urbanalbtv_inst)
      !YS  
      ```

  - After around Line 71 `use column_varcon , only : icol_road_perv, icol_road_imperv`, add:

    ```fortran
    !YS
        use clm_varctl    , only : transient_urbanalbedo_roof, transient_urbanalbedo_improad, transient_urbanalbedo_wall
    !YS  
    ```

  - After around Line 88 `type(surfalb_type)     , intent(inout) :: surfalb_inst`, add:

    ```fortran
    !YS
        type(urbanalbtv_type)  , intent(in) :: urbanalbtv_inst
    !YS  
    ```

  - After around Line 133 `real(r8) :: sref_perroad_dif   (bounds%begl:bounds%endl, numrad) ! diffuse solar reflected by pervious road per unit ground area per unit incident flux  `, add:

    ```bash
    !YS
        real(r8) :: alb_roof_dir (bounds%begl:bounds%endl, numrad)
        real(r8) :: alb_roof_dif (bounds%begl:bounds%endl, numrad)
        real(r8) :: alb_wall_dir (bounds%begl:bounds%endl, numrad)
        real(r8) :: alb_wall_dif (bounds%begl:bounds%endl, numrad)
        real(r8) :: alb_improad_dir (bounds%begl:bounds%endl, numrad)
        real(r8) :: alb_improad_dif (bounds%begl:bounds%endl, numrad)
    !YS  
    ```

  - After around Line 134, modify

    - From:

      ```fortran
               alb_roof_dir       => urbanparams_inst%alb_roof_dir        , & ! Output: [real(r8) (:,:) ]  direct roof albedo                              
               alb_roof_dif       => urbanparams_inst%alb_roof_dif        , & ! Output: [real(r8) (:,:) ]  diffuse roof albedo                             
               alb_improad_dir    => urbanparams_inst%alb_improad_dir     , & ! Output: [real(r8) (:,:) ]  direct impervious road albedo                   
               alb_improad_dif    => urbanparams_inst%alb_improad_dif     , & ! Output: [real(r8) (:,:) ]  diffuse imprevious road albedo 
                        alb_perroad_dir    => urbanparams_inst%alb_perroad_dir     , & ! Output: [real(r8) (:,:) ]  direct pervious road albedo                     
               alb_perroad_dif    => urbanparams_inst%alb_perroad_dif     , & ! Output: [real(r8) (:,:) ]  diffuse pervious road albedo                    
               alb_wall_dir       => urbanparams_inst%alb_wall_dir        , & ! Output: [real(r8) (:,:) ]  direct wall albedo                              
               alb_wall_dif       => urbanparams_inst%alb_wall_dif        , & ! Output: [real(r8) (:,:) ]  diffuse wall albedo    
      ```

    - To:

      ```fortran
                  
      !YS         alb_roof_dir       => urbanparams_inst%alb_roof_dir        , & ! Output: [real(r8) (:,:) ]  direct roof albedo                              
      !YS         alb_roof_dif       => urbanparams_inst%alb_roof_dif        , & ! Output: [real(r8) (:,:) ]  diffuse roof albedo                             
      !YS         alb_improad_dir    => urbanparams_inst%alb_improad_dir     , & ! Output: [real(r8) (:,:) ]  direct impervious road albedo                   
      !YS         alb_improad_dif    => urbanparams_inst%alb_improad_dif     , & ! Output: [real(r8) (:,:) ]  diffuse imprevious road albedo                  
               alb_perroad_dir    => urbanparams_inst%alb_perroad_dir     , & ! Output: [real(r8) (:,:) ]  direct pervious road albedo                     
               alb_perroad_dif    => urbanparams_inst%alb_perroad_dif     , & ! Output: [real(r8) (:,:) ]  diffuse pervious road albedo                                              
              
      !YS         alb_wall_dir       => urbanparams_inst%alb_wall_dir        , & ! Output: [real(r8) (:,:) ]  direct wall albedo                              
      !YS         alb_wall_dif       => urbanparams_inst%alb_wall_dif        , & ! Output: [real(r8) (:,:) ]  diffuse wall albedo                             
      !YS
               con_alb_roof_dir       => urbanparams_inst%alb_roof_dir        , &    ! Input: [real(r8) (:,:) ]  direct roof albedo (constant)                             
               con_alb_roof_dif       => urbanparams_inst%alb_roof_dif        , &                                      
               con_alb_wall_dir       => urbanparams_inst%alb_wall_dir        , &    ! Input: [real(r8) (:,:) ]  direct wall albedo (constant)                   
               con_alb_wall_dif       => urbanparams_inst%alb_wall_dif        , &
               con_alb_improad_dif    => urbanparams_inst%alb_improad_dif     , &    ! Input: [real(r8) (:,:) ]  direct impervious road albedo (constant)
               con_alb_improad_dir    => urbanparams_inst%alb_improad_dir     , &
               dyn_alb_roof_dir       => urbanalbtv_inst%dyn_alb_roof_dir     , &    ! Output: [real(r8) (:,:) ]  direct roof albedo (transient)                          
               dyn_alb_roof_dif       => urbanalbtv_inst%dyn_alb_roof_dif     , &
               dyn_alb_improad_dir    => urbanalbtv_inst%dyn_alb_improad_dir  , &    ! Output: [real(r8) (:,:) ]  direct improad albedo (transient)                                
               dyn_alb_improad_dif    => urbanalbtv_inst%dyn_alb_improad_dif  , &
               dyn_alb_wall_dir       => urbanalbtv_inst%dyn_alb_wall_dir     , &    ! Output: [real(r8) (:,:) ]  direct wall albedo (transient)                              
               dyn_alb_wall_dif       => urbanalbtv_inst%dyn_alb_wall_dif     , &
      !YS   
      ```

  - After around Line 230, add:

    ```fortran
    !YS
          do ib = 1, numrad
             do fl = 1,num_urbanl
                l = filter_urbanl(fl)
                if (.not. transient_urbanalbedo_roof) then
                   alb_roof_dir(l,ib) = con_alb_roof_dir(l,ib)
                   alb_roof_dif(l,ib) = con_alb_roof_dif(l,ib)
                else
                   alb_roof_dir(l,ib) = dyn_alb_roof_dir(l,ib)
                   alb_roof_dif(l,ib) = dyn_alb_roof_dif(l,ib)   
                end if
                
                if (.not. transient_urbanalbedo_wall) then
                   alb_wall_dir(l,ib) = con_alb_wall_dir(l,ib)
                   alb_wall_dif(l,ib) = con_alb_wall_dif(l,ib)
                else
                   alb_wall_dir(l,ib) = dyn_alb_wall_dir(l,ib)
                   alb_wall_dif(l,ib) = dyn_alb_wall_dif(l,ib)   
                end if
                
                if (.not. transient_urbanalbedo_improad) then
                   alb_improad_dir(l,ib) = con_alb_improad_dir(l,ib)
                   alb_improad_dif(l,ib) = con_alb_improad_dif(l,ib)
                else
                   alb_improad_dir(l,ib) = dyn_alb_improad_dir(l,ib)
                   alb_improad_dif(l,ib) = dyn_alb_improad_dif(l,ib)   
                end if 
             end do
          end do
    !YS
    ```

- Modify `src/biogeophys/UrbanParamsType.F90`:

  - After around Line 105 `logical, public                      :: urban_traffic = .false.     ! urban traffic fluxes`, add:

    ```fortran
    !YS   
      logical, public                      :: transient_urbanalbedo_roof    = .false.
      logical, public                      :: transient_urbanalbedo_improad = .false.
      logical, public                      :: transient_urbanalbedo_wall    = .false.
    !YS  
    ```

  - After around Line 851, change

    - From:

      ```fortran
      namelist / clmu_inparm / urban_hac, urban_explicit_ac, urban_traffic, building_temp_method
      ```

    - To:

      ```fortran
          namelist / clmu_inparm / urban_hac, urban_explicit_ac, urban_traffic, building_temp_method, &
      !YS
                                   transient_urbanalbedo_roof, transient_urbanalbedo_improad, transient_urbanalbedo_wall
      !YS 
      ```

      

  - After around Line 888, add:

    ```fortran
    !YS
        call shr_mpi_bcast(transient_urbanalbedo_roof, mpicom)
        call shr_mpi_bcast(transient_urbanalbedo_wall, mpicom)
        call shr_mpi_bcast(transient_urbanalbedo_improad, mpicom)
    !YS
    ```

- Modify `src/main/clm_driver.F90`

  - After around Line 85 `use SoilBiogeochemDecompCascadeConType , only : no_soil_decomp, decomp_method`, add:

    ```fortran
    !YS
      use UrbanDynAlbMod         , only : urbanalbtv_type
      use clm_varctl             , only : transient_urbanalbedo_roof
      use clm_varctl             , only : transient_urbanalbedo_improad
      use clm_varctl             , only : transient_urbanalbedo_wall
    !YS  
    ```

  - After around Line 474 `call urbantv_inst%urbantv_interp(bounds_proc)`, add:

    ```fortran
    !YS
        ! Get time varying urban albedo
        if (transient_urbanalbedo_roof) then
           call urbanalbtv_inst%urbanalbtvroof_interp(bounds_proc)
        end if
        
        if (transient_urbanalbedo_improad) then
           call urbanalbtv_inst%urbanalbtvimproad_interp(bounds_proc)
        end if   
        
        if (transient_urbanalbedo_wall) then
           call urbanalbtv_inst%urbanalbtvwall_interp(bounds_proc)
        end if
    !YS
    ```

  - At around Line 1262, change

    - From:

      ```fortran
                        water_inst%waterstatebulk_inst, &
                        water_inst%waterdiagnosticbulk_inst, &
                        urbanparams_inst,         &
                        solarabs_inst, surfalb_inst)
      ```

    - To:

      ```fortran
                        water_inst%waterstatebulk_inst, &
                        water_inst%waterdiagnosticbulk_inst, &
                        urbanparams_inst,         &
                        solarabs_inst, surfalb_inst)
                        solarabs_inst, surfalb_inst,         &
      !YS
                        urbanalbtv_inst)
      !YS
      ```

- Modify `src/main/clm_instMod.F90`

  - After Line 93 `use SoilWaterMovementMod            , only : use_aquifer_layer`, add

    ```fortran
    !YS
      use clm_varctl                      , only : transient_urbanalbedo_roof
      use clm_varctl                      , only : transient_urbanalbedo_improad
      use clm_varctl                      , only : transient_urbanalbedo_wall
      use UrbanDynAlbMod                  , only : urbanalbtv_type
    !YS 
    ```

  - After around Line 168 `type(hlm_fates_interface_type), public  :: clm_fates`, add

    ```fortran
    !YS
      type(urbanalbtv_type),public            :: urbanalbtv_inst
    !YS
    ```

  - After around Line 282 `call urbantv_inst%Init(bounds, NLFilename)`, add

    ```fortran
    !YS
        ! Initialize urban time varying albedo
        if (transient_urbanalbedo_roof .or. transient_urbanalbedo_wall .or. transient_urbanalbedo_improad) then
           call urbanalbtv_inst%dynAlbinit(bounds)
        end if
    !YS
    ```

- Modify `src/main/clm_varctl.F90`

  - After around Line 413 `logical, public :: use_biomass_heat_storage = .false. ! true => include biomass heat storage in canopy energy budget`, add

    ```fortran
    
    !YS  
      !----------------------------------------------------------
      ! urban landunit based on LCZs
      !----------------------------------------------------------
      
      logical, public :: use_lcz = .false.
      
      !----------------------------------------------------------
      ! dynamic urban albedo streams
      !----------------------------------------------------------
    
      logical, public :: transient_urbanalbedo_roof = .false.    ! true => use dynamic urban roof albedo streams in UrbanParamsType.F90
      logical, public :: transient_urbanalbedo_improad = .false. ! true => use dynamic urban improad albedo streams in UrbanParamsType.F90
      logical, public :: transient_urbanalbedo_wall = .false.    ! true => use dynamic urban wall albedo streams in UrbanParamsType.F90
    !YS  
    ```

    
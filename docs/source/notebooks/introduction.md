# 1 New Model Functionalities

## 1.1 Improving Urban Land Surface Representation

### Representing urban LCZ land cover in CESM (CESM-LCZ)

- Sun, Y., et al. (2025). Enhancing global-scale urban land cover representation using local climate zones in the Community Earth System Model. *Journal of Advances in Modeling Earth Systems*, 17(11), e2025MS004934. [10.1029/2025MS004934](https://doi.org/10.1029/2025MS004934)
  - [GitHub Repository](https://github.com/envdes/code_CESM_LCZ)
  
  - [Simulation Input and Output Data & Job Scripts](https://doi.org/10.6084/m9.figshare.30665966)
  
  - Presentation: [21st AOGS](https://yuansun-uom.github.io/files/Yuan_Sun_AOGS_poster.png)*, [CESM 2025 Winter Group Meeting](https://www.cesm.ucar.edu/sites/default/files/2025-02/2025-cesm-lmwgbgcwg-ysun.pdf), [AMS 2026](https://yuansun-uom.github.io/files/Yuan_Sun_AMS26_poster.pdf)**
  
    *Best Student Poster Award
  
    **Third Place Best Urban Student Poster Presentation Award 
  
- Sun, Y., et al. (2026). 

  - Presentation: [31st CESM Workshop](https://www.cesm.ucar.edu/sites/default/files/2026-06/2026cesmworkshopsun.pdf)

- [CESM-LCZ **User Guide**](projects/lcz/index.rst)



## 1.2 Explicitly Parameterizing Urban Physical Processes

### Modeling urban traffic heat flux in CESM (CESM-Traffic)

- Sun, Y., et al. (2026). Modeling urban traffic heat flux in the Community Earth System Model: Formulation and validation for two test sites. *Journal of Advances in Modeling Earth Systems*, 18(4), e2025MS005435. [10.1029/2025MS005435](https://doi.org/10.1029/2025MS005435)
  - [GitHub Repository](https://github.com/envdes/code_CLMU_traffic)
  - [(Open Access) Simulation Input and Output Data & Job Scripts](https://doi.org/10.6084/m9.figshare.31891603)
  - Presentation: [30th CESM Workshop](https://www.cesm.ucar.edu/sites/default/files/2025-06/2025cesmsun.pdf), [EGU26]()
  
- [CESM-Traffic **User Guide**](projects/traffic/index.rst)

## 1.3 Incorporating Adaptation-oriented Process

### Prescribing transient urban albedo in CESM (CESM-TranUrbAlb)

-  Sun, Y., et al. (2024). Improving urban climate adaptation modelling in the Community Earth System Model (CESM) through transient urban surface albedo representation. *Journal of Advances in Modeling Earth Systems*, 16(12), e2024MS004380. [10.1029/2024MS004380](https://doi.org/10.1029/2024MS004380)
  - [GitHub Repository](https://github.com/envdes/code_DynamicUrbanAlbedo)
  - [Simulation Input and Output Data & Job Scripts](https://doi.org/10.48420/27867357)
  
  - Presentation: [29th CESM Workshop](https://www.cesm.ucar.edu/sites/default/files/2024-06/2024cesmlmwgsun.pdf), [12th ICUC](https://yuansun-uom.github.io/files/Yuan_Sun_ICUC12-33_slides.pdf)
-  [CESM-TranUrbAlb **User Guide**](projects/transient_urban_albedo/index.rst)

## 1.4 Enhancing Model Scalability

### Coupling WRF and CTSM (WRF-CTSM)

- Preprint "Advancing CLMU for regional climate simulations through WRF coupling: intercomparison with NOAH–SLUCM." [10.31223/X5MT9P](https://doi.org/10.31223/X5MT9P)
  - [GitHub Repository](https://github.com/envdes/code_WRF-CLMU)
  - Presentation: [CESM 2026 Winter Group Meeting]()
- [WRF-CTSM **User Guide**](projects/wrf-ctsm/index.rst)



# 2 Model Applications

## 2.1 Assessing Urban Climate Impact

### Transient Urban Land Representation

- Sun, Y., et al. (2026). Linking urban population exposure to heatwaves with land cover change across the UK. *Sustainable Cities and Society*. 144, 107349. [10.1016/j.scs.2026.107349](https://doi.org/10.1016/j.scs.2026.107349)
  - [GitHub Repository](https://github.com/envdes/code_CLMU_UK_2000_2014)
  - [Simulation Input and Output Data & Job Scripts](https://doi.org/10.48420/31996764)

## 2.2 Evaluating Urban Climate Adaptation Strategies

### WRF-CTSM ＋ TranUrbAlb

- Preprint "."
  -  [GitHub Repository]()



# 3 Support

## 3.1 Useful Links

- GitHub Repository
  - [CESM](https://github.com/ESCOMP/CESM)
  - [CTSM](https://github.com/ESCOMP/CTSM)
  - [WRF](https://github.com/wrf-model/WRF)
  
- User Guide
  - [WPS User Guide](https://www2.mmm.ucar.edu/wrf/users/wrf_users_guide/build/html/wps.html)
  
  - [WRF User Guide](https://www2.mmm.ucar.edu/wrf/users/wrf_users_guide/build/html/index.html)
  
  - [CTSM documentation](https://escomp.github.io/CTSM/release-clm5.0/index.html#)
  
    - [CLM5.0 User's Guide](https://escomp.github.io/CTSM/release-clm5.0/users_guide/index.html)
  
    - [CLM Technical Note](https://escomp.github.io/CTSM/release-clm5.0/tech_note/index.html)
  
    - [Technical Description of an Urban Parameterization for the Community Land Model (CLMU)](https://doi.org/10.5065/D6K35RM9)
  
      - [Webpage version with modifications](technotes/CLMU/index.rst)
  
  - [CTSM-LILAC user guide](https://escomp.github.io/CTSM/lilac/index.html)
- Technical Note
  - [Technical Description of an Urban Parameterization for the Community Land Model (CLMU)](https://doi.org/10.5065/D6K35RM9)
  
  - [Technical Description of version 5.0 of the Community Land Model (CLM)](https://files.cesm.ucar.edu/models/clm/5.0/CLM50_Tech_Note.pdf)
  
  - [A Description of the Advanced Research WRF Model Version 4](https://doi.org/10.5065/1dfh-6p97)
- Tutorial
  - WRF-CTSM: [Using CTSM with WRF](https://escomp.github.io/CTSM/lilac/specific-atm-models/wrf.html), [WRF-CTSM on the SIGMA2 HPC](https://metos-uio.github.io/CTSM-Norway-Documentation/wrf-ctsm/)

- Forum
  - [WRF & MPAS-A Support Forum](https://forum.mmm.ucar.edu)
  - [DiscussCESM Forums](https://bb.cgd.ucar.edu/cesm/)



## 3.2 Inquiry For Help & Collaboration

- Please create an [Issues](https://github.com/YuanSun-UoM/esm-dev/issues) and [Discussions](https://github.com/YuanSun-UoM/esm-dev/discussions). The author will try to respond as soon as possible.
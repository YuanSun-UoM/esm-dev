#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'esmf-8_8_1.sh' > './log/esmf-8_8_1.log' 2>&1
# screen -S install_esmf
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=esmf
APPVER=8.8.1
COMPILER=gcc
APP=8_8_1
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
ESMFDIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
PNETCDFDIR=${INROOT}/${COMPILER}/pnetcdf/1.12.3
NETCDFCDIR=${INROOT}/${COMPILER}/netcdf-c/4.9.2
NETCDFFDIR=${INROOT}/${COMPILER}/netcdf-fortran/4.6.1
PIODIR=${INROOT}/${COMPILER}/pio/2.6.6
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$PNETCDFDIR/bin:$NETCDFCDIR/bin:$NETCDFFDIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$PIODIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$PNETCDFDIR/share/man:$NETCDFCDIR/share/man:$NETCDFFDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$HDF5DIR/include:$PNETCDFDIR/include:$NETCDFCDIR/include:$NETCDFFDIR/include:$PIODIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$NETCDFFDIR/lib:$PIODIR/lib:$LIBRARY_PATH"

# making the install directory (and change accessibility if needed)
if [ -d "${APPROOT}" ]; then
   rm -rf "${APPROOT}"
   mkdir -p $APPROOT

else
   echo "create '${APPROOT}'"
   mkdir $APPROOT
fi

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER build archive
cd archive

# download the ESMF code
wget -c -4  https://github.com/esmf-org/${NAME}/archive/refs/tags/v${APPVER}.tar.gz
tar zxvf v${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

## environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include -I$HDF5DIR/include -I$PNETCDFDIR/include -I$NETCDFCDIR/include -I$NETCDFFDIR/include -I$PIODIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib -L$HDF5DIR/lib -L$PNETCDFDIR/lib -L$NETCDFCDIR/lib -L$NETCDFFDIR/lib -L$PIODIR/lib"
export ESMF_DIR=$APPROOT/build/$FLODER
export ESMF_BOPT='O'
export ESMF_COMM='mpich'
export ESMF_NETCDF='nc-config'
export ESMF_NETCDF_INCLUDE=$NETCDFCDIR/include
export ESMF_NETCDF_LIBPATH=$NETCDFCDIR/lib
export ESMF_NETCDF_LIBS='-lnetcdff -lnetcdf -lhdf5_hl -lhdf5'
export ESMF_NFCONFIG="nf-config"
export ESMF_NETCDFF_INCLUDE=$NETCDFFDIR/include
export ESMF_NETCDFF_LIBPATH=$NETCDFFDIR/lib
export ESMF_NETCDFF_LIBS="-lnetcdff"
export ESMF_PNETCDF='pnetcdf-config'
export ESMF_PNETCDF_INCLUDE=$PNETCDFDIR/include
export ESMF_PNETCDF_LIBPATH=$PNETCDFDIR/lib
export ESMF_PNETCDF_LIBS='-lpnetcdf'
export ESMF_PIO='external'
export ESMF_PIO_LIB=$PIODIR/lib
export ESMF_PIO_INCLUDE=$PIODIR/include
export ESMF_COMPILER='gfortran'
export ESMF_INSTALL_PREFIX=$ESMFDIR
export ESMF_INSTALL_BINDIR=$ESMF_INSTALL_PREFIX/bin
export ESMF_INSTALL_LIBDIR=$ESMF_INSTALL_PREFIX/lib
export ESMF_INSTALL_MODDIR=$ESMF_INSTALL_PREFIX/mod
export ESMF_INSTALL_HEADERDIR=$ESMF_INSTALL_PREFIX/head
export ESMF_INSTALL_DOCDIR=$ESMF_INSTALL_PREFIX/doc
export CC=mpicc
export FC=mpifort
export MPICXX=mpicxx

# configure the build
make
make check
make install
#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'netcdff-4_6_1.sh' > './log/netcdff-4_6_1.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=netcdf-fortran
APPVER=4.6.1
COMPILER=gcc
APP=4_6_1
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
NETCDFFDIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
PNETCDFDIR=${INROOT}/${COMPILER}/pnetcdf/1.12.3
NETCDFCDIR=${INROOT}/${COMPILER}/netcdf-c/4.9.2
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$PNETCDFDIR/bin:$NETCDFCDIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$PNETCDFDIR/share/man:$NETCDFCDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$HDF5DIR/include:$PNETCDFDIR/include:$NETCDFCDIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$NETCDFCDIR/lib:$LIBRARY_PATH"

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

# download the NETCDF-FORTRAN code
wget -c -4  https://github.com/Unidata/${NAME}/archive/refs/tags/v${APPVER}.tar.gz
tar zxvf v${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

## environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include -I$HDF5DIR/include -I$PNETCDFDIR/include -I$NETCDFCDIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib -L$HDF5DIR/lib -L$PNETCDFDIR/lib -L$NETCDFCDIR/lib"
export CC=mpicc
export FC=mpifort
export MPICXX=mpicxx

# configure the build
./configure --prefix=$NETCDFFDIR --enable-pnetcdf --enable-shared --enable-legacy-support --with-netcdf=${NETCDFCDIR}
make 
make install
#make check
# Check netCDF fortran installation parameters
#nf-config --all
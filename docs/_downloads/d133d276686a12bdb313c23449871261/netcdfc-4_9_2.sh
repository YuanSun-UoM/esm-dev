#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'netcdfc-4_9_2.sh' > './log/netcdfc-4_9_2.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=netcdf-c
APPVER=4.9.2
COMPILER=gcc
APP=4_9_2
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
NETCDFCDIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
PNETCDFDIR=${INROOT}/${COMPILER}/pnetcdf/1.12.3
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$PNETCDFDIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$PNETCDFDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$HDF5DIR/include:$PNETCDFDIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$PNETCDFDIR/lib:$LIBRARY_PATH"

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

# download the NETCDF-C code
wget -c -4  https://github.com/Unidata/${NAME}/archive/refs/tags/v${APPVER}.tar.gz
tar zxvf v${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

# environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include -I$HDF5DIR/include -I$PNETCDFDIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib -L$HDF5DIR/lib -L$PNETCDFDIR/lib"
export CC=mpicc
export FC=mpifort
export MPICXX=mpicxx

# configure the build
./configure --prefix=$NETCDFCDIR --disable-dap --enable-pnetcdf --enable-parallel-tests --enable-shared
make 
make install
make check

# Check netCDF-C installation parameters
#nc-config --version
#nc-config --all
#!/usr/bin/env bash
# Install script for hdf5 parralel
# cd /home/yuansun/jobscript/software/
# bash 'pnetcdf-1_12_3.sh' > './log/pnetcdf-1_12_3.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=pnetcdf
APPVER=1.12.3
COMPILER=gcc
APP=1_12_3
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=${INROOT}/${COMPILER}/${NAME}
PNETCDFDIR=${INROOT}/${COMPILER}/${NAME}/$APPVER
MPICHDIR=${INROOT}/${COMPILER}/mpich/4.0.2
ZLIBDIR=${INROOT}/${COMPILER}/zlib/1.3.1
HDF5DIR=${INROOT}/${COMPILER}/hdf5/1.12.3
export PATH="$MPICHDIR/bin:$HDF5DIR/bin:$PATH"
export LD_LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$LD_LIBRARY_PATH"
export MANPATH="$MPICHDIR/share/man:$ZLIBDIR/share/man:$MANPATH"
export CPATH="$MPICHDIR/include:$ZLIBDIR/include:$HDF5DIR/include:$CPATH"
export LIBRARY_PATH="$MPICHDIR/lib:$ZLIBDIR/lib:$HDF5DIR/lib:$LIBRARY_PATH"

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

# download the PNETCDF code
wget -c -4  https://parallel-netcdf.github.io/Release/${NAME}-${APPVER}.tar.gz
tar zxvf ${NAME}-${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/$FLODER
cd $APPROOT/build/$FLODER

# environmental settings
export CPPFLAGS="-I$MPICHDIR/include -I$ZLIBDIR/include -I$HDF5DIR/include"
export LDFLAGS="-L$MPICHDIR/lib -L$ZLIBDIR/lib -L$HDF5DIR/lib"
export CC=mpicc
export FC=mpifort
export CXX=mpicxx

# configure the build
./configure --prefix=${PNETCDFDIR} --enable-subfiling --enable-shared --enable-large-file-test --enable-null-byte-header-padding --enable-burst-buffering --enable-profiling --enable-fortran
## (untest) --enable-fortran for WRF with pnetcdf

make
make tests
make check
make ptest
make ptests
make install
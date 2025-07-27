#!/usr/bin/env bash
# Install script for zlib 
# cd /home/yuansun/jobscript/software/
# bash 'lapack-3_9_0.sh' > './log/lapack-3_9_0.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=lapack
APPVER=3.9.0
COMPILER=gcc
APP=3_9_0
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/$COMPILER/${NAME}
LAPACKDIR=$APPROOT/${APPVER}
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

# download the LAPACK code
wget -c -4 wget https://github.com/Reference-LAPACK/${NAME}/archive/v${APPVER}.tar.gz
tar zxvf v${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER

cp make.inc.example make.inc
export FC=gfortran-9
make blaslib
make lapacklib
cp lib*.a $LAPACKDIR/

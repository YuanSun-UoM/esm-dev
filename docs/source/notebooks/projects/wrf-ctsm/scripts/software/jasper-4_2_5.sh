#!/usr/bin/env bash
# Install script for zlib 
# cd /home/yuansun/jobscript/software/
# bash 'jasper-4_2_5.sh' > './log/jasper-4_2_5.log' 2>&1
set -e
WORK=/home/yuansun
INROOT=${WORK}/software
NAME=jasper
APPVER=4.2.5
COMPILER=gcc
APP=4_2_5
FLODER=${NAME}-${APP}

# set the install & executable directory
APPROOT=$INROOT/$COMPILER/${NAME}
JASPERDIR=$APPROOT/${APPVER}

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

# download the JASPER code
wget -c -4 https://github.com/jasper-software/jasper/releases/download/version-${APPVER}/jasper-${APPVER}.tar.gz
tar zxvf jasper-${APPVER}.tar.gz
mv ${NAME}-${APPVER} $APPROOT/build/${FLODER}
cd $APPROOT/build/$FLODER
SOURCE_DIR=${APPROOT}/build/jasper-${APP}
BUILD=${APPROOT}/build/jasper-${APP}-build

cmake -G "Unix Makefiles" -H$SOURCE_DIR -B$BUILD -DCMAKE_INSTALL_PREFIX=$JASPERDIR \
                          -DJAS_ENABLED_SHARED=ON -DJAS_ENABLE_LIBJPEG=ON \
                          -DCMAKE_C_COMPILER=gcc-9 \
                          -DCMAKE_CXX_COMPILER=g++-9
cd $BUILD
make -j$(nproc)
make install              
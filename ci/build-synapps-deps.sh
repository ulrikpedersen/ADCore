#!/bin/bash
# Make sure we exit on any error 
set -e

ADCORE_DIR=`pwd`
mkdir -p $HOME/synapps
cd $HOME/synapps

#export EPICS_BASE=$HOME/epics/base-3.14.12.5
#export EPICS_HOST_ARCH=linux-x86_64

export PATH=$PATH:$EPICS_BASE/bin/$EPICS_HOST_ARCH

if [ ! -f sscan_R2-10.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/bcda/synApps/tar/sscan_R2-10.tar.gz
  tar -zxf sscan_R2-10.tar.gz 
fi
if [ ! -d "$HOME/synapps/sscan-2-10/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > sscan-2-10/configure/RELEASE
  make -C sscan-2-10/
else
  echo 'Using cached directory sscan';
fi

if [ ! -f calc_R3-4-2.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/bcda/synApps/tar/calc_R3-4-2.tar.gz
  tar -zxf calc_R3-4-2.tar.gz
fi
if [ ! -d "$HOME/synapps/calc-3-4-2/lib/$EPICS_HOST_ARCH" ]; then
  echo "SSCAN=`pwd`/sscan-2-10" > calc-3-4-2/configure/RELEASE
  echo "EPICS_BASE=$EPICS_BASE" >> calc-3-4-2/configure/RELEASE
  make -C calc-3-4-2/
else
  echo 'Using cached directory calc';
fi

if [ ! -f asyn4-26.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/epics/download/modules/asyn4-26.tar.gz
  tar -zxf asyn4-26.tar.gz
fi
if [ ! -d "$HOME/synapps/asyn4-26/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > asyn4-26/configure/RELEASE
  #echo "EPICS_LIBCOM_ONLY=YES" >> asyn4-26/configure/CONFIG_SITE
  make -C asyn4-26/
else
  echo 'Using cached directory asyn';
fi


if [ ! -f busy_R1-6-1.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/bcda/synApps/tar/busy_R1-6-1.tar.gz
  tar -zxf busy_R1-6-1.tar.gz
fi
if [ ! -d "$HOME/synapps/busy-1-6-1/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > busy-1-6-1/configure/RELEASE
  echo "ASYN=`pwd`/asyn4-26" >> busy-1-6-1/configure/RELEASE
  make -C busy-1-6-1/
else
  echo 'Using cached directory busy';
fi

if [ ! -f autosave_R5-5.tar.gz ]; then
  wget -nv http://www.aps.anl.gov/bcda/synApps/tar/autosave_R5-5.tar.gz
  tar -zxf autosave_R5-5.tar.gz
fi
if [ ! -d "$HOME/synapps/autosave-5-5/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > autosave-5-5/configure/RELEASE
  make -C autosave-5-5/
else
  echo 'Using cached directory autosave';
fi

if [ ! -f 3.1.14.tar.gz ]; then
  wget -nv https://github.com/epics-modules/iocStats/archive/3.1.14.tar.gz
  tar -zxf 3.1.14.tar.gz
fi
if [ ! -d "$HOME/synapps/iocStats-3.1.14/lib/$EPICS_HOST_ARCH" ]; then
  echo "EPICS_BASE=$EPICS_BASE" > iocStats-3.1.14/configure/RELEASE
  make -C iocStats-3.1.14
else
  echo 'Using cached directory iocStats';
fi

cd $ADCORE_DIR


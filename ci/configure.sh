#!/bin/bash
# Configure ADCore in preparation for build
# Make sure we exit on any error 
set -e

# Generate the configure/RELEASE.local and configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
# with the details of where to find various external libraries.
echo "EPICS_BASE=$EPICS_BASE"                >> configure/RELEASE.local
echo "HDF5=/usr"                             >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "HDF5_LIB=/usr/lib"                     >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "HDF5_INCLUDE=-I/usr/include"           >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
echo "XML2_INCLUDE=-I/usr/include/libxml2"   >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
if [ -z "$BOOST" ]; then
  echo "Not building boost unittests"
else
  echo "BOOST=$BOOST"                        >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
  echo "BOOST_LIB=$BOOST/lib"                >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
  echo "BOOST_INCLUDE=$BOOST/include"        >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
fi
echo "HOST_OPT=NO"                           >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
echo "USR_CXXFLAGS_Linux=--coverage"         >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
echo "USR_LDFLAGS_Linux=--coverage"          >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 

if [ -z "$EPICS_LIBCOM_ONLY" ]; then
  echo "ASYN=$HOME/synapps/asyn4-26"                >> configure/RELEASE.local
  echo "BUSY=$HOME/synapps/busy-1-6-1"              >> configure/RELEASE.local
  echo "CALC=$HOME/synapps/calc-3-4-2"              >> configure/RELEASE.local
  echo "SSCAN=$HOME/synapps/sscan-2-10"             >> configure/RELEASE.local
  echo "AUTOSAVE=$HOME/synapps/autosave-5-5"        >> configure/RELEASE.local
  echo "DEVIOCSTATS=$HOME/synapps/iocStats-3.1.14"  >> configure/RELEASE.local
else
  echo "ASYN=$HOME/epics/asyn4-26"           >> configure/RELEASE.local
  echo "EPICS_LIBCOM_ONLY=YES"               >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common 
fi

# Configure the example IOCs in preparation for build
echo "BUILD_IOCS=YES"                        >> configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common
cp configure/RELEASE.local                          iocs/simDetectorIOC/configure/
cp configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common    iocs/simDetectorIOC/configure/
echo "ADCORE=`pwd`"                          >> iocs/simDetectorIOC/configure/RELEASE.local
cp configure/RELEASE.local                          iocs/simDetectorNoIOC/configure/
cp configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common    iocs/simDetectorNoIOC/configure/
echo "ADCORE=`pwd`"                          >> iocs/simDetectorNoIOC/configure/RELEASE.local

echo "====== configure/RELEASE.local ============="
cat configure/RELEASE.local

echo "====== configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common ============="
cat configure/CONFIG_SITE.$EPICS_HOST_ARCH.Common


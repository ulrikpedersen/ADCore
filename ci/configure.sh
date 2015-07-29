#!/bin/bash
# Configure ADCore in preparation for build

# Generate the configure/RELEASE.local and configure/CONFIG_SITE.linux-x86_64.Common
# with the details of where to find various external libraries.
echo "EPICS_BASE=$EPICS_BASE"                >> configure/RELEASE.local
echo "HDF5=/usr"                             >> configure/CONFIG_SITE.linux-x86_64.Common
echo "HDF5_LIB=/usr/lib"                     >> configure/CONFIG_SITE.linux-x86_64.Common
echo "HDF5_INCLUDE=-I/usr/include"           >> configure/CONFIG_SITE.linux-x86_64.Common
echo "XML2_INCLUDE=-I/usr/include/libxml2"   >> configure/CONFIG_SITE.linux-x86_64.Common
if [ -z "$BOOST" ]; then
  echo "Not building boost unittests"
else
  echo "BOOST=$BOOST"                        >> configure/CONFIG_SITE.linux-x86_64.Common
  echo "BOOST_LIB=$BOOST/lib"                >> configure/CONFIG_SITE.linux-x86_64.Common
  echo "BOOST_INCLUDE=$BOOST/include"        >> configure/CONFIG_SITE.linux-x86_64.Common
fi
echo "HOST_OPT=NO"                           >> configure/CONFIG_SITE.linux-x86_64.Common 
echo "USR_CXXFLAGS_Linux=--coverage"         >> configure/CONFIG_SITE.linux-x86_64.Common 
echo "USR_LDFLAGS_Linux=--coverage"          >> configure/CONFIG_SITE.linux-x86_64.Common 

echo "ASYN=$HOME/epics/asyn4-26"          >> configure/RELEASE.local
echo "BUSY=$HOME/epics/busy-1-6-1"        >> configure/RELEASE.local
echo "CALC=$HOME/epics/calc-3-4-2"        >> configure/RELEASE.local
echo "SSCAN=$HOME/epics/sscan-2-10"       >> configure/RELEASE.local
echo "AUTOSAVE=$HOME/epics/autosave-5-5"  >> configure/RELEASE.local
echo "DEVIOCSTATS=$HOME/epics/iocStats-3.1.14"  >> configure/RELEASE.local

# Configure the example IOCs in preparation for build
echo "BUILD_IOCS=YES"                        >> configure/CONFIG_SITE.linux-x86_64.Common
cp configure/RELEASE.local                      iocs/simDetectorIOC/configure/
cp configure/CONFIG_SITE.linux-x86_64.Common    iocs/simDetectorIOC/configure/
echo "ADCORE=`pwd`"                          >> iocs/simDetectorIOC/configure/RELEASE.local
cp configure/RELEASE.local                      iocs/simDetectorNoIOC/configure/
cp configure/CONFIG_SITE.linux-x86_64.Common    iocs/simDetectorNoIOC/configure/
echo "ADCORE=`pwd`"                          >> iocs/simDetectorNoIOC/configure/RELEASE.local


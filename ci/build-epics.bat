@echo off
setlocal enabledelayedexpansion enableextensions

pushd C:\epics

If Exist %EPICS_BASE%\bin\%EPICS_HOST_ARCH%\ ( 
  appveyor AddMessage "Using EPICS base cache" -Category Information
  ECHO Using EPICS base cache
  exit /B 0
) else (
  appveyor AddMessage "Installing EPICS base" -Category Information
  ECHO Installing EPICS base
)

ECHO Downloading EPICS base...
appveyor DownloadFile http://www.aps.anl.gov/epics/download/base/baseR3.14.12.5.tar.gz
if errorlevel 1 (
  call :ReportFailure %ERRORLEVEL% Failed to download EPICS base
  exit /B %ERRORLEVEL%
)

ECHO Extracting EPICS base
7z e -tgzip baseR3.14.12.5.tar.gz
7z x -ttar baseR3.14.12.5.tar > nul

REM ECHO Configuring EPICS base...
REM ECHO SHARED_LIBRARIES=YES >> base-3.14.12.5\configure\CONFIG_SITE.%EPICS_HOST_ARCH%.Common
REM ECHO STATIC_BUILD=NO >> base-3.14.12.5\configure\CONFIG_SITE.%EPICS_HOST_ARCH%.Common

ECHO Building EPICS base...
C:\MinGW\bin\mingw32-make -C base-3.14.12.5 > base-3.14.12.5\build_log.txt 2>&1
set build_error=!ERRORLEVEL!
echo build error: !build_error!
if not !build_error! == 0 (
  call :ReportFailure %ERRORLEVEL% Failed to build EPICS base. Printing log:
  type base-3.14.12.5\build_log.txt
  exit /B !build_error!
)

ECHO Packing EPICS base into an artifact...
copy base-3.14.12.5\build_log.txt %APPVEYOR_BUILD_FOLDER%\artifacts\base_build_log.txt
7z a %APPVEYOR_BUILD_FOLDER%\artifacts\epicsbase.zip %EPICS_BASE%\bin\%EPICS_HOST_ARCH%\*.dll
7z a %APPVEYOR_BUILD_FOLDER%\artifacts\epicsbase.zip %EPICS_BASE%\lib\%EPICS_HOST_ARCH%\*.lib
7z a %APPVEYOR_BUILD_FOLDER%\artifacts\epicsbase.zip %EPICS_BASE%\bin\%EPICS_HOST_ARCH%\*.exe
dir
REM dir %EPICS_BASE%\bin\%EPICS_HOST_ARCH%
REM dir %EPICS_BASE%\lib\%EPICS_HOST_ARCH%
REM dir %EPICS_BASE%\dbd

popd

goto :EOF
:ReportFailure
  appveyor AddMessage "%*" -Category Error
  echo #### ERROR [%DATE% %TIME%] ### Error code: %1  MESSAGE: %*


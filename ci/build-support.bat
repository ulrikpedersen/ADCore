@echo off
setlocal enabledelayedexpansion enableextensions

pushd C:\epics

set epics

If Exist ADBinaries-R2-2\bin\%EPICS_HOST_ARCH%\ ( 
  appveyor AddMessage "Using ADBinaries cache" -Category Information
  ECHO Using ADBinaries cache
  exit /B 0
) else (
  appveyor AddMessage "Installing ADBinaries" -Category Information
  ECHO Installing ADBinaries
      
  ECHO Downloading ADBinaries...
  appveyor DownloadFile https://github.com/areaDetector/ADBinaries/archive/R2-2.zip
  if errorlevel 1 (
    call :ReportFailure %ERRORLEVEL% Failed to download ADBinaries
    exit /B %ERRORLEVEL%
  )

  ECHO Extracting ADBinaries
  7z x -tzip R2-2.zip > nul
  
  ECHO Configuring ADBinaries
  echo EPICS_BASE=%EPICS_BASE:\=/%> ADBinaries-R2-2\configure\RELEASE.%EPICS_HOST_ARCH%
  echo ADBinaries-R2-2\configure\RELEASE
  type ADBinaries-R2-2\configure\RELEASE
  echo ADBinaries-R2-2\configure\RELEASE.%EPICS_HOST_ARCH%
  type ADBinaries-R2-2\configure\RELEASE.%EPICS_HOST_ARCH%

  ECHO Building ADBinaries...
  C:\MinGW\bin\mingw32-make -C ADBinaries-R2-2 > ADBinaries-R2-2\build_log.txt 2>&1
  set build_error=!ERRORLEVEL!
  echo build error: !build_error!
  if not !build_error! == 0 (
    call :ReportFailure %build_error% Failed to build ADBinaries. Printing log:
    type ADBinaries-R2-2\build_log.txt
    exit /B !build_error!
  )
)

If Exist asyn-R4-26\bin\%EPICS_HOST_ARCH%\ ( 
  appveyor AddMessage "Using asyn cache" -Category Information
  ECHO Using asyn cache
  exit /B 0
) else (
  appveyor AddMessage "Installing asyn" -Category Information
  ECHO Installing asyn
      
  ECHO Downloading asyn...
  appveyor DownloadFile https://github.com/epics-modules/asyn/archive/R4-26.zip
  if errorlevel 1 (
    call :ReportFailure %ERRORLEVEL% Failed to download asyn
    exit /B %ERRORLEVEL%
  )

  ECHO Extracting asyn
  7z x -tzip R4-26.zip > nul
  
  ECHO Configuring asyn
  echo EPICS_BASE=C:\\epics\\base-3.14.12.5> asyn-R4-26\configure\RELEASE
  echo EPICS_LIBCOM_ONLY=YES>> asyn-R4-26\configure\CONFIG_SITE
  echo asyn-R4-26\configure\RELEASE:
  type asyn-R4-26\configure\RELEASE
  echo asyn-R4-26\configure\CONFIG_SITE:
  type asyn-R4-26\configure\CONFIG_SITE

  ECHO Building asyn...
  C:\MinGW\bin\mingw32-make -C asyn-R4-26 > asyn-R4-26\build_log.txt 2>&1
  set build_error=!ERRORLEVEL!
  echo build error: !build_error!
  if not !build_error! == 0 (
    call :ReportFailure %build_error% Failed to build asyn. Printing log:
    type %APPVEYOR_BUILD_FOLDER%\artifacts\asyn_build_log.txt
    ls -l asyn-R4-26
    ls -l asyn-R4-26\configure
    exit /B !build_error!
  )
)

copy asyn-R4-26\build_log.txt %APPVEYOR_BUILD_FOLDER%\artifacts\asyn_build_log.txt
copy ADBinaries-R2-2\build_log.txt %APPVEYOR_BUILD_FOLDER%\artifacts\adbinaries_build_log.txt

popd

goto :EOF
:ReportFailure
  appveyor AddMessage "%*" -Category Error
  echo #### ERROR [%DATE% %TIME%] ### Error code: %1  MESSAGE: %*


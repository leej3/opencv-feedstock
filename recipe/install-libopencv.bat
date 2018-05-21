
pushd build
cmake --build . --target INSTALL --config Release -- VERBOSE=1 -j%CPU_COUNT%
:: cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

if "%ARCH%" == "32" ( set "OPENCV_ARCH=86")
if "%ARCH%" == "64" ( set "OPENCV_ARCH=64")

dir /s /q %LIBRARY_PREFIX%\x%OPENCV_ARCH%\vc%VS_MAJOR%\

SET LookForFile="C:\Users\builder\continue.txt"

:CheckForFile
IF EXIST %LookForFile% GOTO FoundIt
echo Waiting for C:\Users\builder\continue.txt to exist

REM If we get here, the file is not found.

REM Wait 60 seconds and then recheck.
REM If no delay is needed, comment/remove the timeout line.
TIMEOUT /T 60 >nul

GOTO CheckForFile

:FoundIt
del C:\Users\builder\continue.txt

robocopy %LIBRARY_PREFIX%\x%OPENCV_ARCH%\vc%VS_MAJOR%\ %LIBRARY_PREFIX%\ *.* /E /R:0 /W:0

rem Remove files installed in the wrong locations
rd /S /Q "%LIBRARY_BIN%\Release"
rd /S /Q "%LIBRARY_PREFIX%\x%OPENCV_ARCH%"

dir /s /q %LIBRARY_PREFIX%\x%OPENCV_ARCH%\vc%VS_MAJOR%\

popd

rem RD is a bit horrible and doesn't return an errorcode properly, so
rem the errorcode from robocopy is propagated (which is non-zero), so we
rem forcibly exit 0 here
exit 0

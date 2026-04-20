@echo off
title SPIKE to Robot Inventor Firmware Tool
setlocal

set SCRIPT_DIR=%~dp0
set PYINSTALLER=%SCRIPT_DIR%python_installer.exe
set ZIPNAME=Mindstorms premade Firmware PyBypass.zip
set ZADIG=%SCRIPT_DIR%zadig.exe
set ZADIG_URL=https://github.com/pbatard/libwdi/releases/download/v1.5.1/zadig-2.9.exe

echo =====================================================
echo GTAC's SPIKE to Robot Inventor Firmware Flashing Tool
echo =====================================================
echo Did you accidentally run SPIKE and it restored the
echo Lego SPIKE firmware to the hub?
echo You can return it to Lego Mindstorms Inventor firmware
echo with this tool.
echo.

REM =====================================================
REM [1/7] Check Python is installed
REM =====================================================
echo [1/7] Checking Python...

where py >nul 2>&1
if %errorlevel% neq 0 (

    echo Python not found.
    echo Downloading Python 3.11...

    curl.exe -L -o "%PYINSTALLER%" https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe

    if not exist "%PYINSTALLER%" (
        echo.
        echo ERROR: Python download failed.
        pause
        exit /b
    )

    echo Installing Python per user silently...
    "%PYINSTALLER%" /quiet PrependPath=1 Include_pip=1

    timeout /t 5 >nul

    where py >nul 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Python installation may not have completed yet.
        echo Please CLOSE this window and run the program again.
        pause
        exit /b
    )

    del "%PYINSTALLER%"

    echo Restarting script to refresh PATH...
    timeout /t 3 >nul
    start "" "%~f0"
    exit /b
)

echo Python found.
echo.

REM =====================================================
REM [2/7] Ensure pip is installed
REM =====================================================
echo [2/7] Checking pip...
py -3 -m ensurepip --upgrade >nul 2>&1
echo pip ready.
echo.

REM =====================================================
REM [3/7] Install pybricksdev
REM =====================================================
echo [3/7] Installing pybricksdev...
py -3 -m pip install --upgrade pybricksdev --break-system-packages

if %errorlevel% neq 0 (
    echo.
    echo ERROR: pybricksdev installation failed.
    pause
    exit /b
)

echo pybricksdev ready.
echo.

REM =====================================================
REM [4/7] Install Lego Hub Driver Using Zadig
REM =====================================================
echo [4/7] Driver Setup (Zadig)

REM Download Zadig if missing
if not exist "%ZADIG%" (
    echo.
    echo Zadig not found.
    echo Downloading Zadig 2.9...

    curl.exe -L -o "%ZADIG%" "%ZADIG_URL%"

    if not exist "%ZADIG%" (
        echo.
        echo ERROR: Zadig download failed.
        pause
        exit /b
    )

    echo Zadig downloaded successfully.
)

REM Clear screen before important instructions
cls

echo =====================================================
echo IMPORTANT DRIVER STEP
echo =====================================================
echo.
echo 1. Put hub in bootloader mode:
echo.
echo Make sure the hub is turned off with no lights on.
echo Hold the bluetooth button down and plug in the microUSB cable,
echo then hold the bluetooth button for another 5 seconds.
echo The bluetooth button will begin cycling through:
echo RED -^> GREEN -^> BLUE -^> PURPLE.
echo.
echo When you can see colour cycling, you are ready to continue.  When you continue a new app will pop up called Zadig.  
pause
echo.
echo 2. In Zadig, click Options -^> List All Devices.  
echo (If you have installed winUSB previously, nothing will appear in the menu.  You can close Zadig and press any key to continue).
echo 3. Select the LEGO Technic Hub in DFU mode.
echo 4. Choose WinUSB driver.
echo 5. Click Install Driver.  It may take a minute
echo 6. Close Zadig when finished.
echo.

start "" "%ZADIG%"

echo.
echo After installing the driver and closing Zadig,
pause

echo Driver step complete.
echo.

REM =====================================================
REM [5/7] Download Firmware
REM =====================================================
echo [5/7] Checking firmware...

if not exist "%ZIPNAME%" (
    echo Downloading firmware...
    curl.exe -L -o "%ZIPNAME%" https://raw.githubusercontent.com/EnderCraft2007/Spike-Prime-Robot-Inventor-Conversion/main/Mindstorms%%20premade%%20Firmware%%20PyBypass.zip

    if not exist "%ZIPNAME%" (
        echo.
        echo ERROR: Firmware download failed.
        pause
        exit /b
    )
)

echo Firmware ready.
echo.

REM =====================================================
REM [6/7] Ready to Flash
REM =====================================================
echo [6/7] READY TO FLASH
echo.
echo Make sure hub is still in COLOUR CYCLING bootloader mode.
pause

REM =====================================================
REM [7/7] Flash Firmware
REM =====================================================
echo Flashing firmware...
echo.

py -3 -m pybricksdev flash "%ZIPNAME%"

if %errorlevel% neq 0 (
    echo.
    echo FLASH FAILED.  Was your hub connected, your drivers setup and your hub colour cycling?
    pause
    exit /b
)

echo.
echo =====================================================
echo FLASH COMPLETE!
echo Hub should now be ready to update in
echo Lego Mindstorms Inventor.
echo =====================================================
pause

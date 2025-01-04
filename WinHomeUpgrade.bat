@echo off
:: Batch script to upgrade Windows to Pro
:: Request administrative privileges
:: =============================================
:: Display warning message
echo =============================================
echo WARNING: This process will upgrade your Windows edition to Pro.
echo A reboot will be required during the process.
echo Please ensure all open applications are closed before proceeding.
echo =============================================

pause

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrative privileges confirmed.
    timeout /t 3 >nul
) else (
    echo Requesting administrative privileges...
    :: Re-run the script as administrator
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Enable delayed variable expansion for dynamic variable manipulation
setlocal enabledelayedexpansion

:: Function to disable internet connections
:DisableInternet
echo Disabling internet connections...
set "enabledInterfaces=0"
for /f "skip=3 tokens=1,4" %%a in ('netsh interface show interface') do (
    if /i "%%a"=="Enabled" (
        set "interface=%%b"
        if "!interface:~0,1!"==" " set "interface=!interface:~1!"
        if "!interface:~-1!"==" " set "interface=!interface:~0,-1!"
        echo Disabling interface: "!interface!"
        netsh interface set interface "!interface!" admin=disable
        timeout /t 1 >nul
        set /a enabledInterfaces+=1
    )
)

:: Check if any enabled interfaces are left
if !enabledInterfaces! equ 0 (
    echo All interfaces have been disabled.
    goto :MainProcess
) else (
    echo Some interfaces could not be disabled.
)

:: Main process
:MainProcess

:: Step 2: Uninstall the current product key
echo Uninstalling the current product key...
cscript //B slmgr.vbs /upk
timeout /t 3 >nul

:: Step 3: Clear the product key from the registry
echo Clearing the product key from the registry...
cscript //B slmgr.vbs /cpky
timeout /t 3 >nul

:: Step 4: Clear the KMS server address
echo Clearing the KMS server address...
cscript //B slmgr.vbs /ckms
timeout /t 3 >nul

:: Step 5: Check if the edition is upgradable to Pro
echo Checking if your edition is upgradable to Pro...
DISM /online /Get-TargetEditions
timeout /t 3 >nul

:: Step 6: Run the Windows Pro installer
echo Running Windows Pro installer...
sc config LicenseManager start= auto
net start LicenseManager
sc config wuauserv start= auto
net start wuauserv
changepk.exe /productkey VK7JG-NPHTM-C97JM-9MPGT-3V66T
timeout /t 3 >nul

:: Step 7: Create the EnableInternet.bat script in the Startup folder
echo Creating EnableInternet.bat in the Startup folder...
echo @echo off > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo :: Check for admin rights >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo net session ^>nul 2^>^&1 >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo if %%errorLevel%% == 0 ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     echo Administrative privileges confirmed. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     timeout /t 3 ^>nul >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) else ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     echo Requesting administrative privileges... >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     powershell -Command "Start-Process '%%~f0' -Verb RunAs" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     exit /b >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo setlocal enabledelayedexpansion >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo set "disabledInterfaces=0" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo for /f "skip=3 tokens=1,4" %%a in ('netsh interface show interface') do ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     if /i "%%a"=="Disabled" ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         set "interface=%%b" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         if "%%interface:~0,1%%"==" " set "interface=%%interface:~1%%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         if "%%interface:~-1%%"==" " set "interface=%%interface:~0,-1%%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         echo Enabling interface: "%%interface%%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         netsh interface set interface "%%interface%%" admin=enable >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         if %%errorLevel%% equ 0 ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo             set /a disabledInterfaces+=1 >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         ) else ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo             echo Failed to enable interface: "%%interface%%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo         ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo if %%disabledInterfaces%% equ 0 ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     echo All interfaces have been enabled. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) else ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo     echo Some interfaces could not be enabled. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo echo Windows 11 Pro upgrade is complete! >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo echo Please run 'WinProActiv.bat' to activate Windows 11 Pro. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo pause >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"

:: Step 8: Add commands to delete EnableInternet.bat and logs
echo Adding self-deletion commands to EnableInternet.bat...
echo echo Deleting EnableInternet.bat and logs... >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo del "%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo if %%errorLevel%% equ 0 ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo    echo Files deleted successfully. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo    pause >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) else ( >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo    echo Failed to delete files. >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo ) >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EnableInternet.bat"
echo echo exit



:: Step 9: Reboot the system
echo Rebooting the system in 15 seconds...

if %errorLevel% == 0 (
    echo Rebooting now...
    shutdown /r /t 15
)

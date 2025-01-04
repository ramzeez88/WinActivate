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
) else (
    echo Requesting administrative privileges...
    :: Re-run the script as administrator
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Step 1: Check if the current edition is already Pro
for /f "tokens=4 delims= " %%a in ('DISM /online /Get-CurrentEdition') do set CURRENT_EDITION=%%a
if "%CURRENT_EDITION%"=="Professional" (
    echo =============================================
    echo Your Windows edition is already Professional.
    echo No upgrade is needed. Exiting...
    echo =============================================
    pause
    exit /b
)

:: Step 2: Uninstall the current product key
echo Uninstalling the current product key...
cscript //B slmgr.vbs /upk

:: Step 3: Clear the product key from the registry
echo Clearing the product key from the registry...
cscript //B slmgr.vbs /cpky

:: Step 4: Clear the KMS server address
echo Clearing the KMS server address...
cscript //B slmgr.vbs /ckms

:: Step 5: Check if the edition is upgradable to Pro
echo Checking if your edition is upgradable to Pro...
DISM /online /Get-TargetEditions

:: Step 6: Run the Windows Pro installer
echo Running Windows Pro installer...
sc config LicenseManager start= auto
net start LicenseManager
sc config wuauserv start= auto
net start wuauserv
changepk.exe /productkey VK7JG-NPHTM-C97JM-9MPGT-3V66T

:: Step 7: Create a post-reboot script
echo @echo off > "%TEMP%\PostRebootMessage.bat"
echo echo Windows 11 Pro upgrade is complete! >> "%TEMP%\PostRebootMessage.bat"
echo echo Please run 'WinProActiv.bat' to activate Windows 11 Pro. >> "%TEMP%\PostRebootMessage.bat"
echo pause >> "%TEMP%\PostRebootMessage.bat"

:: Step 8: Schedule the post-reboot script to run after reboot
schtasks /create /tn "PostRebootMessage" /tr "%TEMP%\PostRebootMessage.bat" /sc onstart /ru SYSTEM /f

:: Step 9: Reboot the system
echo Rebooting the system in 15 seconds...
timeout /t 15 /nobreak >nul
if %errorLevel% == 0 (
    echo Rebooting now...
    shutdown /r /t 0
)

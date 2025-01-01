@echo off
:: Batch script to activate Windows 11 Pro
:: Request administrative privileges
:: =============================================
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

:: Step 1: Activate Windows 11 Pro
echo Activating Windows 11 Pro...
cscript //B slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
cscript //B slmgr.vbs /skms kms8.msguides.com
cscript //B slmgr.vbs /ato

echo Windows 11 Pro has been activated!
pause

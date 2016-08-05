configuration vTrainingLabPrepare {
    param (
        ## Target filename, e.g. "C:\Windows\System32\Prepare.bat"
        [Parameter(Mandatory)]
        [System.String] $Path
    )

    Import-DscResource -Module PSDesiredStateConfiguration;

    $prepareBat = @'
@echo off
cls

:: Simple Prepbuild Script (nothing fancy)
:: Virtual Engine 09/06/2016
:: Version : 1.0

echo STARTING -  Prepbuild Script (%time%)

:: Stop/Disable Windows Update
powershell.exe -Command "& { Get-Service wuauserv | Stop-Service -PassThru | Set-Service -StartupType Disabled }"
echo 1. Stopped and disabled Windows Update Service.

:: Delete WSUS Downloads folder
echo 2. Deleting C:\Windows\SoftwareDistribution\Download Folder...
rd "C:\Windows\SoftwareDistribution\Download" /s /q
echo 3. Deleted C:\Windows\SoftwareDistribution\Download.

:: Run .NET Optimisations
echo 4. Running .NET Optimisations...
"C:\Windows\Microsoft.NET\Framework\v2.0.50727\ngen.exe" ExecuteQueuedItems /silent
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe" ExecuteQueuedItems /silent
"C:\Windows\Microsoft.NET\Framework64\v2.0.50727\ngen.exe" ExecuteQueuedItems /silent
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" ExecuteQueuedItems /silent
echo 5. NET Optimisations Completed.

:: Run Disk Cleanup
:: echo 6. Running Disk Cleanup. This will take some time!!
:: cleanmgr /sagerun:1 /d c:
:: echo 7. Disk Cleanup Completed.

:: Delete Temp Files
:: echo 7. Delete Temp Files.
rmdir /S /Q %SYSTEMDRIVE%\Resources
rmdir /S /Q %SYSTEMDRIVE%\Bootstrap
del "%temp%\*" /s /q
del /F /S /Q "%WINDIR%\TEMP"
echo 8. Deleted Temp Files.

:: Clear All Event Logs (Yes we need some Powershell magic)
echo 9. Clearing All Event Logs...
powershell.exe -Command "& { wevtutil el | Foreach-Object { wevtutil cl "$_" } }"
echo 10. Event Logs Cleared.

:: Delete Cached Profiles
echo 11. Deleting Cached Profiles...
"%~dp0Delprof2.exe" /u /q
echo 12. Cached Profiles Deleted.

:: Disable Maintenance Task...
schtasks.exe /change /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /disable
schtasks.exe /change /tn "\Microsoft\Windows\TaskScheduler\Idle Maintenance" /disable
schtasks.exe /change /tn "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /disable
echo 13. Disabled Maintenance Task

:: Delete the Run History and Recently used Programs
reg DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist /f
reg DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
echo 14. Deleted the Run History and Recently Used Programs.

reg ADD "HKLM\Software\Virtual Engine" /v PreparationDate /t REG_SZ /d "%date% %time%" /f

:: Shutdown the VM immediately
:: SHUTDOWN /S /T 0

echo COMPLETED - Prepbuild Script (%time%)
'@

    File 'Prepare_BAT' {
        DestinationPath = $Path;
        Contents = $prepareBat;
        Type = 'File';
    }
} #end configuration vTrainingLabPrepare

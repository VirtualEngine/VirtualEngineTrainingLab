configuration vTrainingLabPrepare {
    param (
        ## Target filename, e.g. "C:\Windows\System32\Prepare.bat" 
        [Parameter(Mandatory)]
        [System.String] $Path
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration;
    
    $prepareBat = @'
@ECHO OFF

REM ***** Delete the Run history
REG DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

REM ***** Delete the recently used programs
REG DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist /f

REM ***** Remove \Resources and \Bootstrap folders
RMDIR /S /Q %SYSTEMDRIVE%\Resources
RMDIR /S /Q %SYSTEMDRIVE%\Bootstrap

REM ***** Empty System %TEMP% directory
DEL /F /S /Q "%WINDIR%\TEMP"

REM ***** Disable Windows Update and delete Windows Update cache
NET STOP WUAUSERV
SC.EXE CONFIG WUAUSERV start= disabled
RMDIR /S /Q "%SYSTEMROOT%\SoftwareDistribution"

REM ***** Run .Net optimisation
CD "%SYSTEMROOT%\Microsoft.NET"
for /R %f in (ngen.exe) do @IF EXIST %f %f executeQueuedItems

REG ADD HKLM\Software\VirtualEngine /v PreparationDate /t REG_SZ /d "%date% %time%" /f

REM ***** Shutdown the VM immediately
SHUTDOWN /S /T 0
'@
    
    File 'Prepare_BAT' {
        DestinationPath = $Path;
        Contents = $prepareBat;
        Type = 'File';
    }
} #end configuration vTrainingLabPrepare
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

REM ***** Shutdown the VM immediately
SHUTDOWN /S /T 0
'@
    
    File 'Prepare_BAT' {
        DestinationPath = $Path;
        Contents = $prepareBat;
        Type = 'File';
    }
} #end configuration vTrainingLabPrepare
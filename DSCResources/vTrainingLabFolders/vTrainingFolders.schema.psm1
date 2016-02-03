configuration vTrainingLabFolders {
    param (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Folders,
        
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Users,
        
        [Parameter()]
        [System.String[]] $Departments
    )
    
    Import-DscResource PSDesiredStateConfiguration, xSmbShare;
    
    foreach ($folder in $Folders) {
        $folderId = $folder.Path.Replace(':','').Replace('\','_');
        File $folderId {
            DestinationPath = $folder.Path;
            Type = 'Directory';
        }
        
        if ($folder.Share) {
            if ($folder.FullControl -and $folder.Description) {
                xSmbShare $folder.Share {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    FullControl = $folder.FullControl;
                }
            }
            elseif ($folder.FullControl) {
                xSmbShare $folder.Share {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    FullControl = $folder.FullControl;
                }
            }
            else {
                xSmbShare $folder.Share {
                    Name = $folder.Share;
                    Path = $folder.Path;
                }
            }
            Name = $folder.Share;
            Path = $folder.Path;
        }
        
    } #end foreach folder
    
    if ($Departments) {
        foreach ($departments in $Departments) {
            $folderPath = '{0}\{1}' -f 'C:\SharedData\Departmental Shares', $department;
            $folderId = $folderPath.Replace(':','').Replace('\','_');
            File $folderId {
                DestinationPath = $folderPath;
                Type = 'Directory';
            }
        }  
    }
    
    if ($Users) {
        foreach ($user in $Users) {
            $folderPath = '{0}\{1}' -f 'C:\SharedData\User Home Directories', $user.SamAccountName;
            $folderId = $folderPath.Replace(':','').Replace('\','_');
            File $folderId {
                DestinationPath = $folderPath;
                Type = 'Directory';
            }
        }
    }

} #end configuration vTrainingLabFolders

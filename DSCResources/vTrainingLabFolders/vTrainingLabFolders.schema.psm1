configuration vTrainingLabFolders {
    param (
        ## Collection of folders
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Folders,

        ## Collection of users to create home directories
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Users,

        ## Collections of departments to create department shares
        [Parameter()]
        [System.String[]] $Departments
    )

    Import-DscResource -Module PSDesiredStateConfiguration, xSmbShare, PowerShellAccessControl;

    foreach ($folder in $Folders) {

        $folderId = $folder.Path.Replace(':','').Replace(' ','').Replace('\','_');

        File $folderId {
            DestinationPath = $folder.Path;
            Type = 'Directory';
        }

        if ($folder.ReadNtfs) {
            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute;
                Principal = $folder.ReadNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.ModifyNtfs) {
            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::Modify;
                Principal = $folder.ModifyNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.FullControlNtfs) {
            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::FullControl;
                Principal = $folder.FullControlNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.Share) {
            $folderName = $folder.Share.Replace('$','');
            if ($folder.FullControl -and $folder.ChangeControl -and $folder.Description) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    FullAccess = $folder.FullControl;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl -and $folder.ChangeControl) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    FullAccess = $folder.FullControl;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl -and $folder.Description) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    FullAccess = $folder.FullControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.ChangeControl -and $folder.Description) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.Description) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    FullAccess = $folder.FullControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.ChangeControl) {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            else {
                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
        } #end if shared

    } #end foreach folder

    if ($Departments) {
        foreach ($department in $Departments) {

            $folderPath = '{0}\{1}' -f 'C:\SharedData\Departmental Shares', $department;
            $folderId = $folderPath.Replace(':','').Replace(' ','').Replace('\','_');

            File $folderId {
                DestinationPath = $folderPath;
                Type = 'Directory';
            }

            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folderPath;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::Modify;
                Principal = $department;
                DependsOn = "[File]$folderId";
            }

            xSmbShare $department {
                Name = $department;
                Path = $folderPath;
                FullAccess = 'Domain Admins';
                ChangeAccess = $department;
                Ensure = 'Present';
                Description = "$department departmental share";
                DependsOn = "[File]$folderId";
            }

        } #end foreach department
    } #end if departments

    if ($Users) {
        ## Create home directories
        foreach ($user in $Users) {

            $folderPath = '{0}\{1}' -f 'C:\SharedData\User Home Directories', $user.SamAccountName;
            $folderId = $folderPath.Replace(':','').Replace('\','_');

            File $folderId {
                DestinationPath = $folderPath;
                Type = 'Directory';
            }

            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folderPath;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::FullControl;
                Principal = $user.SamAccountName;
                DependsOn = "[File]$folderId";
            }

        } #end foreach user
    } #end if users

} #end configuration vTrainingLabFolders

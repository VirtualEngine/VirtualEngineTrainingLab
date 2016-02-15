configuration vTrainingLabUserThumbnails {
    param (
        ## Collection of users
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Users,
        
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhotoPath,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )
    
    Import-DscResource -Name vADUserThumbnailPhoto;
    
    foreach ($user in $Users) {
        vADUserThumbnailPhoto "$($user.SamAccountName)_Thumbnail" {
            DomainName = $DomainName;
            UserName = $user.SamAccountName;
            ThumbnailPhoto = (Join-Path -Path $ThumbnailPhotoPath -ChildPath $user.SamAccountName);
        }
    }
    
} #end configuration vTrainingLabUserThumbnails

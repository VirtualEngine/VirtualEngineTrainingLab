configuration vTrainingLabUserThumbnails {
    param (
        ## Collection of users
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Users,
        
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhotoPath,
        
        ## File extension added to SamAccountName, i.e. LOCAL01.jpg
        [Parameter(Mandatory)] [ValidateSet('jpg','png')]
        [System.String] $Extension,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )
    
    Import-DscResource -Name vADUserThumbnailPhoto;
    
    foreach ($user in $Users) {
        vADUserThumbnailPhoto "$($user.SamAccountName)_Thumbnail" {
            DomainName = $DomainName;
            UserName = $user.SamAccountName;
            ThumbnailPhoto = '{0}.{1}' -f (Join-Path -Path $ThumbnailPhotoPath -ChildPath $user.SamAccountName), $Extension;
        }
    }
    
} #end configuration vTrainingLabUserThumbnails

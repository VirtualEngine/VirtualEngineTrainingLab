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

        ## Uses the specified filename rather than %USERNAME%.$Extension
        [Parameter()] [ValidateNotNull()]
        [System.String] $Filename,

        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )

    Import-DscResource -Name vADUserThumbnailPhoto;

    foreach ($user in $Users) {

        if ($PSBoundParameters.ContainsKey('Filename')) {
            $thumbnailPhotoPath = '{0}.{1}' -f (Join-Path -Path $ThumbnailPhotoPath -ChildPath $Filename), $Extension;
        }
        else {
            $thumbnailPhotoPath = '{0}.{1}' -f (Join-Path -Path $ThumbnailPhotoPath -ChildPath $user.SamAccountName), $Extension;
        }

        vADUserThumbnailPhoto "$($user.SamAccountName)_Thumbnail" {
            DomainName = $DomainName;
            UserName = $user.SamAccountName;
            ThumbnailPhoto = $thumbnailPhotoPath;
        }

    } #end foreach user

} #end configuration vTrainingLabUserThumbnails

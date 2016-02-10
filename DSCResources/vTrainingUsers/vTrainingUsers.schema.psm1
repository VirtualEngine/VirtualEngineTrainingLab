configuration vTrainingLabUsers {
    param (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $Users,
        
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Password,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FileServer = 'controller.lab.local',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeDrive = 'H:',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeShare = 'Home$',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ProfileShare = 'Profile$',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MandatoryProfileName = 'Mandatory' 
    )
    
    
    $rootDN = ',DC={0}' -f $DomainName -split '\.' -join ',DC=';
    
    Import-DscResource -Module xActiveDirectory;
    
    foreach ($user in $ConfigurationData.NonNodeData.ActiveDirectory.Users) {

            if ([System.String]::IsNullOrEmpty($user.Path)) {
                $userPath = 'CN=Users,{0}' -f $rootDN.TrimStart(',');
            }
            else {
                $userPath = '{0}{1}' -f $user.Path, $rootDN;
            }

            if (-not $FileServer.StartsWith('\\')) {
                $FileServer = '\\{0}' -f $FileServer;
            }

            switch ($user.ProfileType)
            {
                'Roaming' { $profilePath = '{0}\{1}\{2}' -f $FileServer, $ProfileShare, $user.SamAccountName; }
                'Mandatory' { $profilePath = '{0}\{1}\{2}' -f $FileServer, $ProfileShare, $MandatoryProfileName; }
                Default { $profilePath = ''; }
            }

            xADUser "xADUser_$($user.SamAccountName)" {
                Path = $userPath;
                CommonName = "$($user.GivenName) $($user.Surname)";
                UserName = $user.SamAccountName;
                DomainName = $DomainName;
                Password = $Password;
                UserPrincipalName = "$($user.SamAccountName)@$($DomainName)";
                GivenName = $user.GivenName;
                Surname = $user.Surname;
                DisplayName = "$($user.GivenName) $($user.Surname)";
                Description = $user.SamAccountName;
                Office = $user.Office;
                OfficePhone = $user.Telephone;
                MobilePhone = $user.Mobile;
                Fax = $user.Fax;
                StreetAddress = $user.Address;
                City = $user.City;
                State = $user.State;
                PostalCode = $user.PostCode;
                Country = $user.Country;
                PasswordNeverExpires = $true;
                JobTitle = $user.JobTitle;
                Department = $user.Department;
                Company = $user.Company;
                HomeDrive = $HomeDrive;
                HomeDirectory = '{0}\{1}\{2}' -f $FileServer, $HomeShare, $user.SamAccountName;
                ProfilePath = $profilePath;
            }

        } #end foreach user

} #end configuration vTrainingLabUsers

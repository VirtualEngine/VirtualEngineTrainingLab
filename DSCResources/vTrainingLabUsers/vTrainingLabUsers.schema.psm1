configuration vTrainingLabUsers {
    param (
        ## Collection of users
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Users,
        
        ## User password to set/enforce
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Password,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',
        
        ## File server FQDN containing the user's home directories and profile shares
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FileServer = 'controller.lab.local',
        
        ## User's home drive assignment
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeDrive = 'H:',
        
        ## User home directory share name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $HomeShare = 'Home$',
        
        ## User profile directory share name
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ProfileShare = 'Profile$',
        
        ## Name of the mandatory user profile
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $MandatoryProfileName = 'Mandatory' 
    )
    
    $rootDN = ',DC={0}' -f $DomainName -split '\.' -join ',DC=';
    
    Import-DscResource -Module xActiveDirectory;
    
    foreach ($user in $Users) {

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
            'Roaming' {
                $profilePath = '{0}\{1}\{2}' -f $FileServer, $ProfileShare, $user.SamAccountName;
            }
            'Mandatory' {
                $profilePath = '{0}\{1}\{2}' -f $FileServer, $ProfileShare, $MandatoryProfileName;
            }
            Default {
                $profilePath = '';
            }
        }
        
        if ($user.ManagedBy) {
            $manager = $Users.Where({ $_.SamAccountName -eq $user.ManagedBy });
            $managerCN = '{0} {1}' -f $manager.GivenName, $manager.Surname;

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
                Manager = 'CN={0},{1}{2}' -f $managerCN, $manager.Path, $rootDN;
                EmployeeID = [System.String] $user.EmployeeID;
                EmployeeNumber = [System.String] $user.EmployeeNumber;
            }
            
        }
        else {

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
                EmployeeID = [System.String] $user.EmployeeID;
                EmployeeNumber = [System.String] $user.EmployeeNumber;
            }
        
        }

    } #end foreach user
    
} #end configuration vTrainingLabUsers

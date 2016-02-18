configuration vTrainingLab {
    param (
        ## Default user password to set/enforce
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Password,
        
        ## IP address used to calculate reverse lookup zone name
        [Parameter(Mandatory)]
        [System.String] $IPAddress,
        
        ## Folder containing GPO backup files
        [Parameter(Mandatory)]
        [System.String] $GPOBackupPath,
               
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
        [System.String] $MandatoryProfileName = 'Mandatory',
        
        ## Hostname for itstore.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ITStoreHost = 'controller.lab.local',
        
        ## Hostname for storefront.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StorefrontHost = 'xenapp.lab.local',
        
        ## Directory path containing user thumbnail photos 
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ThumbnailPhotoPath
    )
    
    ## Avoid recursive loading of the VirtualEngineTrainingLab composite resource
    Import-DscResource -Name vTrainingLabOUs, vTrainingLabUsers, vTrainingLabServiceAccounts, vTrainingLabGroups, vTrainingLabFolders;
    Import-DscResource -Name vTrainingLabGPOs, vTrainingLabDns, vTrainingLabPrinters, vTrainingLabUserThumbnails;
    
    $folders = @(
        @{  Path = 'C:\SharedData'; }
        @{
            Path = 'C:\SharedData\App-V Content';
            Share = 'Content';
            Description = 'App-V packages';
        }
        @{  Path = 'C:\SharedData\Company Share';
            Share = 'Company';
            FullControl = 'Everyone';
            Description = 'Company-wide shared information';
        }
        @{ Path = 'C:\SharedData\Company Share\Documentation'; }
        @{ Path = 'C:\SharedData\Company Share\Media'; }
        @{ Path = 'C:\SharedData\Company Share\Portraits'; }
        @{ Path = 'C:\SharedData\Departmental Shares'; }
        @{
            Path = 'C:\SharedData\DTS';
            Share = 'DTS$';
            FullControl = 'Everyone';
            Description = 'RES ONE Workspace Desktop Sampler files';
        }
        @{ Path = 'C:\SharedData\Labs'; }
        @{
            Path = 'C:\SharedData\Profiles';
            Share = 'Profile$';
            FullControl = 'Everyone';
            Description = 'User roaming profiles';
        }
        @{
            Path = 'C:\SharedData\Profiles\TS Profiles';
            Share = 'TSProfile$';
            FullControl = 'Everyone';
            Description = 'User Terminal Services roaming profiles';
        }
        @{ Path = 'C:\SharedData\Profiles\User Profiles'; }
        @{ Path = 'C:\SharedData\Scripts'; }
        @{
            Path = 'C:\SharedData\Software';
            Share = 'Software$';
            FullControl = 'Everyone';
            Description = 'Software repository';
        }
        @{
            Path = 'C:\SharedData\User Home Directories';
            Share = 'Home$';
            FullControl = 'Everyone';
            Description = 'User home folders';
        }
    ) #end folders
    
    $rootDN = 'DC={0}' -f $DomainName -split '\.' -join ',DC=';
    
    $activeDirectory = @{
        OUs = @(
            @{ Name = 'Training'; Description = 'Training group and user resources'; }
                @{ Name = 'Computers'; Path = 'OU=Training'; Description = 'Training computer accounts'; }
                @{ Name = 'Groups'; Path = 'OU=Training'; Description = 'Training security and distribution groups'; }
                @{ Name = 'Servers'; Path = 'OU=Training'; Description = 'Training server accounts'; }
                @{ Name = 'Service Accounts'; Path = 'OU=Training'; Description = 'Training service accounts'; }
                @{ Name = 'Users'; Path = 'OU=Training'; Description = 'Training department users'; }
                    @{ Name = 'Engineering'; Path = 'OU=Users,OU=Training'; Description = 'Engineering department user accounts'; }
                    @{ Name = 'Executive'; Path = 'OU=Users,OU=Training'; Description = 'Company executive user accounts'; }
                    @{ Name = 'Finance'; Path = 'OU=Users,OU=Training'; Description = 'Finance department user accounts'; }
                    @{ Name = 'Information Technology'; Path = 'OU=Users,OU=Training'; Description = 'IT departmental user accounts'; }
                    @{ Name = 'Marketing'; Path = 'OU=Users,OU=Training'; Description = 'Marketing department user accounts'; }
                    @{ Name = 'Sales'; Path = 'OU=Users,OU=Training'; Description = 'Sales department user accounts'; }
        )
        
        GPOs = @{
            'Default Domain Policy' = @{ };
            'Default Lab Policy' = @{ Link = $rootDN; Enabled = $true; }
            'Invoke Workspace Composer' = @{ Link = "OU=Servers,OU=Training,$rootDN","OU=Computers,OU=Training,$rootDN"; Enabled = $false; }
        }
        
        Users = @(
            # Engineering
            @{  SamAccountName = 'ROAM02'; GivenName = 'Gene'; Surname = 'Poole';
                Telephone = '01234 567894'; Mobile = '07700 900622'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Engineering Manager'; Department = 'Engineering'; Office = 'Medawar Centre'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Roaming'; }
            @{  SamAccountName = 'MAND01'; GivenName = 'Ann'; Surname = 'Thrax';
                Telephone = '01234 567900'; Mobile = '07700 900409'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Engineer'; Department = 'Engineering'; Office = 'Stark Tower'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Mandatory'; }
            @{  SamAccountName = 'MAND05'; GivenName = 'Jack'; Surname = 'Hammer';
                Telephone = '01234 567904'; Mobile = '07700 900415'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Engineering Manager'; Department = 'Engineering'; Office = 'Medawar Centre'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Mandatory'; }
            
            # Executive
            @{  SamAccountName = 'LOCAL05'; GivenName = 'Tony'; Surname = 'Stark';
                Telephone = '01234 567905'; Mobile = '07700 900440'; Fax = '01234 567899';
                JobTitle = 'Chief Executive Officer'; Department = 'Executive'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Executive,OU=Users,OU=Training'; }
            
            # Finance
            @{  SamAccountName = 'LOCAL03'; GivenName = 'Robin'; Surname = 'Banks';
                Telephone = '01234 567891'; Mobile = '07700 900827'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Finance Director'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; }
            @{  SamAccountName = 'ROAM04'; GivenName = 'Owen'; Surname = 'Cash';
                Telephone = '01234 567896'; Mobile = '07700 900468'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Credit Controller'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; ProfileType = 'Roaming'; }
            @{  SamAccountName = 'MAND03'; GivenName = 'Chris'; Surname = 'Cross';
                Telephone = '01234 567902'; Mobile = '07700 900585'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Finance Clerk'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; ProfileType = 'Mandatory'; }
            
            # Information Technology
            @{  SamAccountName = 'ROAM01'; GivenName = 'Justin'; Surname = 'Case';
                Telephone = '01234 567893'; Mobile = '07700 900155'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'IT Manager'; Department = 'Information Technology'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Information Technology,OU=Users,OU=Training'; ProfileType = 'Roaming'; }
            @{  SamAccountName = 'ROAM05'; GivenName = 'Luke'; Surname = 'Warme';
                Telephone = '01234 567898'; Mobile = '07700 900872'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Helpdesk Anaylst'; Department = 'Information Technology'; Office = 'Medawar Centre'; Company = 'Stark Industries';
                Path = 'OU=Information Technology,OU=Users,OU=Training'; ProfileType = 'Roaming'; }
            
            # Marketing
            @{  SamAccountName = 'LOCAL04'; GivenName = 'Mike'; Surname = 'Raffone';
                Telephone = '01234 567890'; Mobile = '07700 900738'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Marketing Manager'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; }
            @{  SamAccountName = 'ROAM03'; GivenName = 'Claire'; Surname = 'Voyant';
                Telephone = '01234 567895'; Mobile = '07700 900009'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Graphic Artist'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; ProfileType = 'Roaming'; }
            @{  SamAccountName = 'MAND02'; GivenName = 'Mona'; Surname = 'Lott';
                Telephone = '01234 567901'; Mobile = '07700 900576'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Copy Writer'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; ProfileType = 'Mandatory'; }
            
            # Sales
            @{  SamAccountName = 'LOCAL01'; GivenName = 'Warren'; Surname = 'Peace';
                Telephone = '01234 567892'; Mobile = '07700 900834'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Sales Director'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; }
            @{  SamAccountName = 'LOCAL02'; GivenName = 'Anne'; Surname = 'Chovee';
                Telephone = '01234 567897'; Mobile = '07700 900747'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Account Manager'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; }
            @{  SamAccountName = 'MAND04'; GivenName = 'Al'; Surname = 'Pacca';
                Telephone = '01234 567903'; Mobile = '07700 900558'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Account Manager'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; ProfileType = 'Mandatory'; }
        )

        ServiceAccounts = @(
            @{  SamAccountName = 'RESAM'; GivenName = 'RES'; Surname = 'Service AM';
                Description = 'RES ONE Automation Service Account'; Path = 'OU=Service Accounts,OU=Training'; }
            @{  SamAccountName = 'RESITS'; GivenName = 'RES'; Surname = 'Service ITS';
                Description = 'RES ONE Service Store Service Account'; Path = 'OU=Service Accounts,OU=Training'; }
            @{  SamAccountName = 'RESWM'; GivenName = 'RES'; Surname = 'Service WM';
                Description = 'RES ONE Workspace Service Account'; Path = 'OU=Service Accounts,OU=Training'; }
        )

        ## Universal group required to mail-enable
        Groups = @(
            @{ Name = 'Engineering'; Path = 'OU=Groups,OU=Training'; Description = 'Engineering users'; Scope = 'Universal'; }
            @{ Name = 'Executive'; Path = 'OU=Groups,OU=Training'; Description = 'Executive users'; Scope = 'Universal'; }
            @{ Name = 'Finance'; Path = 'OU=Groups,OU=Training'; Description = 'Finance users'; Scope = 'Universal'; }
            @{ Name = 'Information Technology'; Path = 'OU=Groups,OU=Training'; Description = 'IT users'; Scope = 'Universal'; }
            @{ Name = 'Marketing'; Path = 'OU=Groups,OU=Training'; Description = 'Marketing users'; Scope = 'Universal'; }
            @{ Name = 'Sales'; Path = 'OU=Groups,OU=Training'; Description = 'Sales users'; Scope = 'Universal'; }
            @{ Name = 'RES AM Administrators'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Automation administation accounts';
                Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES AM Service Accounts'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Automation service accounts';
                Members = 'RESAM'; Scope = 'DomainLocal'; }
            @{ Name = 'RES ITS Administrators'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Service Store administation accounts';
                    Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES ITS Service Accounts'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Service Store service accounts';
                    Members = 'RESITS'; Scope = 'DomainLocal'; }
            @{ Name = 'RES WM Administrators'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Workspace administation accounts';
                    Members = 'Domain Admins','Information Technology'; Scope = 'DomainLocal'; }
            @{ Name = 'RES WM Service Accounts'; Path = 'OU=Groups,OU=Training'; Description = 'RES ONE Workspace service accounts';
                    Members = 'Domain Admins','RESWM'; Scope = 'DomainLocal'; }
            
            ## Add RES AM Service Account to domain admins
            @{ Name = 'Domain Admins'; Path = 'CN=Users'; Members = 'RESAM'; }
        )
    
    } #end ActiveDirectory
    
    #region DNS
    vTrainingLabDns 'ReverseLookupAndCNames' {
        IPAddress = $IPAddress;
        DomainName = $DomainName;
        ITStoreHost = $ITStoreHost;
        StorefrontHost = $StorefrontHost;
    }
    #endregion DNS
    
    #region Active Directory
    vTrainingLabOUs 'OUs' {
        OUs = $activeDirectory.OUs;
        DomainName = $DomainName;
    }
    
    vTrainingLabServiceAccounts 'ServiceAccounts' {
        ServiceAccounts = $activeDirectory.ServiceAccounts;
        Password = $Password;
        DomainName = $DomainName;
    }
    
    vTrainingLabUsers 'Users' {
        Users = $activeDirectory.Users;
        Password = $Password;
        DomainName = $DomainName;
        FileServer = $FileServer;
        HomeDrive = $HomeDrive;
        ProfileShare = $ProfileShare;
        MandatoryProfileName = $MandatoryProfileName;
    }
    
    vTrainingLabGroups 'Groups' {
        Groups = $activeDirectory.Groups;
        Users = $activeDirectory.Users;
        DomainName = $DomainName;
    }
    
    #endregion Active Directory

    #region Group Policy
    vTrainingLabGPOs 'GPOs' {
        GPOBackupPath = $GPOBackupPath;
        GroupPolicyObjects = $activeDirectory.GPOs;
        DependsOn = '[vTrainingLabOUs]OUs';
    }
    #endregion Group Policy
    
    vTrainingLabFolders 'Folders' {
        Folders = $folders;
        Users = $activeDirectory.Users;
        Departments = $activeDirectory.Users | % { $_.Department } | Select -Unique;
    }
    
    vTrainingLabPrinters 'Printers' {
        Departments = $activeDirectory.Users | % { $_.Department } | Select -Unique;
    }
    
    if ($PSBoundParameters.ContainsKey('ThumbnailPhotoPath')) {
        vTrainingLabUserThumbnails 'UserThumbnails' {
            Users = $activeDirectory.Users;
            ThumbnailPhotoPath = $ThumbnailPhotoPath;
            DomainName = $DomainName;
            Extension = 'jpg';
        }   
    }
    
} #end configuration vTrainingLab

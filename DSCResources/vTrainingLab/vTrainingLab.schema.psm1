configuration vTrainingLab {
    param (
        ## Active Directory credentials (for DFS creation)
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

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

        ## Hostname for servicestore.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ServiceStoreHost = 'controller.lab.local',

        ## Hostname for catalogservices.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost = 'controller.lab.local',

        ## DFS root share
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DFSRoot = 'DFS',

        ## Hostname for storefront.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StorefrontHost = 'xenapp.lab.local',

        ## Hostname for smtp.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SmtpHost = 'exchange.lab.local',

        ## Directory path containing user thumbnail photos
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ThumbnailPhotoPath,

        ## Members to add to the 'Terminal Server License Servers' group
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $TerminalServerLicenseServers = 'CONTROLLER$'
    )

    ## Avoid recursive loading of the VirtualEngineTrainingLab composite resource
    Import-DscResource -Name vTrainingLabPasswordPolicy, vTrainingLabOUs, vTrainingLabUsers, vTrainingLabServiceAccounts;
    Import-DscResource -Name vTrainingLabGroups, vTrainingLabFolders, vTrainingLabDfs, vTrainingLabGPOs, vTrainingLabDns;
    Import-DscResource -Name vTrainingLabPrinters, vTrainingLabUserThumbnails;

    $folders = @(
        @{  Path = 'C:\DFSRoots'; }
        @{
            Path = 'C:\DFSRoots\{0}' -f $DFSRoot;
            Share = $DFSRoot;
            FullControl = 'BUILTIN\Administrators';
            ChangeControl = 'Everyone';
            Description = 'Distributed File System Root Share';
            DfsRoot = $true;
        }
        @{  Path = 'C:\SharedData'; }
        @{
            Path = 'C:\SharedData\App-V Content';
            Share = 'Content';
            Description = 'App-V packages';
            DfsPath = 'Content';
        }
        @{  Path = 'C:\SharedData\Company Share';
            Share = 'Company';
            FullControl = 'Everyone';
            ModifyNtfs = 'Users';
            Description = 'Company-wide shared information';
            DfsPath = 'Company';
        }
        @{ Path = 'C:\SharedData\Company Share\Documentation'; }
        @{ Path = 'C:\SharedData\Company Share\Media'; }
        @{ Path = 'C:\SharedData\Company Share\Portraits'; }
        @{ Path = 'C:\SharedData\Departmental Shares'; }
        @{
            Path = 'C:\SharedData\DTS';
            Share = 'DTS$';
            FullControl = 'Everyone';
            ModifyNtfs = 'Users';
            Description = 'RES ONE Workspace Desktop Sampler files';
            DfsPath = 'DTS';
        }
        @{
            Path = 'C:\SharedData\Profiles\Containers';
            Share = 'ProfileContainer$';
            FullControl = 'Everyone';
            FullControlNtfs = 'Users';
            Description = 'FSLogix Containers';
            DfsPath = 'ProfileContainers';
        }
        @{
            Path = 'C:\SharedData\Profiles\User Profiles';
            Share = 'Profile$';
            FullControl = 'Everyone';
            FullControlNtfs = 'Users';
            Description = 'User roaming profiles';
            DfsPath = 'Profiles';
        }
        @{
            Path = 'C:\SharedData\Profiles\TS Profiles';
            Share = 'TSProfile$';
            FullControl = 'Everyone';
            FullControlNtfs = 'Users';
            Description = 'User Terminal Services roaming profiles';
        }
        @{ Path = 'C:\SharedData\Scripts'; }
        @{
            Path = 'C:\SharedData\Software';
            Share = 'Software';
            FullControl = 'Everyone';
            Description = 'Software repository';
            DfsPath = 'Software';
        }
        @{
            Path = 'C:\SharedData\User Home Directories';
            Share = 'Home$';
            FullControl = 'Everyone';
            Description = 'User home folders';
            DfsPath = 'Home Folders';
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
                    @{ Name = 'Human Resources'; Path = 'OU=Users,OU=Training'; Description = 'HR departmental user accounts'; }
                    @{ Name = 'Information Technology'; Path = 'OU=Users,OU=Training'; Description = 'IT departmental user accounts'; }
                    @{ Name = 'Marketing'; Path = 'OU=Users,OU=Training'; Description = 'Marketing department user accounts'; }
                    @{ Name = 'Sales'; Path = 'OU=Users,OU=Training'; Description = 'Sales department user accounts'; }
        )

        GPOs = @{
            'Default Lab Policy' = @{ Link = $rootDN; Enabled = $true; }
            'Invoke Workspace Composer' = @{ Link = "OU=Servers,OU=Training,$rootDN"; Enabled = $false; }
        }

        Users = @(
            # Executive
            @{  SamAccountName = 'LOCAL05'; GivenName = 'Tony'; Surname = 'Stark';
                Telephone = '01234 567905'; Mobile = '07700 900440'; Fax = '01234 567899';
                JobTitle = 'Chief Executive Officer'; Department = 'Executive'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Executive,OU=Users,OU=Training'; ManagedBy = 'LOCAL05'; }

            # Engineering
            @{  SamAccountName = 'ROAM02'; GivenName = 'Gene'; Surname = 'Poole';
                Telephone = '01234 567894'; Mobile = '07700 900622'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Engineering Manager'; Department = 'Engineering'; Office = 'Medawar Centre'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Roaming'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'MAND01'; GivenName = 'Ann'; Surname = 'Thrax';
                Telephone = '01234 567900'; Mobile = '07700 900409'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Engineer'; Department = 'Engineering'; Office = 'Stark Tower'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'ROAM02'; }
            @{  SamAccountName = 'MAND05'; GivenName = 'Jack'; Surname = 'Hammer';
                Telephone = '01234 567904'; Mobile = '07700 900415'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Engineering Manager'; Department = 'Engineering'; Office = 'Medawar Centre'; Company = 'Stark Biotech';
                Path = 'OU=Engineering,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'ROAM02'; }

            # Finance
            @{  SamAccountName = 'LOCAL03'; GivenName = 'Robin'; Surname = 'Banks';
                Telephone = '01234 567891'; Mobile = '07700 900827'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Finance Director'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'ROAM04'; GivenName = 'Owen'; Surname = 'Cash';
                Telephone = '01234 567896'; Mobile = '07700 900468'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Credit Controller'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; ProfileType = 'Roaming'; ManagedBy = 'LOCAL03'; }
            @{  SamAccountName = 'MAND03'; GivenName = 'Chris'; Surname = 'Cross';
                Telephone = '01234 567902'; Mobile = '07700 900585'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Finance Clerk'; Department = 'Finance'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Finance,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'LOCAL03'; }

            # Information Technology
            @{  SamAccountName = 'ROAM01'; GivenName = 'Justin'; Surname = 'Case';
                Telephone = '01234 567893'; Mobile = '07700 900155'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'IT Manager'; Department = 'Information Technology'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Information Technology,OU=Users,OU=Training'; ProfileType = 'Roaming'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'ROAM05'; GivenName = 'Luke'; Surname = 'Warme';
                Telephone = '01234 567898'; Mobile = '07700 900872'; Fax = '01234 567899';
                Address = 'Oxford Science Park'; City = 'Oxford'; State = 'OXON'; PostCode = 'AB12 3CD'; Country = 'GB';
                JobTitle = 'Helpdesk Anaylst'; Department = 'Information Technology'; Office = 'Medawar Centre'; Company = 'Stark Industries';
                Path = 'OU=Information Technology,OU=Users,OU=Training'; ProfileType = 'Roaming'; ManagedBy = 'ROAM01'; }

            # Marketing
            @{  SamAccountName = 'LOCAL04'; GivenName = 'Mike'; Surname = 'Raffone';
                Telephone = '01234 567890'; Mobile = '07700 900738'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Marketing Manager'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'ROAM03'; GivenName = 'Claire'; Surname = 'Voyant';
                Telephone = '01234 567895'; Mobile = '07700 900009'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Graphic Artist'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; ProfileType = 'Roaming'; ManagedBy = 'LOCAL04'; }
            @{  SamAccountName = 'MAND02'; GivenName = 'Mona'; Surname = 'Lott';
                Telephone = '01234 567901'; Mobile = '07700 900576'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Copy Writer'; Department = 'Marketing'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Marketing,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'LOCAL04'; }

            # Sales
            @{  SamAccountName = 'LOCAL01'; GivenName = 'Warren'; Surname = 'Peace';
                Telephone = '01234 567892'; Mobile = '07700 900834'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Sales Director'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'LOCAL02'; GivenName = 'Lois'; Surname = 'Bidd';
                Telephone = '01234 567897'; Mobile = '07700 900747'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Account Manager'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; ManagedBy = 'LOCAL01'; }
            @{  SamAccountName = 'MAND04'; GivenName = 'Ollie'; Surname = 'Gark';
                Telephone = '01234 567903'; Mobile = '07700 900558'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'Account Manager'; Department = 'Sales'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Sales,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'LOCAL01'; }

            # HR
            @{  SamAccountName = 'LOCAL06'; GivenName = 'Ona'; Surname = 'Paar';
                Telephone = '01234 567906'; Mobile = '07700 900087'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'HR Director'; Department = 'HR'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Human Resources,OU=Users,OU=Training'; ManagedBy = 'LOCAL05'; }
            @{  SamAccountName = 'LOCAL07'; GivenName = 'Ally'; Surname = 'Monie';
                Telephone = '01234 567907'; Mobile = '07700 900249'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'HR Administrator'; Department = 'HR'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Human Resources,OU=Users,OU=Training'; ManagedBy = 'LOCAL06'; }
            @{  SamAccountName = 'LOCAL08'; GivenName = 'Hiram'; Surname = 'Cheaper';
                Telephone = '01234 567908'; Mobile = '07700 900304'; Fax = '01234 567899';
                Address = 'Columbus Circle'; City = 'New York'; State = 'NYC'; PostCode = '12345'; Country = 'US';
                JobTitle = 'HR Associate'; Department = 'HR'; Office = 'Stark Tower'; Company = 'Stark Industries';
                Path = 'OU=Human Resources,OU=Users,OU=Training'; ProfileType = 'Mandatory'; ManagedBy = 'LOCAL06'; }
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
            @{ Name = 'Engineering'; Path = 'OU=Groups,OU=Training'; Description = 'Engineering users'; Scope = 'Universal'; ManagedBy = 'ROAM02'; }
            @{ Name = 'Executive'; Path = 'OU=Groups,OU=Training'; Description = 'Executive users'; Scope = 'Universal'; ManagedBy = 'LOCAL05'; }
            @{ Name = 'Finance'; Path = 'OU=Groups,OU=Training'; Description = 'Finance users'; Scope = 'Universal'; ManagedBy = 'LOCAL03'; }
            @{ Name = 'Information Technology'; Path = 'OU=Groups,OU=Training'; Description = 'IT users'; Scope = 'Universal'; ManagedBy = 'ROAM01'; }
            @{ Name = 'Marketing'; Path = 'OU=Groups,OU=Training'; Description = 'Marketing users'; Scope = 'Universal'; ManagedBy = 'LOCAL04'; }
            @{ Name = 'Sales'; Path = 'OU=Groups,OU=Training'; Description = 'Sales users'; Scope = 'Universal'; ManagedBy = 'LOCAL01'; }
            @{ Name = 'HR'; Path = 'OU=Groups,OU=Training'; Description = 'Human Resources users'; Scope = 'Universal'; ManagedBy = 'LOCAL06'; }
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
            
            @{ Name = 'FSLogix ODFC'; Path = 'OU=Groups,OU=Training'; Description = 'FSLogix O365/OneDrive Container user accounts'; Scope = 'DomainLocal'; }
            @{ Name = 'FSLogix Profile Containers'; Path = 'OU=Groups,OU=Training'; Description = 'FSLogix Profile Container user accounts'; Scope = 'DomainLocal'; }
            
            ## Add RES AM Service Account to 'Domain Admins' group
            @{ Name = 'Domain Admins'; Path = 'CN=Users'; Members = 'RESAM'; }
            ## Add CONTROLLER to 'Terminal Server License Servers' group
            @{ Name = 'Terminal Server License Servers'; Path = 'CN=Builtin'; Members = $TerminalServerLicenseServers; Scope = 'DomainLocal'; }
        )

    } #end ActiveDirectory

    #region DNS
    vTrainingLabDns 'ReverseLookupAndCNames' {
        IPAddress           = $IPAddress;
        DomainName          = $DomainName;
        ServiceStoreHost    = $ServiceStoreHost;
        CatalogServicesHost = $CatalogServicesHost;
        StorefrontHost      = $StorefrontHost;
        SmtpHost            = $SmtpHost;
    }
    #endregion DNS

    #region Active Directory
    vTrainingLabPasswordPolicy 'PasswordPolicy' {
        DomainName = $DomainName;
    }

    vTrainingLabOUs 'OUs' {
        OUs        = $activeDirectory.OUs;
        DomainName = $DomainName;
    }

    vTrainingLabServiceAccounts 'ServiceAccounts' {
        ServiceAccounts = $activeDirectory.ServiceAccounts;
        Password   = $Password;
        DomainName = $DomainName;
    }

    vTrainingLabUsers 'Users' {
        Users                = $activeDirectory.Users;
        Password             = $Password;
        DomainName           = $DomainName;
        FileServer           = $FileServer;
        HomeDrive            = $HomeDrive;
        ProfileShare         = $ProfileShare;
        MandatoryProfileName = $MandatoryProfileName;
    }

    vTrainingLabGroups 'Groups' {
        Groups     = $activeDirectory.Groups;
        Users      = $activeDirectory.Users;
        DomainName = $DomainName;
    }

    #endregion Active Directory

    #region Group Policy
    vTrainingLabGPOs 'GPOs' {
        GPOBackupPath      = $GPOBackupPath;
        GroupPolicyObjects = $activeDirectory.GPOs;
        DependsOn          = '[vTrainingLabOUs]OUs';
    }
    #endregion Group Policy

    $departments = $activeDirectory.Users | % { $_.Department } | Select -Unique;

    vTrainingLabFolders 'Folders' {
        Folders     = $folders;
        Users       = $activeDirectory.Users;
        Departments = $departments;
    }

    vTrainingLabDfs 'Dfs' {
        Folders     = $folders;
        Credential  = $Credential;
        DFSRoot     = $DFSRoot;
        DomainName  = $DomainName;
        FileServer  = $FileServer;
        Departments = $departments;
    }

    vTrainingLabPrinters 'Printers' {
        Departments = $departments;
    }

    if ($PSBoundParameters.ContainsKey('ThumbnailPhotoPath')) {

        vTrainingLabUserThumbnails 'UserThumbnailPhotos' {
            Users              = $activeDirectory.Users;
            ThumbnailPhotoPath = $ThumbnailPhotoPath;
            DomainName         = $DomainName;
            Extension          = 'jpg';
        }

        vTrainingLabUserThumbnails 'ServiceAccountPhotos' {
            Users              = $activeDirectory.ServiceAccounts;
            ThumbnailPhotoPath = $ThumbnailPhotoPath;
            DomainName         = $DomainName;
            Filename           = 'ServiceAccount';
            Extension          = 'jpg';
        }

        vTrainingLabUserThumbnails 'AdministratorPhoto' {
            Users              = @{ SamAccountName = 'Administrator' }
            ThumbnailPhotoPath = $ThumbnailPhotoPath;
            DomainName         = $DomainName;
            Filename           = 'AdminAccount';
            Extension          = 'jpg';
        }
    }

} #end configuration vTrainingLab

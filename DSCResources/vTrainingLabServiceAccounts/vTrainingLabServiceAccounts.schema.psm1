configuration vTrainingLabServiceAccounts {
   param (
        ## Collection of service accounts
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $ServiceAccounts,

        ## Servuce account use password to set/enforce
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Password,

        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
   )

   $rootDN = ',DC={0}' -f $DomainName -split '\.' -join ',DC=';

   Import-DscResource -Module xActiveDirectory;

   foreach ($serviceAccount in $ServiceAccounts) {

        if ([System.String]::IsNullOrEmpty($serviceAccount.Path)) {
            $serviceAccountPath = $rootDN.TrimStart(',');
        }
        else {
            $serviceAccountPath = '{0}{1}' -f $serviceAccount.Path, $rootDN;
        }

        xADUser "xADUser_$($serviceAccount.SamAccountName)" {
            Path = $serviceAccountPath;
            CommonName = "$($serviceAccount.GivenName) $($serviceAccount.Surname)";
            UserName = $serviceAccount.SamAccountName;
            DomainName = $DomainName;
            Password = $Password;
            UserPrincipalName = "$($serviceAccount.SamAccountName)@$($DomainName)";
            GivenName = $serviceAccount.GivenName;
            Surname = $serviceAccount.Surname;
            DisplayName = "$($serviceAccount.GivenName) $($serviceAccount.Surname)";
            Description = $serviceAccount.Description;
            PasswordNeverExpires = $true;
        }

    } #end foreach service account

    ## Create default NetScaler user account
    $netScalerPassword = ConvertTo-SecureString -String 'Net5caler' -AsPlainText -Force;
    xADUser "xADUser_NetScaler" {
        ## Use the same DN/path as specified in the first account specified as this
        ## may be OU=Service Accounts,OU=Training or OU=Service Accounts,OU=Showcase.
        Path = '{0}{1}' -f $ServiceAccounts[0].Path, $rootDN;
        CommonName = 'NetScaler';
        UserName = 'NetScaler';
        DomainName = $DomainName;
        Password = New-Object System.Management.Automation.PSCredential('NetScaler', $netScalerPassword);
        UserPrincipalName = 'netscaler@{0}' -f $DomainName;
        GivenName = 'NetScaler';
        Surname = 'Service';
        DisplayName = 'NetScaler';
        Description = 'NetScaler Service Account';
        PasswordNeverExpires = $true;
    }

} #end configuration vTrainingLabServiceAccounts

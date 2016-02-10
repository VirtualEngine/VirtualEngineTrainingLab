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
} #end configuration vTrainingLabServiceAccounts

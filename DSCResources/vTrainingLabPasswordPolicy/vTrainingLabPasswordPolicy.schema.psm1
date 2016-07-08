configuration vTrainingLabPasswordPolicy {
    param (
        ## Domain root FQDN used to AD paths
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName,

        ## Whether password complexity is enabled for the default password policy
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $ComplexityEnabled = $false,

        ## Whether the directory must store passwords using reversible encryption
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $ReversibleEncryptionEnabled = $false,

        ## Minimum length of time that you can have the same password (minutes)
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $MinPasswordAge = 0,

        ## Maximum length of time that you can have the same password (minutes)
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $MaxPasswordAge = 0,

        ## Minimum number of characters that a password must contain
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $MinPasswordLength = 7,

        ## Number of previous passwords to remember
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $PasswordHistoryCount = 0,

        ## Domain credential
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -Module xActiveDirectory;

    if ($PSBoundParameters.ContainsKey('Credential')) {

        xADDomainDefaultPasswordPolicy 'DefaultDomainPasswordPolicy' {
            DomainName                  = $DomainName;
            ComplexityEnabled           = $ComplexityEnabled;
            ReversibleEncryptionEnabled = $ReversibleEncryptionEnabled;
            MinPasswordAge              = $MinPasswordAge;
            MaxPasswordAge              = $MaxPasswordAge;
            MinPasswordLength           = $MinPasswordLength;
            PasswordHistoryCount        = $PasswordHistoryCount;
            Credential                  = $Credential;
        }
    }
    else {

        xADDomainDefaultPasswordPolicy 'DefaultDomainPasswordPolicy' {
            DomainName                  = $DomainName;
            ComplexityEnabled           = $ComplexityEnabled;
            ReversibleEncryptionEnabled = $ReversibleEncryptionEnabled;
            MinPasswordAge              = $MinPasswordAge;
            MaxPasswordAge              = $MaxPasswordAge;
            MinPasswordLength           = $MinPasswordLength;
            PasswordHistoryCount        = $PasswordHistoryCount;
        }
    }

} #end configuration vTrainingLabPasswordPolicy

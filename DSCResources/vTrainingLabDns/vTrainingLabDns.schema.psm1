configuration vTrainingLabDns {
    param (
        ## IP address used to calculate reverse lookup zone name
        [Parameter(Mandatory)]
        [System.String] $IPAddress,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',
        
        ## Hostname for itstore.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ITStoreHost = 'controller',
        
        ## Hostname for storefront.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $StorefrontHost = 'xenapp',
        
        ## Hostname for storefront.$DomainName CNAME
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $SmtpHost = 'exchange'
    )
    
    Import-DscResource -Module xDnsServer;
    
    if (-not $ITStoreHost.Contains('.')) {
        $ITStoreHost = '{0}.{1}' -f $ITStoreHost, $DomainName;
    }
    
    xDnsRecord 'itstore_CName' {
        Name = 'itstore';
        Zone = $DomainName;
        Target = $ITStoreHost;
        Type = 'CName';
        Ensure = 'Present';
    }
    
    if (-not $StorefrontHost.Contains('.')) {
        $StorefrontHost = '{0}.{1}' -f $StorefrontHost, $DomainName;
    }
    
    xDnsRecord 'storefront_CName' {
        Name = 'storefront';
        Zone = $DomainName;
        Target = $StorefrontHost;
        Type = 'CName';
        Ensure = 'Present';
    }
    
    if (-not $SmtpHost.Contains('.')) {
        $SmtpHost = '{0}.{1}' -f $SmtpHost, $DomainName;
    }
    
    xDnsRecord 'smtp_CName' {
        Name = 'smtp';
        Zone = $DomainName;
        Target = $SmtpHost;
        Type = 'CName';
        Ensure = 'Present';
    }
    
    if ($IPAddress.EndsWith('.in-addr.arpa')) {
        xDnsServerPrimaryZone 'ReverseLookup' {
            Name = $IPAddress;
            DynamicUpdate = 'NonsecureAndSecure';
        }
    }
    else {
        $ipQuartets = $IPAddress.Split('.');
        xDnsServerPrimaryZone 'ReverseLookup' {
            Name = '{0}.{1}.{2}.in-addr.arpa' -f $ipQuartets[2], $ipQuartets[1], $ipQuartets[0];
            DynamicUpdate = 'NonsecureAndSecure';
        }
    }
    
} #end configuration vTrainingLabDns

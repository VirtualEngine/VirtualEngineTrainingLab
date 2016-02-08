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
        [System.String] $ITStoreHost = 'controller'
    )
    
    Import-DscResource -Module xDnsServer;
    
    if (-not $ITStoreHost.Contains('.')) {
        $ITStoreHost = '{0}.{1}' -f $ITStoreHost, $DomainName;
    }
    
    xDnsRecord itstore_CName {
        Name = 'itstore.{0}' -f $DomainName;
        Zone = $DomainName;
        Target = $ITStoreHost;
        Type = 'CName';
        Ensure = 'Present';
    }
    
    if ($IPAddress.EndsWith('.in-addr.arpa')) {
        xDnsServerPrimaryZone ReverseLookup {
            Name = $IPAddress;
            DynamicUpdate = 'NonsecureAndSecure';
        }
    }
    else {
        $ipSubnetQuartets = $IPAddress.Split('.');
        xDnsServerPrimaryZone ReverseLookup {
            Name = '{0}.{1}.{2}.in-addr.arpa' -f $ipQuartets[2], $ipQuartets[1], $ipQuartets[0];
            DynamicUpdate = 'NonsecureAndSecure';
        }
    }
    
} #end configuration vTrainingLabDns

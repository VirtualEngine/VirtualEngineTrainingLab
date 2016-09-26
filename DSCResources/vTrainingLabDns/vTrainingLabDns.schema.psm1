configuration vTrainingLabDns {
    param (
        ## IP address used to calculate reverse lookup zone name
        [Parameter(Mandatory)]
        [System.String] $IPAddress,

        ## Domain root FQDN used to AD paths
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',

        ## Hostname for servicestore.$DomainName CNAME
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('ITStoreHost')]
        [System.String] $ServiceStoreHost = 'controller',

        ## Hostname for catalogservices.$DomainName CNAME
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost = 'controller',

        ## Hostname for storefront.$DomainName CNAME
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $StorefrontHost = 'xenapp',

        ## Hostname for storefront.$DomainName CNAME
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $SmtpHost = 'exchange'
    )

    Import-DscResource -Module xDnsServer;

    if (-not $ServiceStoreHost.Contains('.')) {
        $ServiceStoreHost = '{0}.{1}' -f $ServiceStoreHost, $DomainName;
    }

    xDnsRecord 'servicestore_CName' {
        Name = 'servicestore';
        Zone = $DomainName;
        Target = $ServiceStoreHost;
        Type = 'CName';
        Ensure = 'Present';
    }

    if (-not $CatalogServicesHost.Contains('.')) {
        $CatalogServicesHost = '{0}.{1}' -f $CatalogServicesHost, $DomainName;
    }

    xDnsRecord 'catalogservices_CName' {
        Name = 'catalogservices';
        Zone = $DomainName;
        Target = $CatalogServicesHost;
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

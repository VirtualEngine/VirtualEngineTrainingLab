configuration vTrainingLabOUs {
    param (
        ## Collection of organisational units
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $OUs,
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local'
    )
    
    $rootDN = ',DC={0}' -f $DomainName -split '\.' -join ',DC=';
    
    Import-DscResource -Module xActiveDirectory;
    
    foreach ($ou in $OUs) {
            
        if ([System.String]::IsNullOrEmpty($ou.Path)) { $ouPath = $rootDN.TrimStart(','); }
        else { $ouPath = '{0}{1}' -f $ou.Path, $rootDN; }
        
        xADOrganizationalUnit "xADOrganizationalUnit_$($ou.Name)" {
            Name = $ou.Name;
            Path = $ouPath;
            Description = $ou.Description;
        }
        
    } #end foreach ou

} #end configuration vTrainingLabOUs

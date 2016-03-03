configuration vTrainingLabExchange {
    param (
        ## Credential used to connect to the Exchange remoting end-point
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Search base for users. All mail-disabled users under this DN will be mail-enabled
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $UserSearchBase = 'ou=Users,ou=Training,dc=lab,dc=local',
        
        ## Search base for groups. All mail-disabled universal security groups under this DN will be mail-enabled
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $GroupSearchBase = 'ou=Groups,ou=Training,dc=lab,dc=local',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainController = 'controller.lab.local',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $OrganizationAdministrators = 'Domain Admins'
        
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory;
    
    ## Cannot pass credentials via $using: ...
    $Username = $Credential.UserName;
    $Password = $Credential.GetNetworkCredential().Password;
    
    Script 'MailEnableUniversalGroups' {
        GetScript = {
            $enabledGroups = Get-ADGroup -SearchBase $using:GroupSearchBase -Filter { Mail -like '*' } |
                Select-Object -ExpandProperty SamAccountName;
            $targetResource = @{ Result = ''; }
            if ($enabledGroups) {
                $targetResource['Result'] = $enabledGroups -join ','; 
            }
            return $targetResource;
        } #end get script
    
        TestScript = {
            $disabledGroups = Get-ADGroup -SearchBase $using:GroupSearchBase -Filter { GroupScope -eq 'Universal' -and Mail -notlike '*' };
            if ($disabledGroups.Count -and ($disabledGroups.Count -gt 0)) {
                Write-Verbose ('Mail-disabled AD group count ''{0}''.' -f $disabledGroups.Count);
                Write-Verbose ('Resource is NOT in the desired state.');
                return $false;
            }
            else {
                Write-Verbose ('Resource is in the desired state.');
                return $true;
            }
        } #end test script
    
        SetScript = {
            $serverName = ('{0}.{1}' -f $env:COMPUTERNAME, (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).Domain).ToLower();
            $sessionName = 'vTrainingLabExchange';
            $commandNames = 'Enable-DistributionGroup';
            $newCredential = New-Object PSCredential $using:Username, (ConvertTo-SecureString -String $using:Password -AsPlainText -Force);
            $session = Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue;

            if ($null -eq $session) {
                New-Alias -Name Get-ExBanner -Value Out-Null;
                New-Alias -Name Get-Tip -Value Out-Null;
                . "$env:ProgramFiles\Microsoft\Exchange Server\V15\Bin\RemoteExchange.ps1";
                
                $session = _NewExchangeRunspace -fqdn $serverName -Credential $newCredential -UseWIA $false -AllowRedirection $false
                $session.Name = $sessionName;
            }

            $moduleInfo = Import-PSSession -Session $session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -CommandName $commandNames -Verbose:$false;
            Import-Module $moduleInfo -Global -DisableNameChecking -Verbose:$false;

            Get-ADGroup -SearchBase $using:GroupSearchBase -Filter { GroupScope -eq 'Universal' -and Mail -notlike '*' } |
                ForEach-Object {
                    $alias = $_.Name.ToLower().Replace(' ','');
                    Write-Verbose ('Mail-enabling universal group ''{0}'' ({1}).' -f $_.DistinguishedName, $alias);
                    Enable-DistributionGroup -Identity $_.DistinguishedName -Alias $alias;
                }
        } #end set script
    } #end script 'MailEnableUniversalGroups'
    
    Script 'MailEnableUsers' {
        GetScript = {
            $enabledUsers = Get-ADUser -SearchBase $using:UserSearchBase -Filter { Mail -like '*' } |
                Select-Object -ExpandProperty SamAccountName;
            $targetResource = @{ Result = ''; }
            if ($enabledUsers) {
                $targetResource['Result'] = $enabledUsers -join ','; 
            }
            return $targetResource;
        } #end get script
    
        TestScript = {
            $disabledUsers = Get-ADUser -SearchBase $using:UserSearchBase -Filter { Mail -notlike '*' };
            if ($disabledUsers.Count -and ($disabledUsers.Count -gt 0)) {
                Write-Verbose ('Mail-disabled AD user count ''{0}''.' -f $disabledUsers.Count);
                Write-Verbose ('Resource is NOT in the desired state.');
                return $false;
            }
            else {
                Write-Verbose ('Resource is in the desired state.');
                return $true;
            }
        } #end test script
    
        SetScript = {
            $serverName = ('{0}.{1}' -f $env:COMPUTERNAME, (Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false).Domain).ToLower();
            $sessionName = 'vTrainingLabExchange';
            $commandNames = 'Enable-Mailbox';
            $newCredential = New-Object PSCredential $using:Username, (ConvertTo-SecureString -String $using:Password -AsPlainText -Force);
            $session = Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue;

            if ($null -eq $session) {
                New-Alias -Name Get-ExBanner -Value Out-Null;
                New-Alias -Name Get-Tip -Value Out-Null;
                . "$env:ProgramFiles\Microsoft\Exchange Server\V15\Bin\RemoteExchange.ps1";
                
                $session = _NewExchangeRunspace -fqdn $serverName -Credential $newCredential -UseWIA $false -AllowRedirection $false
                $session.Name = $sessionName;
            }

            $moduleInfo = Import-PSSession -Session $session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -CommandName $commandNames -Verbose:$false;
            Import-Module $moduleInfo -Global -DisableNameChecking -Verbose:$false;

            Get-ADUser -SearchBase $using:UserSearchBase -Filter { Mail -notlike '*' } |
                ForEach-Object {
                    $alias = ($_.UserPrincipalName.Split('@')[0]).ToLower();
                    Write-Verbose ('Enabling mailbox ''{0}'' ({1}).' -f $_.UserPrincipalName, $alias);
                    Enable-Mailbox -Identity $_.UserPrincipalName -Alias $alias;
                }
        } #end set script
    } #end script MailEnableUsers
    
    xADGroup 'OrganisationAdmins' {
        GroupName = 'Organization Management';
        GroupScope = 'Universal';
        Credential = $Credential;
        DomainController = $DomainController;
        MembersToInclude = $OrganizationAdministrators;
    }

} #end configuration vTrainingLabExchange

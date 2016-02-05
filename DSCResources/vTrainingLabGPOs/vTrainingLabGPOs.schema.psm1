configuration vTrainingLabGPOs {
    param (
        ## Folder containing GPO backup files
        [Parameter(Mandatory)]
        [System.String] $GPOBackupPath,
        
        ## Hashtable containing GPO names and link information
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $GroupPolicyObjects
    )
    
    <#  Example hashtable configuration
        @{
            'Default Domain Policy' = @{ };
            'Default Lab Policy' = @{ Link = 'dc=lab,dc=local'; Enabled = $true; }
            'Invoke Workspace Composer' = @{ Link = 'ou=Servers,ou=Training,dc=lab,dc=local','ou=Computers,ou=Training,dc=lab,dc=local'; Enabled = $false; }
        }
    #>
    
    Import-DscResource -Module PSDesiredStateConfiguration;
    
    Script TrainingLabGPOs {
        GetScript = {
            return @{ Result = $using:GPOBackupPath; }
        } #end get script

        TestScript = {
            $gpos = $using:GroupPolicyObjects;
            $isCompliant = $true;
            foreach ($gpo in $gpos.Keys) {
                $groupPolicyObject = Get-GPO -Name $gpo -ErrorAction SilentlyContinue;
                if (-not $groupPolicyObject) {
                    Write-Verbose ('Missing GPO ''{0}''.' -f $gpo);
                    $isCompliant = $false;
                }
                elseif ($gpos[$gpo].Link) {
                    foreach ($gpoLink in $gpos[$gpo].Link) {
                        $existingGpoLinks = Get-ADObject -Filter { DistinguishedName -eq $gpoLink } -Properties name, distinguishedName, gPLink, gPOptions -ErrorAction SilentlyContinue;
                        $gpoRegex = '\[LDAP:\/\/cn={{{0}}},cn=policies,cn=system,DC=lab,DC=local;\d\]' -f $groupPolicyObject.Id;
                        $validGpoLink = $existingGpoLinks | Where gpLink -match $gpoRegex;
                        $linkEnabled = if ($gpos[$gpo].Enabled -eq $true) { 'Yes' } else { 'No' }

                        if (-not $validGpoLink) {
                            Write-Verbose ('Missing GPO ''{0}'' link to ''{1}''.' -f $gpo, $gpoLink);
                            $isCompliant = $false;
                        }
                        else {
                            ## Check link enabled/disabled
                            $gpoDisabledRegex = '(?<=\[LDAP:\/\/cn={{{0}}},cn=policies,cn=system,DC=lab,DC=local;)\d(?=\])' -f $groupPolicyObject.Id;
                            $linkEnabled = if ($gpos[$gpo].Enabled -eq $true) { 'Yes' } else { 'No' };
                            [bool] $gpoEnabled = -not $linkEnabled;
                            if ($existingGpoLinks.gpLink -match $gpoDisabledRegex) {
                                [bool] $gpoEnabled = $matches.Values -eq 0;
                            }
                            if ($gpoEnabled -ne $gpos[$gpo].Enabled) {
                                Write-Verbose ('GPO ''{0}'' link enabled is ''{1}'', expected ''{2}''.' -f $gpo, $gpoEnabled, $gpos[$gpo].Enabled);
                                $isCompliant = $false;
                            }
                        }
                    } #end foreach link
                } #end if link 
            } #end foreach gpo
            return $isCompliant;
        } #end test script

        SetScript = {
            $gpoBackupPath = $using:GPOBackupPath;
            $gpos = $using:GroupPolicyObjects;
            foreach ($gpo in $gpos.Keys) {
                $groupPolicyObject = Get-GPO -Name $gpo -ErrorAction SilentlyContinue;
                if (-not $groupPolicyObject) {
                    Write-Verbose ('Importing GPO ''{0}''.' -f $gpo);
                    $groupPolicyObject = Import-GPO -BackupGpoName $gpo -Path $gpoBackupPath -TargetName $gpo -CreateIfNeeded;
                }
                if ($gpos[$gpo].Link) {
                    foreach ($gpoLink in $gpos[$gpo].Link) {
                        $existingGpoLinks = Get-ADObject -Filter { DistinguishedName -eq $gpoLink } -Properties name, distinguishedName, gPLink, gPOptions -ErrorAction SilentlyContinue;
                        $validGpoLink = $existingGpoLinks | Where gpLink -match $groupPolicyObject.Id;
                        $linkEnabled = if ($gpos[$gpo].Enabled -eq $true) { 'Yes' } else { 'No' }
                        if ($validGpoLink) {
                            Write-Verbose ('Updating GPO ''{0}'' link to ''{1}''.' -f $gpo, $gpoLink);
                            [ref] $null = Set-GPLink -Guid $groupPolicyObject.Id -Target $gpoLink -LinkEnabled $linkEnabled;
                        }
                        else {
                            Write-Verbose ('Creating GPO ''{0}'' link to ''{1}''.' -f $gpo, $gpoLink);
                            [ref] $null = New-GPLink -Guid $groupPolicyObject.Id -Target $gpoLink -LinkEnabled $linkEnabled;
                        }

                    } #end foreach link
                } #end if link 
            } #end foreach gpo
        } #end set script

} #end configuration vTrainingLabGPOs

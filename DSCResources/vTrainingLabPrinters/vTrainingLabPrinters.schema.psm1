configuration vTrainingLabPrinters {
    param (
        ## List of department names
        [Parameter(Mandatory)]
        [System.String[]] $Departments
    )
    
    Import-DscResource -Module PrinterManagement;
    
    PrinterDriver 'MicrosoftXPSClassDriver' {
        DriverName = 'Microsoft XPS Class Driver';
    }
    
    foreach ($departmentName in $Departments) {
        Printer "$($departmentName)Printer" {
            Name = '{0} Printer' -f $departmentName;
            DriverName = 'Microsoft XPS Class Driver';
            PortName = 'PORTPROMPT:';
            Comment = '{0} Printer' -f $departmentName;
            ShareName = '{0} Printer' -f $departmentName;
            Published = $true;
            DependsOn = '[PrinterDriver]MicrosoftXPSClassDriver';
        }
    } #end foreach department

} #end configuration vTrainingLabPrinters

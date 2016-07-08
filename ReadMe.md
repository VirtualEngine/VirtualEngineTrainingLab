The VirtualEngineTrainingLab composite DSC resources can be used to create the Virtual Engine standardised
Active Directory training environment. This module contains the following DSC resources:

### Included Resources
* vTrainingLab
 * Creates the training folders, file shares, OUs, users, service accounts and groups.
* vTrainingLabDfs
 * Creates the training lab DFS root and folder namespaces.
* vTrainingLabDns
 * Creates the training lab DNS aliases and reverse DNS lookup zone.
* vTrainingLabExchange
 * Mail-enables users and universal security groups.
* vTrainingLabFolders
 * Creates the training folders and file shares.
* vTrainingLabGPOs
 * Restores training lab GPOs from a backup.
* vTrainingLabGroups
 * Creates the training Active Directory groups.
* vTrainingLabOUs
 * Creates the training Active Directory organisational units.
* vTrainingLabPasswordPolicy
 * Configures the default training lab Active Directory domain password policy.
* vTrainingLabPrepare
 * Creates the training lab seal/preparation script.
* vTrainingLabPrinters
 * Creates the shared department printers.
* vTrainingLabScheduledTasks
 * Manages the built-in maintenance scheduled tasks.
* vTrainingLabServiceAccounts
 * Creates the training Active Directory service accounts.
* vTrainingLabUsers
 * Creates the training Active Directory users.
* vTrainingLabUserThumbnails
 * Adds training Active Directory user thumbnails/pictures.

### Requirements
There are __dependencies__ on the following DSC resources:

* xSmbShare - https://github.com/PowerShell/xSmbShare
* xActiveDirectory - https://github.com/PowerShell/xActiveDirectory
* PrinterManagement - https://github.com/VirtualEngine/PrinterManagement
* PowerShellAccessControl - https://github.com/rohnedwards/PowerShellAccessControl
* VirtualEngineLab - https://github.com/VirtualEngine/VirtualEngineLab

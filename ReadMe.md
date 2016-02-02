The VirtualEngineTrainingLab composite DSC resources can be used to create the Virtual Engine standardised
Active Directory training environment. This module contains the following DSC resources:

###Included Resources
* vTrainingLab
 * Creates the training folders, file shares, OUs, users, service accounts and groups.
* vTrainingLabFolders
 * Creates the training folders and file shares.
* vTrainingLabGroups
 * Creates the training Active Directory groups.
* vTrainingLabOUs
 * Creates the training Active Directory organisational units.
* vTrainingLabServiceAccounts
 * Creates the training Active Directory service accounts.
* vTrainingLabUsers
 * Creates the training Active Directory users.

###Requirements
There are __dependencies__ on the following DSC resources:

* xSmbShare - https://github.com/PowerShell/xSmbShare
* xActiveDirectory - https://github.com/PowerShell/xActiveDirectory

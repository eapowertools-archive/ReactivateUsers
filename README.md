# Status
[![Project Status: Unsupported – The project has reached a stable, usable state but the author(s) have ceased all work on it. A new maintainer may be desired.](https://www.repostatus.org/badges/latest/unsupported.svg)](https://www.repostatus.org/#unsupported)

# ReactivateUsers
Sets __ALL__ Inactive Users in Qlik Sense to Active

## SYNOPSIS
Reactivates __ALL__ users in a Qlik Sense Site that have been set to inactive and removed externally.
## DESCRIPTION
Connects to the Qlik Sense Repository using the QRS API.  A POST selection call is run with a filter on inactive eq true, then a PUT on the selection is made to change the properties to false.
## EXAMPLE
Reactivate-QlikUsers %senseServerHostName%  %certFriendlyName%
## EXAMPLE
Reactivate-QlikUsers sense3.112adams.local QlikClient
## Parameter senseServerHostName
The name of the Qlik Sense server.
## Parameter certFriendlyName
The friendly name of the Qlik Sense generated certificate used to connect to the QRS api.  By default, enter QlikClient.  ***See note below.***

***This Code defaults to using the CurrentUser certificate store and prefers using the QlikClient certificate.
The QlikClient certificate is installed for the service account user set up during Qlik Sense installation.***

## DIRECTIONS
1. Download the ps1 file to the Qlik Sense server Central Node.
2. Run the script as the Qlik Sense service account user so that the QlikClient certificate can be used.
3. If prompted to disable signing of Powershell scripts, follow the directions on this page     
__[Set Execution Policy for Powershell Scripts](https://github.com/eapowertools/ReactivateUsers/wiki/Changing-Execution-Signing-Policy-in-Powershell)__.

Below is an example of running the script.
![pic](https://github.com/eapowertools/ReactivateUsers/blob/master/ExampleScreenShot.png?raw=true)

<#
.SYNOPSIS
Reactivates all users in a Qlik Sense Site that have been set to inactive and removed externally.
.DESCRIPTION
Connects to the Qlik Sense Repository using the QRS API.  A POST selection call is run with a filter on inactive eq true, then a PUT on the selection is made to change the properties to false.
.EXAMPLE
Reactivate-QlikUsers %senseServerHostName%  %certFriendlyName%
.EXAMPLE
Reactivate-QlikUsers sense3.112adams.local QlikClient
.Parameter senseServerHostName
The name of the Qlik Sense server.
.Parameter certFriendlyName
The friendly name of the Qlik Sense generated certificate used to connect to the QRS api.

This Code defaults to using the CurrentUser certificate store and prefers using the QlikClient certificate.  The QlikClient certificate is installed for the service account user set up during Qlik Sense installation.

#>

[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$senseServerHostName,
        [Parameter(Mandatory=$true)][string]$certFriendlyName
        )

    <# Hardcoded Parameters to make things move faster when testing
    request parameters in command line can be uncommented above and then
    comment below 
    $senseServerHostName = "https://%senseServerHostName%"
    $senseVirtualProxy = "%VirtualProxyPrefix%"
    $virtualProxyHeader = "%HeaderName%"
    $userId = "%Admin User%"
    $certFriendlyName = "%certFriendlyName%"
    #>

    #Find Certificate
    $ns = "System.Security.Cryptography.X509Certificates"
    $store = New-Object "$ns.X509Store"("My","CurrentUser")

    $store.Open("ReadOnly")

    ForEach($cert in $store.Certificates)
    {
        if($cert.FriendlyName -eq $certFriendlyName)
        {
            $certToUse = $cert
        }
    }

    $protocol = "https://"
    $senseServerHostName = $protocol + $senseServerHostName + ":4242"

function QRSConnect {

        param (
            [Parameter(Position=0,Mandatory=$true)]
            [string] $command,
            [Parameter(Position=1,Mandatory=$true)]
            [System.Collections.Generic.Dictionary`2[System.String,System.String]] $header,
            [Parameter(Position=2,Mandatory=$true)]
            [string] $method,
            [Parameter(Position=3,Mandatory=$true)]
            [System.Object] $cert,
            [Parameter(Position=4,Mandatory=$false)]
            [System.Object] $body
            )

        
        $contenttype = "application/json"
        if($method -eq "PUT")
        {
            $response = Invoke-RestMethod $command -ContentType $contenttype -Headers $header -Method $method -Certificate $cert -Body $body
        }
        else
        {
            $response = Invoke-RestMethod $command -Headers $header -Method $method -Certificate $cert
        }

        return $response
    }

    # cross site scripting key
    $xrfKey = "ABCDEFG123456789"

    # Create a dictionary object that allows header storage in Rest call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Qlik-Xrfkey",$xrfKey)
    $headers.Add("X-Qlik-User", "UserDirectory=internal;UserId=sa_repository")

    
    #Get a selection object for all inactive users
    $filter = "&filter=inactive eq true"
    $path = "/selection/user?xrfkey=$xrfKey"
    $theCommand = $senseServerHostName + "/qrs" + $path + $filter

    $selection = QRSConnect $theCommand $headers "POST" $certToUse
    
    Write-Host $selection.id

    $path = "/selection/" + $selection.id + "/user/synthetic?xrfkey=$xrfKey"
    $theCommand = $senseServerHostName + "/qrs" + $path

    $modDate = (Get-Date).AddDays(1)
    $modDate = Get-Date -Date $modDate -format s

    Write-Host $modDate
    
    $body = "{
	'properties':
	[
		{
			'name':'inactive',
			'value':false,
			'valueIsDifferent':true,
			'valueIsModified':true
			
		},
		{
			'name':'removedExternally',
			'value':false,
			'valueIsDifferent':true,
			'valueIsModified':true
			
		}
	],
	'type':'User',
	'latestModifiedDate':'$modDate.999Z'
}"

    Write-Host $body

    QRSConnect $theCommand $headers "PUT" $certToUse $body

    $path = "/selection/" + $selection.id + "?xrfkey=$xrfKey"
    $theCommand = $senseServerHostName + "/qrs" + $path

    QRSConnect $theCommand $headers "DELETE" $certToUse $body
    
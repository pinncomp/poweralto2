###############################################################################
## Start Powershell Cmdlets
###############################################################################


###############################################################################
# Clear-PaSession
function Clear-PaSession {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ParameterSetName="Id",Position=0)]
        [int]$Id,
		
        # Filter Fields
		[Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Application,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Destination,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [int]$DestinationPort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$EgressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$HardwareInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$IngressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$MinKb,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Nat,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$NatRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$PbfRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Protocol,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosClass,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosNodeId,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [switch]$Rematch,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SecurityRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Source,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourcePort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SslDecrypt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [double]$StartAt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$State,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Type,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$VsysName
    )

    $ReturnObject = @()
    
    $FilterString = ""
    
    $FilterHash = @{ "application"       = $Application
                     "destination"       = $Destination
                     "destination-port"  = $DestinationPort
                     "destination-user"  = $DestinationUser
                     "egress-interface"  = $EgressInterface
                     "from"              = $SourceZone
                     "hw-interface"      = $HardwareInterface
                     "ingress-interface" = $IngressInterface
                     "min-kb"            = $MinKb
                     "nat"               = $Nat
                     "nat-rule"          = $NatRule
                     "pbf-rule"          = $PbfRule
                     "protocol"          = $Protocol
                     "qos-class"         = $QosClass
                     "qos-node-id"       = $QosNodeId
                     "qos-rule"          = $QosRule
                     "rule"              = $SecurityRule
                     "source"            = $Source
                     "source-port"       = $SourcePort
                     "source-user"       = $SourceUser
                     "ssl-decrypt"       = $SslDecrypt
                     "start-at"          = $StartAt
                     "state"             = $State
                     "to"                = $DestinationZone
                     "type"              = $Type
                     "vsys-name"         = $VsysName }
    
    if ($Rematch) { $FilterHash += @{ "rematch" = "security-policy" } }
    
    foreach ($Filter in $FilterHash.GetEnumerator()) {
        if ($Filter.Value) {
            $FilterString += "<" + [string]$Filter.Name + ">"
            $FilterString += $Filter.Value
            $FilterString += "</" + [string]$Filter.Name + ">"
        }
    }

    if ($Id) {
        $Command = "<clear><session><id>$Id</id></session></clear>"
    } elseif ($FilterString -ne "") {
        $Command = "<clear><session><all><filter>$FilterString</filter></all></session></clear>"
    } else {
        Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command
    
    switch ($ResponseData.member) {
        "sessions cleared" {
            $ReturnObject = $true
        }
        default {
            $ReturnObject = $false
        }
    }

    return $ReturnObject
}

###############################################################################
# Connect-PaDevice
function Connect-PaDevice {
    [CmdletBinding()]
	<#
	.SYNOPSIS
		Establishes initial connection to Palo Alto API.
		
	.DESCRIPTION
		The Get-PaDevice cmdlet establishes and validates connection parameters to allow further communications to the Palo Alto API. The cmdlet needs at least two parameters:
		 - The device IP address or FQDN
		 - A valid API key
		
		
		The cmdlet returns an object containing details of the connection, but this can be discarded or saved as desired; the returned object is not necessary to provide to further calls to the API.
	
	.EXAMPLE
		Get-PaDevice "pa.example.com" "LUFRPT1PR2JtSDl5M2tjTktBeTkyaGZMTURTTU9BZm89OFA0Rk1WMS8zZGtKN0F"
		
		Connects to PRTG using the default port (443) over SSL (HTTPS) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer "prtg.company.com" "jsmith" 1234567890 -HttpOnly
		
		Connects to PRTG using the default port (80) over SSL (HTTP) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer -Server "monitoring.domain.local" -UserName "prtgadmin" -PassHash 1234567890 -Port 8080 -HttpOnly
		
		Connects to PRTG using port 8080 over HTTP using the username "prtgadmin" and the passhash 1234567890.
		
	.PARAMETER Server
		Fully-qualified domain name for the PRTG server. Don't include the protocol part ("https://" or "http://").
		
	.PARAMETER UserName
		PRTG username to use for authentication to the API.
		
	.PARAMETER PassHash
		PassHash for the PRTG username. This can be retrieved from the PRTG user's "My Account" page.
	
	.PARAMETER Port
		The port that PRTG is running on. This defaults to port 443 over HTTPS, and port 80 over HTTP.
	
	.PARAMETER HttpOnly
		When specified, configures the API connection to run over HTTP rather than the default HTTPS.
		
	.PARAMETER Quiet
		When specified, the cmdlet returns nothing on success.
	#>

	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
		[string]$Device,

        [Parameter(ParameterSetName="keyonly",Mandatory=$True,Position=1)]
        [string]$ApiKey,

        [Parameter(ParameterSetName="credential",Mandatory=$True,Position=1)]
        [pscredential]$Credential,

		[Parameter(Mandatory=$False,Position=2)]
		[int]$Port = $null,

		[Parameter(Mandatory=$False)]
		[alias('http')]
		[switch]$HttpOnly,
		
		[Parameter(Mandatory=$False)]
		[alias('q')]
		[switch]$Quiet
	)

    BEGIN {

		if ($HttpOnly) {
			$Protocol = "http"
			if (!$Port) { $Port = 80 }
		} else {
			$Protocol = "https"
			if (!$Port) { $Port = 443 }
			
			$global:PaDeviceObject = New-Object Poweralto.PaDevice
			
			$global:PaDeviceObject.Protocol = $Protocol
			$global:PaDeviceObject.Port     = $Port
			$global:PaDeviceObject.Device   = $Device

            if ($ApiKey) {
                $global:PaDeviceObject.ApiKey = $ApiKey
            } else {
                $UserName = $Credential.UserName
                $Password = $Credential.getnetworkcredential().password
            }
			
			$global:PaDeviceObject.OverrideValidation()
		}
    }

    PROCESS {
        
        if (!($ApiKey)) {
            $QueryStringTable = @{ type     = "keygen"
                                   user     = $UserName
                                   password = $Password }

            $QueryString = HelperCreateQueryString $QueryStringTable
			Write-Debug $QueryString
		    $url         = $global:PaDeviceObject.UrlBuilder($QueryString)

		    try   { $QueryObject = $global:PaDeviceObject.HttpQuery($url) } `
            catch {	throw $_.Exception.Message	           }

            $Data                  = HelperCheckPaError $QueryObject
            $global:PaDeviceObject.ApiKey = $Data.key
        }
        
        $QueryStringTable = @{ type = "op"
                               cmd  = "<show><system><info></info></system></show>" }

        $QueryString = HelperCreateQueryString $QueryStringTable
        Write-Debug "QueryString: $QueryString"
		$url         = $global:PaDeviceObject.UrlBuilder($QueryString)
        Write-Debug "URL: $Url"

		try   { $QueryObject = $global:PaDeviceObject.HttpQuery($url) } `
        catch {	throw $_.Exception.Message       	           }

        $Data = HelperCheckPaError $QueryObject
		$Data = $Data.system

        $global:PaDeviceObject.Name            = $Data.hostname
        $global:PaDeviceObject.Model           = $Data.model
        $global:PaDeviceObject.Serial          = $Data.serial
        $global:PaDeviceObject.OsVersion       = $Data.'sw-version'
        if ($global.PaDeviceObject.Type -eq "firewall") {
            $global:PaDeviceObject.GpAgent         = $Data.'global-protect-client-package-version'
            $global:PaDeviceObject.AppVersion      = $Data.'app-version'
            $global:PaDeviceObject.ThreatVersion   = $Data.'threat-version'
            $global:PaDeviceObject.WildFireVersion = $Data.'wildfire-version'
            $global:PaDeviceObject.UrlVersion      = $Data.'url-filtering-version'
        } else {
            
        }

        #$global:PaDeviceObject = $PaDeviceObject

		
		if (!$Quiet) {
			return $global:PaDeviceObject | Select-Object @{n='Connection';e={$_.ApiUrl}},Name,OsVersion
		}
    }
}

###############################################################################
# Get-PaActiveRoute
function Get-PaActiveRoute {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><routing><route></route></routing></show>"

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData
    
    $Flags = @{ 'A' = 'active'
                '?' = 'loose'
                'C' = 'connect'
                'H' = 'host'
                'S' = 'static'
                '~' = 'internal'
                'R' = 'rip'
                'O' = 'ospf'
                'B' = 'bgp'
                'Oi' = 'ospf intra-area'
                'Oo' = 'ospf inter-area'
                'O1' = 'ospf ext-type-1'
                'O2' = 'ospf ext-type-2'
                'E' = 'ecmp' }


    $ResponseTable = @()

    foreach ($r in $ResponseData.entry) {
        $ResponseObject                = New-Object PowerAlto.ActiveRoute
        $EntryFlags = $r.flags.trim().split()
        $RealFlags = @()
        Foreach ($e in $EntryFlags) {
            $RealFlags += $Flags.get_item($e)
        }

        $ResponseObject.VirtualRouter  = $r.'virtual-router'
        $ResponseObject.Destination    = $r.destination
        $ResponseObject.NextHop        = $r.nexthop
        $ResponseObject.Metric         = $r.metric
        $ResponseObject.Flags          = $RealFlags
        $ResponseObject.Age            = $r.age
        $ResponseObject.Interface      = $r.interface

        $ResponseTable                += $ResponseObject
    }

    return $ResponseTable
}

###############################################################################
# Get-PaAddressGroupObject
function Get-PaAddressGroupObject {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.AddressGroupObject
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'address-group'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.AddressGroupObject
        Write-Verbose "Creating new AddressGroupObject"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Address Group Name $($r.name)"
        
        if ($r.dynamic) {
            $ResponseObject.Type = 'dynamic'
            $ResponseObject.Filter = $r.dynamic.filter.trim()
        }

        if ($r.static) {
            $ResponseObject.Type = 'static'
            $ResponseObject.Members = HelperGetPropertyMembers $r static
        }

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }

    #############################################
    # Lookup dynamic members

    $DynamicGroups = $ResponseTable | ? { $_.Type -eq 'dynamic' }
    if ($DynamicGroups) {
        $Addresses = Get-PaAddressObject
        foreach ($d in $DynamicGroups) {
            $Expression = HelperConvertFilterToPosh $d.Filter Addresses Tags
            Write-Verbose $d.Filter
            Write-Verbose $Expression
            $Members = @(iex $Expression)
            $d.Members = $Members.Name
        }
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaAddressObject
function Get-PaAddressObject {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )
    
    $Xpath = HelperCreateXpath "address"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    Write-Debug $ResponseData

    if ($ResponseData.address) { $ResponseData = $ResponseData.address.entry } `
                       else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.AddressObject
        Write-Verbose "Creating new AddressObject"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Address Name $($r.name)"
        
        if ($r.'ip-netmask') {
        #    $ResponseObject.AddressType = 'ip-netmask'
            $ResponseObject.Address = $r.'ip-netmask'
            Write-Verbose "Setting Address: ip-netmask/$($r.'ip-netmask')"
        }

        if ($r.'ip-range') {
        #    $ResponseObject.AddressType = 'ip-range'
            $ResponseObject.Address = $r.'ip-range'
            Write-Verbose "Setting Address: ip-range/$($r.'ip-range')"
        }

        if ($r.fqdn) {
        #    $ResponseObject.AddressType = 'fqdn'
            $ResponseObject.Address = $r.fqdn
            Write-Verbose "Setting Address: fqdn/$($r.fqdn)"
        }

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaAdminIdleTimeout
function Get-PaAdminIdleTimeout {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/devices/entry/deviceconfig/setting/management/idle-timeout"
    $RootNodeName = 'permitted-ip'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    try {
        $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action
    } catch {
        if ($_ -match "No such node.") {
            return "60 minutes"
        } else {
            Throw $_
        }
    }

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = $ResponseData."idle-timeout"

    return $ResponseTable + " minutes"
}

###############################################################################
# Get-PaAdministrator
function Get-PaAdministrator {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.Administrator
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'users'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Administrator
        
        $ResponseObject.Name = $r.name
        $ResponseObject.AuthenticationProfile = $r.'authentication-profile'
        
        if ($r.permissions.'role-based'.custom) {
            $ResponseObject.AdminType = 'RoleBased'
            $ResponseObject.Role      = $r.permissions.'role-based'.custom.profile    
        } else {
            $ResponseObject.AdminType = 'Dynamic'
            $ResponseObject.Role      = ($r.permissions.'role-based' | gm -MemberType Property).Name
        }

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaApplicationGroupObject
function Get-PaApplicationGroupObject {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.ApplicationGroupObject
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'application-group'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.ApplicationGroupObject
        Write-Verbose "Creating new ApplicationGroupObject"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Application Group Name $($r.name)"
        
        $ResponseObject.Members = $r.Member

        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaAuthenticationProfile
function Get-PaAuthenticationProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.AuthenticationProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'authentication-profile'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.AuthenticationProfile
        
        $ResponseObject.Name           = $r.name
        $ResponseObject.LockoutTime    = $r.lockout.'lockout-time'
        $ResponseObject.FailedAttempts = $r.lockout.'failed-attempts'
        $ResponseObject.Method         = ($r.method | gm -MemberType Property).Name
        $ResponseObject.ServerProfile  = $r.method."$($ResponseObject.Method)".'server-profile'
        $ResponseObject.AllowList      = $r.'allow-list'.member

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaConfig
function Get-PaConfig {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$False,Position=1)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )

    HelperCheckPaConnection

    $QueryTable = @{ type   = "config"
                     xpath  = $Xpath
                     action = $Action  }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)
    $global:test2 = $Response

    return HelperCheckPaError $Response
}

###############################################################################
# Get-PaConfigLogSettings
function Get-PaConfigLogSettings {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/shared/log-settings/config"
    $RootNodeName = 'config'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = @()
	
	
    $Severities = @("any")
    
    foreach ($Severity in $Severities) {
        $ResponseObject                    = New-Object PowerAlto.SystemLogSetting
        $ResponseObject.Severity           = "config"
        $ResponseObject.Syslog   = $ResponseData.$Severity.'send-syslog'.'using-syslog-setting'
        $ResponseObject.SnmpTrap = $ResponseData.$Severity.'send-snmptrap'.'using-snmptrap-setting'
        $ResponseObject.Email    = $ResponseData.$Severity.'send-email'.'using-email-setting'
        if ($ResponseData.'send-to-panorama' -eq "yes") { $ResponseObject.$Severity.Panorama = $true }
        
        $ResponseTable += $ResponseObject
    }
    
    
    return $ResponseTable
}

###############################################################################
# Get-PaContentUpgrades
function Get-PaContentUpgrades {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="av")]
        [switch]$Antivirus,

        [Parameter(Mandatory=$True,ParameterSetName="app")]
        [switch]$AppsAndThreats
    )
    

    if ($Antivirus) {
        $Command = "<request><anti-virus><upgrade><download><latest></latest></download></upgrade></anti-virus></request>"
    }
    if ($AppsAndThreats) {
        $Command = "<request><content><upgrade><download><latest></latest></download></upgrade></content></request>"
    }

    if ($ShowProgress) { $WaitForCompletion = $true }

    $ResponseData = Invoke-PaOperation $Command
    $global:test = $ResponseData
    $Job = $ResponseData.job

    $JobParams = @{ 'Id' = $Job
                    'CheckInterval' = 5 }
    if ($ShowProgress)      { $JobParams += @{ 'ShowProgress' = $true } }
    if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

    $JobStatus = Get-PaJob @JobParams
    if ($JobStatus.Result -eq 'Fail') {
        Throw $JobStatus.Details
    } else {
        if (!($Quiet)) {
            return $JobStatus.Details
        }
    }
    
}

###############################################################################
# Get-PaCustomUrlCategory
function Get-PaCustomUrlCategory {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.CustomUrlCategory
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'custom-url-category'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.CustomUrlCategory
        Write-Verbose "Creating new CustomUrlCategory Object"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting URL Category Name $($r.name)"
        
        $ResponseObject.Members = HelperGetPropertyMembers $r list
        $ResponseObject.Description = $r.description

        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaDevice
function Get-PaDevice {
    [CmdletBinding()]
	<#
	.SYNOPSIS
		Establishes initial connection to Palo Alto API.
		
	.DESCRIPTION
		The Get-PaDevice cmdlet establishes and validates connection parameters to allow further communications to the Palo Alto API. The cmdlet needs at least two parameters:
		 - The device IP address or FQDN
		 - A valid API key
		
		
		The cmdlet returns an object containing details of the connection, but this can be discarded or saved as desired; the returned object is not necessary to provide to further calls to the API.
	
	.EXAMPLE
		Get-PaDevice "pa.example.com" "LUFRPT1PR2JtSDl5M2tjTktBeTkyaGZMTURTTU9BZm89OFA0Rk1WMS8zZGtKN0F"
		
		Connects to PRTG using the default port (443) over SSL (HTTPS) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer "prtg.company.com" "jsmith" 1234567890 -HttpOnly
		
		Connects to PRTG using the default port (80) over SSL (HTTP) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer -Server "monitoring.domain.local" -UserName "prtgadmin" -PassHash 1234567890 -Port 8080 -HttpOnly
		
		Connects to PRTG using port 8080 over HTTP using the username "prtgadmin" and the passhash 1234567890.
		
	.PARAMETER Server
		Fully-qualified domain name for the PRTG server. Don't include the protocol part ("https://" or "http://").
		
	.PARAMETER UserName
		PRTG username to use for authentication to the API.
		
	.PARAMETER PassHash
		PassHash for the PRTG username. This can be retrieved from the PRTG user's "My Account" page.
	
	.PARAMETER Port
		The port that PRTG is running on. This defaults to port 443 over HTTPS, and port 80 over HTTP.
	
	.PARAMETER HttpOnly
		When specified, configures the API connection to run over HTTP rather than the default HTTPS.
		
	.PARAMETER Quiet
		When specified, the cmdlet returns nothing on success.
	#>

	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
		[string]$Device,

        [Parameter(ParameterSetName="keyonly",Mandatory=$True,Position=1)]
        [string]$ApiKey,

        [Parameter(ParameterSetName="credential",Mandatory=$True,Position=1)]
        [pscredential]$PaCred,

		[Parameter(Mandatory=$False,Position=2)]
		[int]$Port = $null,

		[Parameter(Mandatory=$False)]
		[alias('http')]
		[switch]$HttpOnly,
		
		[Parameter(Mandatory=$False)]
		[alias('q')]
		[switch]$Quiet
	)

    BEGIN {

		if ($HttpOnly) {
			$Protocol = "http"
			if (!$Port) { $Port = 80 }
		} else {
			$Protocol = "https"
			if (!$Port) { $Port = 443 }
			
			$global:PaDeviceObject = New-Object Poweralto.PaDevice
			
			$global:PaDeviceObject.Protocol = $Protocol
			$global:PaDeviceObject.Port     = $Port
			$global:PaDeviceObject.Device   = $Device

            if ($ApiKey) {
                $global:PaDeviceObject.ApiKey = $ApiKey
            } else {
                $UserName = $PaCred.UserName
                $Password = $PaCred.getnetworkcredential().password
            }
			
			$global:PaDeviceObject.OverrideValidation()
		}
    }

    PROCESS {
        
        if (!($ApiKey)) {
            $QueryStringTable = @{ type     = "keygen"
                                   user     = $UserName
                                   password = $Password }

            $QueryString = HelperCreateQueryString $QueryStringTable
			Write-Debug $QueryString
		    $url         = $global:PaDeviceObject.UrlBuilder($QueryString)

		    try   { $QueryObject = $global:PaDeviceObject.HttpQuery($url) } `
            catch {	throw $_.Exception.Message	           }

            $Data                  = HelperCheckPaError $QueryObject
            $global:PaDeviceObject.ApiKey = $Data.key
        }
        
        $QueryStringTable = @{ type = "op"
                               cmd  = "<show><system><info></info></system></show>" }

        $QueryString = HelperCreateQueryString $QueryStringTable
        Write-Debug "QueryString: $QueryString"
		$url         = $global:PaDeviceObject.UrlBuilder($QueryString)
        Write-Debug "URL: $Url"

		try   { $QueryObject = $global:PaDeviceObject.HttpQuery($url) } `
        catch {	throw $_.Exception.Message       	           }

        $Data = HelperCheckPaError $QueryObject
		$Data = $Data.system

        $global:PaDeviceObject.Name            = $Data.hostname
		$global:PaDeviceObject.IpAddress       = $Data.'ip-address'
        $global:PaDeviceObject.Model           = $Data.model
        $global:PaDeviceObject.Serial          = $Data.serial
        $global:PaDeviceObject.OsVersion       = $Data.'sw-version'
        $global:PaDeviceObject.GpAgent         = $Data.'global-protect-client-package-version'
        $global:PaDeviceObject.AppVersion      = $Data.'app-version'
        $global:PaDeviceObject.ThreatVersion   = $Data.'threat-version'
        $global:PaDeviceObject.WildFireVersion = $Data.'wildfire-version'
        $global:PaDeviceObject.UrlVersion      = $Data.'url-filtering-version'

        #$global:PaDeviceObject = $PaDeviceObject

		
		if (!$Quiet) {
			return $global:PaDeviceObject | Select-Object @{n='Connection';e={$_.ApiUrl}},Name,OsVersion
		}
    }
}

###############################################################################
# Get-PaDiskSpace
function Get-PaDiskSpace {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><system><disk-space></disk-space></system></show>"

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    $ResponseSplit = $ResponseData.'#cdata-section'.Split("`r`n")
    
    $OutputRx = [regex] '(?msx)
                         (?<filesystem>[a-z0-9\/]+)\ +
                         (?<size>[0-9\.A-Z]+)\ +
                         (?<used>[0-9\.A-Z]+)\ +
                         (?<available>[0-9\.A-Z]+)\ +
                         (?<percent>\d+%)\ +
                         (?<mount>[\/a-z]+)
                         '
    $ReturnObjects = @()

    foreach ($r in $ResponseSplit) {
        $Match = $OutputRx.Match($r)
        if ($Match.Success) {
            $ReturnObject             = "" | Select FileSystem,Size,Used,Available,PercentUsed,MountPoint
            $ReturnObject.FileSystem  = $Match.Groups['filesystem'].Value
            $ReturnObject.Size        = $Match.Groups['size'].Value
            $ReturnObject.Used        = $Match.Groups['used'].Value
            $ReturnObject.Available   = $Match.Groups['available'].Value
            $ReturnObject.PercentUsed = $Match.Groups['percent'].Value
            $ReturnObject.MountPoint  = $Match.Groups['mount'].Value
            
            $ReturnObjects += $ReturnObject
        }
    }

    return $ReturnObjects
}

###############################################################################
# Get-PaDynamicBlockList
function Get-PaDynamicBlockList {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.DynamicBlockList
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'external-list'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.DynamicBlockList
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Description = $r.description
        $ResponseObject.Source      = $r.url
        
        $UpdateInterval = ($r.recurring | gm -Type property).Name
        
        $ResponseObject.UpdateInterval = $UpdateInterval
        $ResponseObject.UpdateTime     = $r.recurring.$UpdateInterval.at

        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaInterfaceConfig
function Get-PaInterfaceConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        #[ValidatePattern("\w+|(\w\.)+\w")]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Ethernet,

        [Parameter(Mandatory=$False)]
        [switch]$Loopback,

        [Parameter(Mandatory=$False)]
        [switch]$Vlan,

        [Parameter(Mandatory=$False)]
        [switch]$Tunnel,
        
        [Parameter(Mandatory=$False)]
        [switch]$Aggregate,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    if ($Ethernet -or $Loopback -or $Vlan -or $Tunnel) {
        $TypeSpecified = $True
    }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ElementName = "network/interface"
    $Xpath = "/config/devices/entry/$ElementName"
    $InterfaceTypeRx = [regex] '(?<type>loopback|vlan|tunnel|ethernet|ae)(?<num>\d+\/\d+|\.\d+|\d+)?(?<sub>\.\d+)?'

    if ($Name) {
        $InterfaceMatch = $InterfaceTypeRx.Match($Name)
        $InterfaceType  = $InterfaceMatch.Groups['type'].Value

        Write-Verbose $InterfaceMatch.Value

        switch ($InterfaceType) {
            { ($_ -eq "loopback") -or
              ($_ -eq "vlan") -or
              ($_ -eq "tunnel") } {
                if ($InterfaceMatch.Groups['num'].Success) {
                    $Xpath += "/$InterfaceType/units/entry[@name='$Name']"
                } else {
                    $Xpath += "/$Name"
                }
            }
            ethernet {
                $Xpath += "/$InterfaceType/entry[@name='$($InterfaceMatch.Groups['type'].Value)$($InterfaceMatch.Groups['num'].Value)']"
                if ($InterfaceMatch.Groups['sub'].Success) {
                    $Xpath += "/layer3/units/entry[@name='$Name']"
                }
            }
            default {
                $Xpath += "/$InterfaceType/entry[@name='$Name']"
            }
        }
    }

    Write-Verbose $Xpath

    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    $Global:test = $ResponseData

    function ProcessInterface ($entry) {
        $interfaceObject                = New-Object PowerAlto.InterfaceConfig
        $interfaceObject.Name           = $entry.name
        $interfaceObject.AggregateGroup = $entry.'aggregate-group'
        $interfaceObject.Comment        = $entry.comment
        $InterfaceObject.AdminSpeed     = $Entry.'link-speed'
        $InterfaceObject.AdminDuplex    = $Entry.'link-duplex'
        $InterfaceObject.AdminState     = $Entry.'link-state'

        if ($entry.layer3 -or ($entry.firstchild.name -eq 'tap')) {
            $interfaceObject.MgmtProfile    = $entry.layer3.'interface-management-profile'
            $interfaceObject.NetflowProfile = $entry.layer3.'netflow-profile'
            $interfaceObject.IpAddress      = $entry.layer3.ip.entry.name

            if ($entry.layer3) {
                $interfaceObject.Type = 'layer3'
            } elseif ($entry.firstchild.name -eq 'tap') {
                $interfaceObject.Type = 'tap'
            }

            if ($entry.layer3.'untagged-sub-interface' -eq 'yes') {
                $interfaceObject.UntaggedSub = $true
            }

            if ($entry.layer3.'dhcp-client'.enable -eq 'yes') {
                $interfaceObject.IsDhcp = $true

                if ($entry.layer3.'dhcp-client'.'create-default-route' -eq 'yes') {
                    $interfaceObject.CreateDefaultRoute = $true
                }
            }
        } elseif ($entry.ip.entry.name) {
            $interfaceObject.MgmtProfile = $entry.'interface-management-profile'
            $interfaceObject.IpAddress   = $entry.ip.entry.name
            $interfaceObject.Tag         = $entry.tag

            switch ($entry.name) {
                { $_ -match 'ethernet' } {
                    $interfaceObject.Type = 'subinterface'
                }
            }
        }

        return $interfaceObject
    }


    ###############################################################################
    # Process Response

    if ($Name) {
        if ($ResponseData.entry) {
            ProcessInterface $ResponseData.entry
        } else {
            ProcessInterface $ResponseData.$Name
        }

        return $InterfaceObject
    } else {
        $InterfaceObjects = @()

        ###############################################################################
        # Ethernet Interfaces

        if ($Ethernet -or (!($TypeSpecified))) {
            Write-Verbose '## Ethernet Interfaces ##'
            foreach ($e in $ResponseData.interface.ethernet.entry) {
                if (($e.layer3) -or `
                    ($e.firstchild.name -eq 'tap') -or `
                    ($e.'aggregate-group')) {

                    Write-Verbose $e.name
                    $InterfaceObjects += ProcessInterface $e
                    if ($e.layer3.units) {
                        foreach ($u in $e.layer3.units.entry) {
                            Write-Verbose $u.name
                            $InterfaceObjects += ProcessInterface $u
                        }
                    }
                }
            }
        }

        ###############################################################################
        # Aggregate Interfaces

        if ($Ethernet -or (!($TypeSpecified))) {
            Write-Verbose '## Ethernet Interfaces ##'
            foreach ($e in $ResponseData.interface.'aggregate-ethernet'.entry) {
                if ($e.layer3) {

                    Write-Verbose $e.name
                    $InterfaceObjects += ProcessInterface $e
                    if ($e.layer3.units) {
                        foreach ($u in $e.layer3.units.entry) {
                            Write-Verbose $u.name
                            $InterfaceObjects += ProcessInterface $u
                        }
                    }
                }
            }
        }

        ###############################################################################
        # Loopback Interfaces

        if ($Loopback -or (!($TypeSpecified))) {
            Write-Verbose '## Loopback Interfaces ##'
            foreach ($e in $ResponseData.interface.loopback) {
                Write-Verbose 'loopback'
                $InterfaceObjects += ProcessInterface $e
                if ($e.units) {
                    foreach ($u in $e.units.entry) {
                        Write-Verbose $u.name
                        $InterfaceObjects += ProcessInterface $u
                    }
                }
            }
        }

        ###############################################################################
        # Vlan Interfaces

        if ($Vlan -or (!($TypeSpecified))) {
            Write-Verbose '## Vlan Interfaces ##'
            foreach ($e in $ResponseData.interface.vlan) {
                $InterfaceObjects += ProcessInterface $e
                Write-Verbose 'vlan'
                if ($e.units) {
                    foreach ($u in $e.units.entry) {
                        Write-Verbose $u.name
                        $InterfaceObjects += ProcessInterface $u
                    }
                }
            }
        }

        ###############################################################################
        # Tunnel Interfaces

        if ($Tunnel -or (!($TypeSpecified))) {
            Write-Verbose '## Tunnel Interfaces ##'
            foreach ($e in $ResponseData.interface.tunnel) {
                Write-Verbose "tunnel"
                $InterfaceObjects += ProcessInterface $e
                if ($e.units) {
                    foreach ($u in $e.units.entry) {
                        Write-Verbose $u.name
                        $InterfaceObjects += ProcessInterface $u
                    }
                }
            }
        }
        
        return $InterfaceObjects
    }
}

###############################################################################
# Get-PaInterfaceCounter
function Get-PaInterfaceCounter {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^(ethernet\d+\/\d+(\.\d+)?|(loopback|tunnel|vlan|ae\d)(\.\d+)?)$')]
        [string]$Name
    )

    if ($Ethernet -or $Loopback -or $Vlan -or $Tunnel) {
        $TypeSpecified = $True
    }

    if ($Name) {
        $Command = "<show><counter><interface>$Name</interface></counter></show>"
    } else {
        $Command = "<show><counter><interface>all</interface></counter></show>"
    }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessInterface ($entry) {
        $interfaceObject = New-Object PowerAlto.InterfaceStatus
        
        #tunnel:      .ifnet.entry
        #loopback:    .ifnet.entry
        #subinterface .ifnet.entry
        #vlan:        .hw.entry
        #ae:          .hw.entry
        #ethernet:    .hw.entry



        if ($entry.hw.entry) {
            Write-Verbose "hw found"

            $interfaceObject.InBytes  = $entry.hw.entry.ibytes
            $interfaceObject.OutBytes = $entry.hw.entry.obytes
            $interfaceObject.InDrops  = $entry.hw.entry.idrops
            $interfaceObject.InErrors = $entry.hw.entry.ierrors
        } else {
            Write-Verbose "hw not found"

            $interfaceObject.InBytes  = $entry.ifnet.entry.ibytes
            $interfaceObject.OutBytes = $entry.ifnet.entry.obytes
            $interfaceObject.InDrops  = $entry.ifnet.entry.idrops
            $interfaceObject.InErrors = $entry.ifnet.entry.ierrors
        }

        $interfaceObject.Name          = $entry.ifnet.entry.name
        
        return $interfaceObject
    }

    return ProcessInterface $ResponseData
}

###############################################################################
# Get-PaInterfaceStatus
function Get-PaInterfaceStatus {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^(ethernet\d+\/\d+(\.\d+)?|(loopback|tunnel|vlan)(\.\d+)?)$')]
        [string]$Name
    )

    if ($Ethernet -or $Loopback -or $Vlan -or $Tunnel) {
        $TypeSpecified = $True
    }

    if ($Name) {
        $Command = "<show><interface>$Name</interface></show>"
    } else {
        $Command = "<show><interface>all</interface></show>"
    }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessInterface ($entry,$hw) {
        $interfaceObject = New-Object PowerAlto.InterfaceStatus
        
        if ($hw) {
            Write-Verbose "hw found"
            $interfaceObject.MacAddress = $hw.mac
            $interfaceObject.Speed      = $hw.speed
            $interfaceObject.Duplex     = $hw.duplex

            $interfaceObject.InBytes  = $entry.counters.hw.entry.ibytes
            $interfaceObject.OutBytes = $entry.counters.hw.entry.obytes
            $interfaceObject.InDrops  = $entry.counters.hw.entry.idrops
            $interfaceObject.InErrors = $entry.counters.hw.entry.ierrors
        } else {
            $interfaceObject.InBytes  = $entry.counters.ifnet.entry.ibytes
            $interfaceObject.OutBytes = $entry.counters.ifnet.entry.obytes
            $interfaceObject.InDrops  = $entry.counters.ifnet.entry.idrops
            $interfaceObject.InErrors = $entry.counters.ifnet.entry.ierrors
        }

        $interfaceObject.Name          = $entry.name
        $interfaceObject.Vsys          = $entry.vsys
        $interfaceObject.Mtu           = $entry.mtu
        $interfaceObject.VirtualRouter = $entry.vr
        $interfaceObject.Mode          = $entry.mode
        $interfaceObject.Zone          = $entry.zone
        $interfaceObject.Tag           = $entry.tag

        if ($entry.'dyn-addr'.member) {
            $interfaceObject.IpAddress = @($entry.'dyn-addr'.member)
        } elseif ($entry.addr.member) {
            $interfaceObject.IpAddress = @($entry.addr.member)
        }
        
        return $interfaceObject
    }

    return ProcessInterface $ResponseData.ifnet $ResponseData.hw
}

###############################################################################
# Get-PaJob
function Get-PaJob {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [int]$Id,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,

        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$False)]
        [int]$CheckInterval = 15
    )

    $CmdletName = $MyInvocation.MyCommand.Name

    if ($Id) {
        $Command = "<show><jobs><id>$Id</id></jobs></show>"
    } else {
        $Command = "<show><jobs><all></all></jobs></show>"
    }

    if ($ShowProgress) { $WaitForCompletion = $true }

    $ResponseData = Invoke-PaOperation $Command
    $Global:test = $ResponseData

    function ProcessEntry ($Entry) {
        $NewJob = New-Object PowerAlto.Job
        $NewJob.Id = $Entry.id
        $NewJob.TimeEnqueued = $Entry.tenq
        $NewJob.User = $Entry.user
        $NewJob.Type = $Entry.type
        $NewJob.Status = $Entry.status
        $NewJob.Result = $Entry.result
        $NewJob.TimeCompleted = $Entry.tfin
        if ($Entry.details.line.newjob) {
            $NewJob.Details = $Entry.details.line.newjob.newmsg
            $NewJob.NextJob = [int]($Entry.details.line.newjob.nextjob)
        } else {
            $NewJob.Details = $Entry.details.line
        }
        $NewJob.Warnings = $Entry.warnings.line

        if ($Entry.stoppable -eq 'yes') {
            $NewJob.Stoppable = $true
        } else {
            $NewJob.Stoppable = $False
        }

        if ($Entry.progress -match '^\d+$') {
            $NewJob.Progress = $Entry.progress
        } elseif ($Entry.Status -eq 'FIN') {
            $NewJob.Progress = 100
        }

        return $NewJob
    }

    $ReturnObjects = @()

    if ($WaitForCompletion) {
        $ActiveJob = ProcessEntry $ResponseData.job
        if ($ShowProgress) {
            $ProgressParams = @{'Activity'         = $ActiveJob.Type
                                'CurrentOperation' = "Checking status in $CheckInterval seconds..."
                                'Status'           = "$($ActiveJob.Progress)% complete"
                                'Id'               = $ActiveJob.Id
                                'PercentComplete'  = $ActiveJob.Progress}
            Write-Progress @ProgressParams
        }

        while ($ActiveJob.Progress -ne 100) {

            $i = 0
            while ($i -lt $CheckInterval) {
                Start-Sleep -s 1
                $i ++
                if ($ShowProgress) {
                    $ProgressParams.Set_Item("CurrentOperation","Checking Status in $($CheckInterval - $i) seconds...")
                    Write-Progress @ProgressParams
                }
            }
            
            $CurrentOperation = "Checking status now"
            HelperWriteCustomVerbose $CmdletName $CurrentOperation
            if ($ShowProgress) {
                $ProgressParams.Set_Item("CurrentOperation",$CurrentOperation)
                Write-Progress @ProgressParams
            }
             
            $UpdateJob = Invoke-PaOperation $Command
            $ActiveJob = ProcessEntry $UpdateJob.Job
            $Status    = "$($ActiveJob.Progress)% complete"
            HelperWriteCustomVerbose $CmdletName $Status

            if ($ShowProgress) {
                $ProgressParams.Set_Item("PercentComplete",$ActiveJob.Progress)
                $ProgressParams.Set_Item('Status',"$($ActiveJob.Progress)% complete")
                Write-Progress @ProgressParams
            }
        }
        $ReturnObjects += $ActiveJob
    } else {
        foreach ($j in $ResponseData.job) {
            $ReturnObjects += ProcessEntry $j
        }
    }

    return $ReturnObjects
}

###############################################################################
# Get-PaKerberosServerProfile
function Get-PaKerberosServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.KerberosServerProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'kerberos'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.KerberosServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Realm  = $r.realm
        $ResponseObject.Domain = $r.domain
        
        foreach ($Server in $r.server.entry) {
            $KerberosServer          = New-Object PowerAlto.KerberosServer
            $KerberosServer.Name     = $Server.name
            $KerberosServer.Host     = $Server.host
            if ($Server.port) {
                $KerberosServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $KerberosServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaLdapServerProfile
function Get-PaLdapServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

    $InfoObject   = New-Object PowerAlto.LdapServerProfile
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'ldap'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.LdapServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Type   = $r.'ldap-type'
        $ResponseObject.BindDn   = $r.'bind-dn'
        $ResponseObject.BindPassword   = $r.'bind-password'
        $ResponseObject.Base   = $r.base
        $ResponseObject.Domain = $r.domain
        
        if ($r.ssl -eq "yes") { $ResponseObject.Ssl = $true }
        
        foreach ($Server in $r.server.entry) {
            $NewServer          = New-Object PowerAlto.LdapServer
            $NewServer.Name     = $Server.name
            $NewServer.Host     = $Server.address
            if ($Server.port) {
                $NewServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $NewServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaLicense
function Get-PaLicense {
    [CmdletBinding()]
    Param (
    )

    $Command = "<request><license><fetch></fetch></license></request>"

    $ResponseData = Invoke-PaOperation $Command
    $ResponseTable = @()

    foreach ($r in $ResponseData.licenses.entry) {
        $ResponseObject = New-Object PowerAlto.License

        $ResponseObject.Feature     = $r.feature
        $ResponseObject.Description = $r.description
        $ResponseObject.DateIssued  = $r.issued
        $ResponseObject.DateExpires = $r.expires
        $ResponseObject.AuthCode    = $r.authcode

        $ResponseTable                += $ResponseObject
    }

    $Command = "<request><support><check></check></support></request>"
    $ResponseData = Invoke-PaOperation $Command
    
    $ResponseObject = New-Object PowerAlto.License

    $ResponseObject.Feature     = $ResponseData.SupportInfoResponse.Support.SupportLevel
    $ResponseObject.Description = $ResponseData.SupportInfoResponse.Support.SupportDescription
    $ResponseObject.DateExpires = $ResponseData.SupportInfoResponse.Support.ExpiryDate

    $ResponseTable += $ResponseObject

    return $ResponseTable
}

###############################################################################
# Get-PaLog
function Get-PaLog {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,Position=0,ParameterSetName="newlog")]
		[string]$LogType,
        
        [Parameter(Mandatory=$False,ParameterSetName="newlog")]
		[string]$Query,
        
        [Parameter(Mandatory=$False,ParameterSetName="newlog")]
        [ValidateRange(20,5000)]
		[int]$NumberOfLogs = 20,
        
        [Parameter(Mandatory=$True,Position=0,ParameterSetName="getlog")]
		[string]$Action,
        
        [Parameter(Mandatory=$True,Position=1,ParameterSetName="getlog")]
		[int]$Job,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForJob
    )

    HelperCheckPaConnection

    $QueryTable = @{ "type" = "log" }
    
    if ($LogType) {
        $QueryTable."log-type" = $LogType
        $QueryTable.query      = $Query
        $QueryTable.nlogs      = $NumberOfLogs
    } else {
        $QueryTable.action   = $Action
        $QueryTable."job-id" = $Job
    }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)
    $Response    = HelperCheckPaError $Response
    if ($WaitForJob) {
        if (!($Response.job)) { return $Repsonse } 
        
        $QueryTable = @{ "type" = "log" }
        $QueryTable.action   = "get"
        $QueryTable."job-id" = $Response.job
        
        $QueryString = HelperCreateQueryString $QueryTable
        $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
        $Response    = $global:PaDeviceObject.HttpQuery($url)
        $Response    = HelperCheckPaError $Response
        
        while($Response.job.status -ne "FIN") {
            Write-Verbose "Sleeping 5 Seconds"
            Write-Verbose $url
            Write-Verbose $Response.job.status
            sleep 5000
            $Response    = $global:PaDeviceObject.HttpQuery($url)
            $Response    = HelperCheckPaError $Response
        }
    }

    return $Response
}

###############################################################################
# Get-PaManagedDevices
function Get-PaManagedDevices {
    [CmdletBinding()]
    Param (
    )

    $Command = "<show><devices><all></all></devices></show>"

    $ResponseData = Invoke-PaOperation $Command

    $ResponseTable = @()

    foreach ($r in $ResponseData.devices.entry) {
        $ResponseObject = New-Object PowerAlto.PaDevice

        $ResponseObject.Name            = $r.hostname
		$ResponseObject.IpAddress       = $r.'ip-address'
        $ResponseObject.Model           = $r.model
        $ResponseObject.Serial          = $r.serial
        $ResponseObject.OsVersion       = $r.'sw-version'
        $ResponseObject.GpAgent         = $r.'global-protect-client-package-version'
        $ResponseObject.AppVersion      = $r.'app-version'
        $ResponseObject.ThreatVersion   = $r.'threat-version'
        $ResponseObject.WildFireVersion = $r.'wildfire-version'
        $ResponseObject.UrlVersion      = $r.'url-filtering-version'

        $ResponseTable                += $ResponseObject
    }

    return $ResponseTable
}

###############################################################################
# Get-PaManagementAcl
function Get-PaManagementAcl {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/devices/entry/deviceconfig/system/permitted-ip"
    $RootNodeName = 'permitted-ip'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    try {
        $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action
    } catch {
        if ($_ -match "No such node.") {
            return @("0.0.0.0/0")
        } else {
            Throw $_
        }
    }

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = @()
    foreach ($Entry in $ResponseData.Entry) {
        $ResponseTable += $Entry.Name
    }	

    return $ResponseTable
}

###############################################################################
# Get-PaManagementServices
function Get-PaManagementServices {
    [CmdletBinding()]
    Param (
    )

    $InfoObject   = New-Object PowerAlto.ManagementServices
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'service'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

	$ResponseObject = New-Object PowerAlto.ManagementServices
	
    if ($ResponseData.'disable-telnet' -eq "yes") { $ResponseObject.DisableTelnet = $true  } `
                                             else { $ResponseObject.DisableTelnet = $false }
    
    if ($ResponseData.'disable-http' -eq "yes") { $ResponseObject.DisableHttp = $true  } `
                                           else { $ResponseObject.DisableHttp = $false }
                                             
    if ($ResponseData.'disable-userid-service' -eq "no") { $ResponseObject.DisableUserId = $false  } `
                                                    else { $ResponseObject.DisableUserId = $true  }
    
    if ($ResponseData.'disable-snmp' -eq "no") { $ResponseObject.DisableSnmp = $false  } `
                                          else { $ResponseObject.DisableSnmp = $true }
    return $ResponseObject
}

###############################################################################
# Get-PaNatPolicy
function Get-PaNatPolicy {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.NatPolicy
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'rules'

    #if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $RuleCount = 0
    $ResponseTable = @()

    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.NatPolicy
        Write-Verbose "Creating new NatPolicy"
            
        # Number
        $RuleCount++
        $ResponseObject.Number = $RuleCount
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Tags        = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description
        $ResponseObject.NatType     = $r.'nat-type'

        $ResponseObject.SourceZone           = HelperGetPropertyMembers $r from
        $ResponseObject.DestinationZone      = HelperGetPropertyMembers $r to
        $ResponseObject.Service              = $r.service
        $ResponseObject.DestinationInterface = $r.'to-interface'
        $ResponseObject.SourceAddress        = HelperGetPropertyMembers $r source
        $ResponseObject.DestinationAddress   = HelperGetPropertyMembers $r destination
        
        if ($r.disabled -eq 'yes') { $ResponseObject.Disabled = $true }

        $SourceTranslation = $r.'source-translation'
        if ($SourceTranslation.'static-ip') {
            $ResponseObject.SourceTranslationType = "StaticIp"

            if ($SourceTranslation.'static-ip'.'bi-directional' -eq 'yes') {
                $ResponseObject.IsBidirectional = $true
            } else {
                $ResponseObject.IsBidirectional = $false
            }

            if ($SourceTranslation.'static-ip'.'translated-address') {
                $ResponseObject.SourceTranslatedAddressType = "TranslatedAddress"
                $ResponseObject.SourceTranslatedAddress = $SourceTranslation.'static-ip'.'translated-address'
            }
        } elseif ($SourceTranslation.'dynamic-ip-and-port') {
            $ResponseObject.SourceTranslationType = 'DynamicIpAndPort'
            if ($SourceTranslation.'dynamic-ip-and-port'.'interface-address') {
                $ResponseObject.SourceTranslatedAddressType = 'InterfaceAddress'
                $ResponseObject.SourceTranslatedInterface = $SourceTranslation.'dynamic-ip-and-port'.'interface-address'.interface
                $ResponseObject.SourceTranslatedAddress = $SourceTranslation.'dynamic-ip-and-port'.'interface-address'.ip
            }
        }

        $ResponseTable += $ResponseObject

    }
    
    if ($Name) {
        $ResponseTable = $ResponseTable | ? { $_.Name -eq $Name }
    }
    
    return $ResponseTable

}

###############################################################################
# Get-PaQosPolicy
function Get-PaQosPolicy {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.QosPolicy
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'rules'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()

    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.QosPolicy
        
        $ResponseObject.Name        = $r.name
        $ResponseObject.Tags        = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description
        

        $ResponseObject.SourceZone    = HelperGetPropertyMembers $r from
        $ResponseObject.SourceAddress = HelperGetPropertyMembers $r source
        $ResponseObject.SourceUser    = HelperGetPropertyMembers $r source-user
        if ($r.'negate-source' -eq 'yes') {
            $ResponseObject.SourceNegate = $true
        }

        $ResponseObject.DestinationZone      = HelperGetPropertyMembers $r to
        $ResponseObject.DestinationAddress   = HelperGetPropertyMembers $r destination
        if ($r.'negate-destination' -eq 'yes') {
            $ResponseObject.DestinationNegate = $true
        }

        $ResponseObject.UrlCategory = HelperGetPropertyMembers $r category
        $ResponseObject.Application = HelperGetPropertyMembers $r application
        $ResponseObject.Service     = HelperGetPropertyMembers $r service

        $ResponseObject.Class = $r.action.class
        
        $ResponseTable += $ResponseObject

        <#
        Schedule           : none
        #>

    }
    return $ResponseTable

}

###############################################################################
# Get-PaRadiusServerProfile
function Get-PaRadiusServerProfile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name
    )

	$VerbosePrefix = "Get-PaRadiusServerProfile:"
    $InfoObject    = New-Object PowerAlto.RadiusServerProfile
    $Xpath         = $InfoObject.BaseXPath
    $RootNodeName  = 'radius'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.RadiusServerProfile
        
        $ResponseObject.Name   = $r.name
        $ResponseObject.Domain = $r.domain
        
        foreach ($Server in $r.server.entry) {
            $NewServer          = New-Object PowerAlto.RadiusServer
            $NewServer.Name     = $Server.name
            $NewServer.Host     = $Server."ip-address"
			$NewServer.Secret   = $Server.secret
            if ($Server.port) {
                $NewServer.Port     = $Server.port
            }
            $ResponseObject.Servers += $NewServer
        }
        
        $ResponseTable += $ResponseObject
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaSecurityRule
function Get-PaSecurityRule {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"

    #if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $RuleData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($RuleData.rules) { $RuleData = $RuleData.rules.entry } `
                    else { $RuleData = $RuleData.entry       }
        
    $RuleCount = 0
    $RuleTable = @()
    foreach ($r in $RuleData) {
        $RuleObject = New-Object PowerAlto.SecurityRule

        # Number
        $RuleCount++
        $RuleObject.Number = $RuleCount
        
        # General
        $RuleObject.Name        = $r.Name
        $RuleObject.Description = $r.Description
        $RuleObject.Tags        = HelperGetPropertyMembers $r tag

        # Source
        $RuleObject.SourceZone    = HelperGetPropertyMembers $r from
        $RuleObject.SourceAddress = HelperGetPropertyMembers $r source
        if ($r.'negate-source' -eq 'yes') { $RuleObject.SourceNegate = $true }

        # User
        $RuleObject.SourceUser = HelperGetPropertyMembers $r source-user
        $RuleObject.HipProfile = HelperGetPropertyMembers $r hip-profiles

        # Destination
        $RuleObject.DestinationZone    = HelperGetPropertyMembers $r to
        $RuleObject.DestinationAddress = HelperGetPropertyMembers $r destination
        if ($r.'negate-destination' -eq 'yes') { $RuleObject.DestinationNegate = $true }

        # Application
        $RuleObject.Application = HelperGetPropertyMembers $r application

        # Service / Url Category
        $RuleObject.UrlCategory = HelperGetPropertyMembers $r category
        $RuleObject.Service     = HelperGetPropertyMembers $r service

        # Action Setting
        if ($r.action -eq 'allow') { $RuleObject.Allow = $true } `
                              else { $RuleObject.Allow = $false }

        # Profile Setting
        $ProfileSetting = $r.'profile-setting'
        if ($ProfileSetting.profiles) {
            $RuleObject.AntivirusProfile     = $ProfileSetting.profiles.virus.member
            $RuleObject.AntiSpywareProfile   = $ProfileSetting.profiles.spyware.member
            $RuleObject.VulnerabilityProfile = $ProfileSetting.profiles.vulnerability.member
            $RuleObject.UrlFilteringProfile  = $ProfileSetting.profiles.'url-filtering'.member
            $RuleObject.FileBlockingProfile  = $ProfileSetting.profiles.'file-blocking'.member
            $RuleObject.DataFilteringProfile = $ProfileSetting.profiles.'data-filtering'.member
        } elseif ($ProfileSetting.group) {
            if ($ProfileSetting.group.member) { $RuleObject.ProfileGroup = $ProfileSetting.group.member }
        }

        # Log Setting
        if ($r.'log-start' -eq 'yes') { $RuleObject.LogAtSessionStart = $true }
        if ($r.'log-end' -eq 'yes')   { $RuleObject.LogAtSessionEnd = $true   }
        $RuleObject.LogForwarding = $r.'log-setting'

        # QoS Settings
        $QosSetting = $r.qos.marking
        if ($QosSetting.'ip-precedence') {
            $RuleObject.QosType    = "ip-precedence"
            $RuleObject.QosMarking = $QosSetting.'ip-precedence'
        } elseif ($QosSetting.'ip-dscp') {
            $RuleObject.QosType    = "ip-dscp"
            $RuleObject.QosMarking = $QosSetting.'ip-dscp'
        }

        # Other Settings
        $RuleObject.Schedule = $r.schedule
        if ($r.option.'disable-server-response-inspection' -eq 'yes') { $RuleObject.DisableSRI = $true }
        if ($r.disabled -eq 'yes') { $RuleObject.Disabled = $true }

        $RuleTable += $RuleObject
    }
    
    if ($Name) {
        $RuleTable = $RuleTable | ? { $_.Name -eq $Name }
    }

    return $RuleTable

}

###############################################################################
# Get-PaService
function Get-PaService {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $ElementName = "service"
    $Xpath = "/config/devices/entry/vsys/entry/$ElementName"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    Write-Debug $ResponseData

    if ($ResponseData.$ElementName) { $ResponseData = $ResponseData.$ElementName.entry } `
                               else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Service
        Write-Verbose "Creating new Service object"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Service Name $($r.name)"
        
        $Protocol = ($r.protocol | gm -Type Property).Name

        $ResponseObject.Protocol        = $Protocol
        $ResponseObject.DestinationPort = $r.protocol.$Protocol.port

        if ($r.protocol.$Protocol.'source-port') { $ResponseObject.SourcePort      = $r.protocol.$Protocol.'source-port' }

        $ResponseObject.Tags            = HelperGetPropertyMembers $r tag
        $ResponseObject.Description     = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaServiceGroup
function Get-PaServiceGroup {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $InfoObject   = New-Object PowerAlto.ServiceGroup
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'service-group'

    if ($Name) { $Xpath += "/entry[@name='$Name']" }
    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName.entry } `
                                else { $ResponseData = $ResponseData.entry         }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.ServiceGroup
        Write-Verbose "Creating new ServiceGroup"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting ServiceGroup Name $($r.name)"
        
        
        
        $ResponseObject.Members = HelperGetPropertyMembers $r members

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag

        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaSession
function Get-PaSession {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ParameterSetName="Id",Position=0)]
        [int]$Id,
		
        # Filter Fields
		[Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Application,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Destination,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [int]$DestinationPort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$EgressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$HardwareInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$IngressInterface,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$MinKb,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Nat,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$NatRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$PbfRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Protocol,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosClass,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosNodeId,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$QosRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [switch]$Rematch,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SecurityRule,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Source,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourcePort,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SourceUser,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$SslDecrypt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [double]$StartAt,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$State,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$DestinationZone,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$Type,
        
        [Parameter(Mandatory=$False,ParameterSetName='Filter')]
        [string]$VsysName
    )

    $ReturnObject = @()
    
    $FilterString = ""
    
    $FilterHash = @{ "application"       = $Application
                     "destination"       = $Destination
                     "destination-port"  = $DestinationPort
                     "destination-user"  = $DestinationUser
                     "egress-interface"  = $EgressInterface
                     "from"              = $SourceZone
                     "hw-interface"      = $HardwareInterface
                     "ingress-interface" = $IngressInterface
                     "min-kb"            = $MinKb
                     "nat"               = $Nat
                     "nat-rule"          = $NatRule
                     "pbf-rule"          = $PbfRule
                     "protocol"          = $Protocol
                     "qos-class"         = $QosClass
                     "qos-node-id"       = $QosNodeId
                     "qos-rule"          = $QosRule
                     "rule"              = $SecurityRule
                     "source"            = $Source
                     "source-port"       = $SourcePort
                     "source-user"       = $SourceUser
                     "ssl-decrypt"       = $SslDecrypt
                     "start-at"          = $StartAt
                     "state"             = $State
                     "to"                = $DestinationZone
                     "type"              = $Type
                     "vsys-name"         = $VsysName }
    
    if ($Rematch) { $FilterHash += @{ "rematch" = "security-policy" } }
    
    foreach ($Filter in $FilterHash.GetEnumerator()) {
        if ($Filter.Value) {
            $FilterString += "<" + [string]$Filter.Name + ">"
            $FilterString += $Filter.Value
            $FilterString += "</" + [string]$Filter.Name + ">"
        }
    }

    if ($Id) {
        $Command = "<show><session><id>$Id</id></session></show>"
    } elseif ($FilterString -ne "") {
        $Command = "<show><session><all><filter>$FilterString</filter></all></session></show>"
    } else {
        $Command = "<show><session><all></all></session></show>"
        #Throw "Must specifiy an Id or a Filter"
    }
	
    $ResponseData = Invoke-PaOperation $Command
    
    if ($ResponseData.entry) { $ResponseData = $ResponseData.entry } `
                        else { $ResponseData = @($ResponseData)    }
    
    $Global:test = $ResponseData
    
    foreach ($Entry in $ResponseData) {
        Write-verbose "1"
        $global:testentry = $Entry
        $NewObject     = New-Object -TypeName PowerAlto.Session
        $ReturnObject += $NewObject
        
        if ($Id) { $NewObject.Id = $Id } `
            else { $NewObject.Id = $Entry.idx }

        # Interfaces
        if ($NewObject.IngressInterface = $Entry.ingress) {
            $NewObject.IngressInterface = $Entry.ingress
        } else {
            $NewObject.IngressInterface = $Entry.'igr-if'
        }
        
        if ($NewObject.EgressInterface = $Entry.egress) {
            $NewObject.EgressInterface = $Entry.egress
        } else {
            $NewObject.EgressInterface = $Entry.'egr-if'
        }
        
        # Times
        $NewObject.StartTime  = $Entry.'start-time'
        $NewObject.Timeout    = $Entry.timeout
        $NewObject.TimeToLive = $Entry.ttl
            
            
        $NewObject.Application      = $Entry.application
        $NewObject.Vsys             = $Entry.vsys

        if ($NewObject.SecurityRule = $Entry.'security-rule') {
            $NewObject.SecurityRule = $Entry.'security-rule'
        } else {
            $NewObject.SecurityRule = $Entry.rule
        }
            
        # Nat Properties
        if ($Entry.'nat-rule') {
            $NewObject.NatRule = $Entry.'nat-rule'
            $NewObject.Nat     = $true
        } else {
            $NewObject.Nat     = [System.Convert]::ToBoolean($Entry.nat)
        }
        
        if ($Entry.'nat-src') {
            $NewObject.SourceNat            = [System.Convert]::ToBoolean($Entry.'nat-src')
            if ($NewObject.SourceNat) {
                $NewObject.TranslatedSource     = $Entry.s2c.dport
                $NewObject.TranslatedSourcePort = $Entry.s2c.dst
            }
        } else {
            $NewObject.SourceNat            = [System.Convert]::ToBoolean($Entry.srcnat)
            if ($NewObject.SourceNat) {
                $NewObject.TranslatedSource     = $Entry.xsource
                $NewObject.TranslatedSourcePort = $Entry.xsport
            }
        }
                         
        if ($Entry.'nat-dst') {
            $NewObject.DestinationNat            = [System.Convert]::ToBoolean($Entry.'nat-dst')
            if ($NewObject.DestinationNat) {
                $NewObject.TranslatedDestination     = $Entry.c2s.dport
                $NewObject.TranslatedDestinationPort = $Entry.c2s.dst
            }
        } else {
            $NewObject.DestinationNat            = [System.Convert]::ToBoolean($Entry.dstnat)
            if ($NewObject.DestinationNat) {
                $NewObject.TranslatedDestination     = $Entry.xdst
                $NewObject.TranslatedDestinationPort = $Entry.xdport
            }
        }
        
        
        
        
        
        if ($Entry.c2s) {
            $NewObject.Source     = $Entry.c2s.source
            $NewObject.SourcePort = $Entry.c2s.sport
            $NewObject.SourceUser = $Entry.c2s.'src-user'
            
            $NewObject.Destination     = $Entry.c2s.dst
            $NewObject.DestinationPort = $Entry.c2s.dport
            $NewObject.DestinationUser = $Entry.c2s.'dst-user'
            
            $NewObject.Protocol  = $Entry.c2s.proto
            $NewObject.State     = $Entry.c2s.state
            
            $NewObject.SourceZone = $Entry.c2s.'source-zone'
        } else {
            $NewObject.Source     = $Entry.source
            $NewObject.SourceZone = $Entry.from
            $NewObject.SourcePort = $Entry.sport
            
            $NewObject.Destination     = $Entry.dst
            $NewObject.DestinationPort = $Entry.dport
            
            $NewObject.Protocol  = $Entry.proto
            $NewObject.State     = $Entry.state 
        }
        
        if ($Entry.s2c) {
            $NewObject.DestinationZone = $Entry.s2c.'source-zone'
        } else {
            $NewObject.DestinationZone = $Entry.to
        }
    }

    return $ReturnObject
}

###############################################################################
# Get-PaSnmpSettings
function Get-PaSnmpSettings {
    [CmdletBinding()]
    Param (
    )

    $InfoObject   = New-Object PowerAlto.SnmpSettings
    $Xpath        = $InfoObject.BaseXPath
    $RootNodeName = 'snmp-setting'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

	$ResponseObject = New-Object PowerAlto.SnmpSettings
	
	$ResponseObject.Location = $ResponseData.'snmp-system'.location
    $ResponseObject.Contact = $ResponseData.'snmp-system'.contact
    if ($ResponseData.'access-setting'.version.v2c) {
        $ResponseObject.Version = "v2c"
        $ResponseObject.Community = $ResponseData.'access-setting'.version.v2c.'snmp-community-string'
    } else {
        $ResponseObject.Version = "v3"
        Write-Warning "v3 not supported yet"
    }
	
    return $ResponseObject
}

###############################################################################
# Get-PaSoftwareInfo
function Get-PaSoftwareInfo {
    [CmdletBinding()]

    $ReturnObject = $False

    $Command = "<request><system><software><info></info></software></system></request>"

    $ResponseData = Invoke-PaOperation $Command
    $global:Test  = $ResponseData
    
    return $ResponseData.'sw-updates'.versions.entry
}

###############################################################################
# Get-PaSoftwareUpgrades
function Get-PaSoftwareUpgrades {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="latest")]
        [switch]$Latest,

        [Parameter(Mandatory=$True,ParameterSetName="nextstep")]
        [switch]$NextStep,

        [Parameter(Mandatory=$True,ParameterSetName="version")]
        [string]$Version
    )
    
    $CmdletName = $MyInvocation.MyCommand.Name

    $AvailableSoftware = Get-PaSoftwareInfo
    $CurrentVersion    = $Global:PaDeviceObject.OsVersion

    if ($Latest)  { $DesiredEntry = $AvailableSoftware[0] }
    if ($Version) { $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $Version } }
    
    if ($NextStep) {
        $MajorReleases       = $AvailableSoftware | Select @{Name = 'MajorRelease'; Expression = {$_.Version.SubString(0,3)}} -Unique
        $CurrentMajorRelease = $CurrentVersion.Substring(0,3)
        $CurrentIndex        = [array]::IndexOf($MajorReleases.MajorRelease,$CurrentMajorRelease)
        HelperWriteCustomVerbose $CmdletName "CurrentIndex: $CurrentIndex"
        if ($CurrentIndex -gt 0) {
            $DesiredIndex        = $CurrentIndex - 1
        } else {
            $DesiredIndex = $CurrentIndex
        }
        $DesiredMajorRlease  = [string]($MajorReleases[$DesiredIndex].MajorRelease)
        $DesiredVersion      = $DesiredMajorRlease + '.0'
        
        if ($CurrentMajorRelease -eq $DesiredMajorRlease) {
            HelperWriteCustomVerbose $CmdletName "CurrentMajorRelease ($CurrentVersion) matches DesiredMajorRelase ($DesiredMajorRlease)"
            $DesiredEntry = $AvailableSoftware[0]
        } else {
            $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $DesiredVersion }
        }
    }

    Write-Debug "CurrentVersion is $CurrentVersion, Downloading $($DesiredEntry.Version)"

    
    if ($DesiredEntry.Downloaded -eq 'no') {
        $Command = "<request><system><software><download><version>$($DesiredEntry.Version)</version></download></software></system></request>"

        $ResponseData = Invoke-PaOperation $Command
        $global:test  = $ResponseData
        $Job          = $ResponseData.job
    
        $JobParams = @{ 'Id' = $Job
                        'CheckInterval' = 5 }
    
        if ($ShowProgress)      {
            $JobParams += @{ 'ShowProgress' = $true } 
            $WaitForCompletion = $true
        }

        if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

        $JobStatus = Get-PaJob @JobParams
        if ($JobStatus.Result -eq 'Fail') {
            Throw $JobStatus.Details
        }
        return $JobStatus
    } else {
        return $DesiredEntry.Version + " already downloaded"
    }
    
}

###############################################################################
# Get-PaSystemLogSettings
function Get-PaSystemLogSettings {
    [CmdletBinding()]
    Param (
    )

    $Xpath        = "/config/shared/log-settings/system"
    $RootNodeName = 'system'

    Write-Debug "xpath: $Xpath"

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    Write-Debug "action: $Action"
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."

    if ($ResponseData.$RootNodeName) { $ResponseData = $ResponseData.$RootNodeName } `
                                else { $ResponseData = $ResponseData               }

    $ResponseTable = @()
	
	
    $Severities = @("informational"
                    "low"
                    "medium"
                    "high"
                    "critical")
    
    foreach ($Severity in $Severities) {
        $ResponseObject                    = New-Object PowerAlto.SystemLogSetting
        $ResponseObject.Severity           = $Severity
        $ResponseObject.Syslog   = $ResponseData.$Severity.'send-syslog'.'using-syslog-setting'
        $ResponseObject.SnmpTrap = $ResponseData.$Severity.'send-snmptrap'.'using-snmptrap-setting'
        $ResponseObject.Email    = $ResponseData.$Severity.'send-email'.'using-email-setting'
        if ($ResponseData.'send-to-panorama' -eq "yes") { $ResponseObject.$Severity.Panorama = $true }
        
        $ResponseTable += $ResponseObject
    }
    
    
    return $ResponseTable
}

###############################################################################
# Get-PaTag
function Get-PaTag {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $PaObject = New-Object PowerAlto.Tag
    $Xpath    = $PaObject.XPath

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ConfigData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($ConfigData.tag) { $ConfigData = $ConfigData.tag }

    $ColorCodes = @{"red"         = "color1"
                    "green"       = "color2"
                    "blue"        = "color3"
                    "yellow"      = "color4"
                    "copper"      = "color5"
                    "orange"      = "color6"
                    "purple"      = "color7"
                    "gray"        = "color8"
                    "light green" = "color9"
                    "cyan"        = "color10"
                    "light gray"  = "color11"
                    "blue gray"   = "color12"
                    "lime"        = "color13"
                    "black"       = "color14"
                    "gold"        = "color15"
                    "brown"       = "color16" }

    $ColorCodesEnum = $ColorCodes.GetEnumerator()

    $ReturnObject = @()
    foreach ($c in $ConfigData.entry) {
        $NewPaObject           = New-Object PowerAlto.Tag
        $ReturnObject         += $NewPaObject
        $NewPaObject.Name      = $c.Name
        $NewPaObject.Comments  = $c.Comments

        if ($c.Color) {
            $Color = $ColorCodesEnum | ? { $_.Value -eq $c.Color }
            $NewPaObject.Color = $Color.Name
        }

    }

    return $ReturnObject

}

###############################################################################
# Get-PaZone
function Get-PaZone {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/zone"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ZoneData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($ZoneData.zone) { $ZoneData = $ZoneData.zone.entry } `
                   else { $ZoneData = $ZoneData.entry      }
        

    $ZoneTable = @()
    foreach ($z in $ZoneData) {
        $ZoneObject = New-Object PowerAlto.Zone

        $ZoneObject.Name                  = $z.name
        $ZoneObject.LogSetting            = $z.network.'log-setting'
        $ZoneObject.ZoneProtectionProfile = $z.network.'zone-protection-profile'
        $ZoneObject.UserIdAclInclude      = $z.'user-acl'.'include-list'.member
        $ZoneObject.UserIdAclExclude      = $z.'user-acl'.'exclude-list'.member

        if ($z.'enable-user-identification') {
            $ZoneObject.EnableUserId = $true
        }


        $IsLayer3 = $z.network.layer3
        if ($IsLayer3) {
            $ZoneObject.ZoneType = "layer3"
            $ZoneObject.Interfaces = $IsLayer3.member
        }

        $ZoneTable += $ZoneObject
    }

    return $ZoneTable

}

###############################################################################
# Invoke-PaContentCheck
function Invoke-PaContentCheck {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$Antivirus,

        [Parameter(Mandatory=$False)]
        [switch]$AppsAndThreats,

        [Parameter(Mandatory=$False)]
        [switch]$All = $true
    )

    if ($Antivirus -or $AppsAndThreats) {
        $All = $False
    }
    $ReturnObject = $False

    if ($AppsAndThreats -or $All) {
        $Command = "<request><content><upgrade><check></check></upgrade></content></request>"

        $ResponseData = Invoke-PaOperation $Command

        

        $AvailableUpdates = $ResponseData.'content-updates'.entry
        if ($AvailableUpdates.current -eq 'no') {
            if ($Quiet) {
                $ReturnObject = $true
            } else {
                $ReturnObject = @($AvailableUpdates)
            }
        }
    }

    if ($Antivirus -or $All) {
        $Command = "<request><anti-virus><upgrade><check></check></upgrade></anti-virus></request>"

        $ResponseData = Invoke-PaOperation $Command

        $AvailableUpdates = $ResponseData.'content-updates'.entry
        if ($AvailableUpdates.current -eq 'no') {
            if ($Quiet) {
                $ReturnObject = $true
            } else {
                if ($ReturnObject.Gettype().BaseType.Name -eq "array") {
                    $ReturnObject += @($AvailableUpdates)
                } else {
                    $ReturnObject = @($AvailableUpdates)
                }
            }
        }
    }

    return $ReturnObject
}

###############################################################################
# Invoke-PaContentInstall
function Invoke-PaContentInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="av")]
        [switch]$Antivirus,

        [Parameter(Mandatory=$True,ParameterSetName="app")]
        [switch]$AppsAndThreats
    )

    if ($Antivirus) {
        $Command = "<request><anti-virus><upgrade><install><version>latest</version></install></upgrade></anti-virus></request>"
    }
    if ($AppsAndThreats) {
        $Command = "<request><content><upgrade><install><version>latest</version></install></upgrade></content></request>"
    }

    if ($ShowProgress) { $WaitForCompletion = $true }

    $ResponseData = Invoke-PaOperation $Command
    $global:test = $ResponseData
    $Job = $ResponseData.job

    $JobParams = @{ 'Id' = $Job
                    'CheckInterval' = 5 }

    if ($ShowProgress)      { $JobParams += @{ 'ShowProgress' = $true } }
    if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

    $JobStatus = Get-PaJob @JobParams
    if ($JobStatus.NextJob) {
        $JobParams.Set_Item('Id',$JobStatus.NextJob)
        $JobStatus = Get-PaJob @JobParams
    }
    $global:test2 = $JobStatus
    if ($JobStatus.Result -eq 'Fail') {
        Throw $JobStatus.Details
    }
}

###############################################################################
# Invoke-PaOperation
function Invoke-PaOperation {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Command
    )

    HelperCheckPaConnection

    $QueryTable = @{ type = "op"
                     cmd  = $Command }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)

    return HelperCheckPaError $Response
}

###############################################################################
# Invoke-PaSoftwareCheck
function Invoke-PaSoftwareCheck {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet
    )

    $ReturnObject = $False

    $Command = "<request><system><software><check></check></software></system></request>"

    $ResponseData = Invoke-PaOperation $Command
    $global:Test = $ResponseData
        

    $AvailableUpdates = $ResponseData.'sw-updates'.versions.entry
    if ($AvailableUpdates[0].Version -ne $Global:PaDeviceObject.OsVersion) {
        $ReturnObject = $true
    }

    return $ReturnObject
}

###############################################################################
# Invoke-PaSoftwareInstall
function Invoke-PaSoftwareInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion,

        [Parameter(Mandatory=$True,ParameterSetName="latest")]
        [switch]$Latest,

        [Parameter(Mandatory=$True,ParameterSetName="nextstep")]
        [switch]$NextStep,

        [Parameter(Mandatory=$True,ParameterSetName="version")]
        [string]$Version
    )

    $CmdletName = $MyInvocation.MyCommand.Name

    $AvailableSoftware = Get-PaSoftwareInfo
    $CurrentVersion    = $Global:PaDeviceObject.OsVersion

    if ($Latest)  { $DesiredEntry = $AvailableSoftware[0] }
    if ($Version) { $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $Version } }
    
    if ($NextStep) {
        $MajorReleases       = $AvailableSoftware | Select @{Name = 'MajorRelease'; Expression = {$_.Version.SubString(0,3)}} -Unique
        $CurrentMajorRelease = $CurrentVersion.Substring(0,3)
        $CurrentIndex        = [array]::IndexOf($MajorReleases.MajorRelease,$CurrentMajorRelease)
        HelperWriteCustomVerbose $CmdletName "CurrentIndex: $CurrentIndex"
        if ($CurrentIndex -gt 0) {
            $DesiredIndex        = $CurrentIndex - 1
        } else {
            $DesiredIndex = $CurrentIndex
        }
        $DesiredMajorRlease  = [string]($MajorReleases[$DesiredIndex].MajorRelease)
        $DesiredVersion      = $DesiredMajorRlease + '.0'
        
        if ($CurrentMajorRelease -eq $DesiredMajorRlease) {
            HelperWriteCustomVerbose $CmdletName "CurrentMajorRelease ($CurrentVersion) matches DesiredMajorRelase ($DesiredMajorRlease)"
            $DesiredEntry = $AvailableSoftware[0]
        } else {
            $DesiredEntry = $AvailableSoftware | ? { $_.Version -eq $DesiredVersion }
        }
    }

    write-Debug "CurrentVersion is $CurrentVersion, Installing $($DesiredEntry.Version)"

    
    if ($DesiredEntry.Current -eq 'no') {
        if ($DesiredEntry.Downloaded -eq 'no') {
            Throw $DesiredEntry.Downloaded + "Not downloaded, please use Get-PaSoftwareUpgrades"
        } else {
            $Command = "<request><system><software><install><version>$($DesiredEntry.Version)</version></install></software></system></request>"

            $ResponseData = Invoke-PaOperation $Command
            $global:test  = $ResponseData
            $Job          = $ResponseData.job
    
            $JobParams = @{ 'Id' = $Job
                            'CheckInterval' = 5 }
    
            if ($ShowProgress)      {
                $JobParams += @{ 'ShowProgress' = $true } 
                $WaitForCompletion = $true
            }

            if ($WaitForCompletion) { $JobParams += @{ 'WaitForCompletion' = $true } }

            $JobStatus = Get-PaJob @JobParams
            if ($JobStatus.Result -eq 'Fail') {
                Throw $JobStatus.Details
            }
            return $JobStatus
        }
    } else {
        return $DesiredEntry.Version + " already installed"
    }
}

###############################################################################
# New-PaSecurityRule
function New-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidatePattern('^[a-zA-Z0-9\-_\.]{1,31}$')]
        [string]$Name,

        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet("universal","intrazone","interzone")]
        [string]$RuleType = "universal",

        [Parameter(Mandatory=$false,Position=2)]
        [ValidateLength(1,255)]
        [string]$Description,

        [Parameter(Mandatory=$false,Position=3)]
        [array]$Tags,

        [Parameter(Mandatory=$false)]
        [switch]$Disabled
    )

    $NewRule             = New-Object PowerAlto.SecurityRule
    $NewRule.Name        = $Name
    $NewRule.RuleType    = $RuleType
    $NewRule.Description = $Description
    $NewRule.Tags        = $Tags
    $NewRule.Disabled    = $Disabled

    return $NewRule
}

###############################################################################
# Remove-PaConfig
function Remove-PaConfig {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Xpath = "/config"
    )

    HelperCheckPaConnection

    $QueryTable = @{ type   = "config"
                     xpath  = $Xpath
                     action = "delete"  }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)
    $global:test2 = $Response

    return HelperCheckPaError $Response
}

###############################################################################
# Resolve-PaAddress
function Resolve-PaAddress {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[array]$Name,
        
        [Parameter(Mandatory=$False)]
        [switch]$ShowNames
    )

    $ReturnObject = @()
    
    foreach ($n in $Name) {
        try {
            $CheckForAddress = Get-PaAddressObject $n
            
            $NewObject = "" | Select Name,Value
            $NewObject.Name = $CheckForAddress.Name
            $NewObject.Value = $CheckForAddress.Address
            
            if ($ShowNames) {
                $ReturnObject += $NewObject
            } else {
                $ReturnObject += $CheckForAddress.Address
            }
        } catch {
            try {
                $CheckForGroup = Get-PaAddressGroupObject $n
                if ($ShowNames) {
                    $ReturnObject += Resolve-PaAddress $CheckForGroup.Members -ShowNames
                } else {
                    $ReturnObject += Resolve-PaAddress $CheckForGroup.Members
                }
            } catch {
                $NewObject = "" | Select Name,Value
                $NewObject.Value = $n
                if ($ShowNames) {
                    $ReturnObject += $NewObject
                } else {
                    $ReturnObject += $n
                }
            }
        } 
    }
    
    return $ReturnObject
}

###############################################################################
# Restart-PaDevice
function Restart-PaDevice {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [switch]$Quiet,

        [Parameter(Mandatory=$False)]
        [switch]$ShowProgress,
        
        [Parameter(Mandatory=$False)]
        [switch]$WaitForCompletion
    )

    $CmdletName = $MyInvocation.MyCommand.Name

    $Device = $global:PaDeviceObject.Device
    $ApiKey = $global:PaDeviceObject.ApiKey

    $TimerStart = Get-Date

    HelperWriteCustomVerbose $CmdletName "Issuing restart command"
    $Command      = "<request><restart><system></system></restart></request>"
    $ResponseData = Invoke-PaOperation $Command
    HelperWriteCustomVerbose $CmdletName "Restart command issued"
    
    $global:PaDeviceObject = $null

    $ProgressParams = @{'Activity'         = "Waiting for device to reboot"
                        'CurrentOperation' = "Checking status in $CheckInterval seconds..."}
    
    $JobParams = @{ 'Id' = 1
                    'CheckInterval' = 5 }

    if ($ShowProgress) {
        $JobParams         += @{ 'ShowProgress' = $true } 
        $WaitForCompletion  = $true
    }

    if ($WaitForCompletion) {
        $JobParams += @{ 'WaitForCompletion' = $true }

        $CheckInterval   = 15
        $InitialInterval = 60
        $i = 0

        while ($i -lt ($InitialInterval - $CheckInterval)) {
            Start-Sleep -s 1
            $i ++
            if ($ShowProgress) {
                $ProgressParams.Set_Item("CurrentOperation","Checking Status in $($InitialInterval - $i) seconds...")
                Write-Progress @ProgressParams
            }
        }

        if ($ShowProgress) {
            $ProgressParams.Set_Item("CurrentOperation","Trying to reconnect...")
            Write-Progress @ProgressParams
        }
    

        $IsUp = $False
        HelperWriteCustomVerbose $CmdletName "Starting check loop"
        while (!($IsUp)) {
            try {
                $i = 0
                while ($i -lt $CheckInterval) {
                    Start-Sleep -s 1
                    $i ++
                    if ($ShowProgress) {
                        $ProgressParams.Set_Item("CurrentOperation","Checking Status in $($CheckInterval - $i) seconds...")
                        Write-Progress @ProgressParams
                    }
                }

                if ($ShowProgress) {
                    $ProgressParams.Set_Item("CurrentOperation","Trying to reconnect...")
                    Write-Progress @ProgressParams
                }
                $TimerStop     = Get-Date
                $ExecutionTime = [math]::Truncate(($TimerStop - $TimerStart).TotalSeconds)
                HelperWriteCustomVerbose $CmdletName "$ExecutionTime seconds elapsed, trying to connect"

                $Reconnect = Get-PaDevice -Device $Device -ApiKey $ApiKey
            
                HelperWriteCustomVerbose $CmdletName "Connection succeeeded"
                $IsUp = $true
            } catch {
                $IsUp = $False
                switch ($_.Exception.Message) {
                    {$_ -match 'System.Web.HttpException'} {
                        HelperWriteCustomVerbose $CmdletName "Device is not up yet"
                    }
                    default {
                        Throw $_.Exception.Message
                    }
                }
            }
        }

        $ProgressParams.Set_Item("Completed",$true)
        Write-Progress @ProgressParams
    
        #####################################################################################
        # Wait for autocommit job to complete



        $JobStatus = Get-PaJob @JobParams
        if ($JobStatus.NextJob) {
            $JobParams.Set_Item('Id',$JobStatus.NextJob)
            $JobStatus = Get-PaJob @JobParams
        }
        $global:test2 = $JobStatus
        if ($JobStatus.Result -eq 'Fail') {
            Throw $JobStatus.Details
        }
    }
}

###############################################################################
# Set-PaAddress
function Set-PaAddress {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Object',Mandatory=$True,ValueFromPipeline=$True)]
        [PowerAlto.AddressObject]$AddressObject,

        [Parameter(Mandatory=$false)]
        [switch]$NoValidation,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    $Action = "set"
    $Xpath  = HelperCreateXpath address

    if ($NoValidation) {
        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    } else {
        $Rules     = Get-PaSecurityRule
        $Tags      = Get-PaTag
        $Zones     = Get-PaZone
        $Addresses = Get-PaAddressObject

        # Check for rules with this name
        $RuleLookup = $Rules | ? { $_.Name -eq $SecurityRule.Name }
        if ($RuleLookup -and !($Force)) {
            Write-Verbose "Checking for existing Security Policy with Name $($SecurityRule.Name)"
            Throw "Security Policy with the name $($SecurityRule.Name) already exists, use -Force to overwrite"
        }

        # Check for Tags
        foreach ($t in $SecurityRule.Tags) {
            Write-Verbose "Checking for tag `"$t`""
            $TagLookup = $Tags | ? { $_.Name -eq $t }
            if (!($TagLookup)) {
                Throw "Tag `"$t`" does not exist."
            }
        }

        # Check for Zones
        foreach ($z in $SecurityRule.SourceZone) {
            Write-Verbose "Checking for Source Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Source Zone `"$z`" does not exist."
            }
        }

        foreach ($z in $SecurityRule.DestinationZone) {
            Write-Verbose "Checking for Destination Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Destination Zone `"$z`" does not exist."
            }
        }

        # Check for Addresses
        $IpRx = [regex] '(\d+\.){3}\d+(\/\d+)?'
        foreach ($a in $SecurityRule.SourceAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Source Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Source Address `"$a`" does not exist."
                }
            }
        }

        foreach ($a in $SecurityRule.DestinationAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Destination Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Destination Address `"$a`" does not exist."
                }
            }
        }

        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    }

    return $ResponseData
}

###############################################################################
# Set-PaConfig
function Set-PaConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Xpath = "/config",

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateSet("set")]
        [string]$Action,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Element
    )

    HelperCheckPaConnection

    $QueryTable = @{ type    = "config"
                     xpath   = $Xpath
                     action  = $Action
                     element = $Element }
    
    Write-Debug "xpath: $Xpath"
    Write-Debug "action: $Action"
    Write-Debug "element: $Element"

    $QueryString = HelperCreateQueryString $QueryTable
    Write-Debug $QueryString
    $Url         = $PaDeviceObject.UrlBuilder($QueryString)
    Write-Debug $Url
    $Response    = HelperHttpQuery $Url -AsXML

    return HelperCheckPaError $Response
}

###############################################################################
# Set-PaRuleApplication
function Set-PaRuleApplication {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Application = "any",

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.Application = $Application

    if ($PassThru) {
        return $Rule
    }
}

###############################################################################
# Set-PaRuleDestination
function Set-PaRuleDestination {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Zone = "any",

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$Address = "any",

        [Parameter(Mandatory=$false,Position=3,ParameterSetName="security")]
        [switch]$Negate,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.DestinationZone    = $Zone
    $Rule.DestinationAddress = $Address
    $Rule.DestinationNegate  = $Negate

    if ($PassThru) {
        return $Rule
    }
}

###############################################################################
# Set-PaRuleServiceUrl
function Set-PaRuleServiceUrl {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Service,

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$UrlCategory,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    if ($Service)     { $Rule.Service = $Service }
    if ($UrlCategory) { $Rule.UrlCategory = $UrlCategory }

    if ($PassThru) {
        return $Rule
    }
}

###############################################################################
# Set-PaRuleSource
function Set-PaRuleSource {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$Zone = "any",

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$Address = "any",

        [Parameter(Mandatory=$false,Position=3,ParameterSetName="security")]
        [switch]$Negate,

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.SourceZone    = $Zone
    $Rule.SourceAddress = $Address
    $Rule.SourceNegate  = $Negate

    if ($PassThru) {
        return $Rule
    }
}

###############################################################################
# Set-PaRuleUser
function Set-PaRuleUser {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName="security",ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        [Parameter(Mandatory=$false,Position=1,ParameterSetName="security")]
        [array]$User = "any",

        [Parameter(Mandatory=$false,Position=2,ParameterSetName="security")]
        [array]$HipProfile = "any",

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    $Rule.SourceUser = $User
    $Rule.HipProfile = $HipProfile

    if ($PassThru) {
        return $Rule
    }
}

###############################################################################
# Set-PaSecurityRule
function Set-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Object',Mandatory=$True,ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$SecurityRule,

        [Parameter(Mandatory=$false)]
        [switch]$NoValidation,

        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    $Action = "set"
    $Xpath  = $SecurityRule.XPath

    if ($NoValidation) {
        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    } else {
        $Rules     = Get-PaSecurityRule
        $Tags      = Get-PaTag
        $Zones     = Get-PaZone
        $Addresses = Get-PaAddressObject

        # Check for rules with this name
        $RuleLookup = $Rules | ? { $_.Name -eq $SecurityRule.Name }
        if ($RuleLookup -and !($Force)) {
            Write-Verbose "Checking for existing Security Policy with Name $($SecurityRule.Name)"
            Throw "Security Policy with the name $($SecurityRule.Name) already exists, use -Force to overwrite"
        }

        # Check for Tags
        foreach ($t in $SecurityRule.Tags) {
            Write-Verbose "Checking for tag `"$t`""
            $TagLookup = $Tags | ? { $_.Name -eq $t }
            if (!($TagLookup)) {
                Throw "Tag `"$t`" does not exist."
            }
        }

        # Check for Zones
        foreach ($z in $SecurityRule.SourceZone) {
            Write-Verbose "Checking for Source Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Source Zone `"$z`" does not exist."
            }
        }

        foreach ($z in $SecurityRule.DestinationZone) {
            Write-Verbose "Checking for Destination Zone `"$z`""
            $ZoneLookup = $Zones | ? { $_.Name -eq $z }
            if (!($ZoneLookup)) {
                Throw "Destination Zone `"$z`" does not exist."
            }
        }

        # Check for Addresses
        $IpRx = [regex] '(\d+\.){3}\d+(\/\d+)?'
        foreach ($a in $SecurityRule.SourceAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Source Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Source Address `"$a`" does not exist."
                }
            }
        }

        foreach ($a in $SecurityRule.DestinationAddress) {
            $IpMatch = $IpRx.Match($a)
            if (!($IpMatch.Success) -and ($a -ne 'any')) {
                Write-Verbose "Checking for Destination Address `"$a`""
                $AddressLookup = $Addresses | ? { $_.name -eq $a }
                if (!($AddressLookup)) {
                    Throw "Destination Address `"$a`" does not exist."
                }
            }
        }

        $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $SecurityRule.PrintPlainXml()
    }

    return $ResponseData
}

###############################################################################
# Set-PaSecurityRuleActions
function Set-PaSecurityRuleActions {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$True)]
        [PowerAlto.SecurityRule]$Rule,

        #################################################################

        [Parameter(Mandatory=$true,Position=1,ParameterSetName="Action")]
        [ValidateSet("allow","deny")]
        [array]$Action,

        #################################################################
        
        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [switch]$LogStart,

        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [switch]$LogEnd,

        [Parameter(Mandatory=$false,ParameterSetName="Log")]
        [string]$LogForwarding,

        #################################################################

        [Parameter(Mandatory=$True,ParameterSetName="ProfileGroup")]
        [string]$ProfileGroup,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$Antivirus,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$VulnerabilityProtection,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$AntiSpyware,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$UrlFiltering,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$FileBlocking,

        [Parameter(Mandatory=$False,ParameterSetName="Profiles")]
        [string]$DataFiltering,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Schedule")]
        [string]$Schedule,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="Dscp")]
        [ValidateSet("af11","af12","af13","af21","af22","af23","af31",
                     "af32","af33","af41","af42","af43")]
        [string]$DscpMarking,

        #################################################################

        [Parameter(Mandatory=$False,ParameterSetName="IpPrecedence")]
        [ValidateSet("af11","af12","af13","af21","af22","af23","af31",
                     "af32","af33","af41","af42","af43","cs0","cs1",
                     "cs2","cs3","cs4","cs5","cs6","cs7","ef")]
        [string]$IpPrecedence,

        #################################################################
        
        [Parameter(Mandatory=$false,ParameterSetName="SRI")]
        [switch]$DisableSRI,

        #################################################################

        [Parameter(Mandatory=$false)]
        [switch]$PassThru
    )

    if ($Action) {
        if ($Action -eq "allow") { $Rule.Allow = $true } 
                            else { $Rule.Allow = $false }
    }

    if ($LogStart)      { $Rule.LogAtSessionStart = $true }
    if ($LogEnd)        { $Rule.LogAtSessionEnd   = $true }
    if ($LogForwarding) { $Rule.LogForwarding     = $LogForwarding }

    if ($ProfileGroup)  { $Rule.ProfileGroup = $ProfileGroup }

    if ($Antivirus)                { $Rule.AntivirusProfile     = $Antivirus }
    if ($VulnerabilityProtection)  { $Rule.VulnerabilityProfile = $VulnerabilityProtection }
    if ($AntiSpyware)              { $Rule.AntiSpywareProfile   = $AntiSpyware }
    if ($UrlFiltering)             { $Rule.UrlFilteringProfile  = $UrlFiltering }
    if ($FileBlocking)             { $Rule.FileBlockingProfile  = $FileBlocking }
    if ($DataFiltering)            { $Rule.DataFilteringProfile = $DataFiltering }

    if ($Schedule) { $Rule.Schedule = $Schedule }

    if ($DscpMarking) {
        $Rule.QosType    = 'ip-dscp'
        $Rule.QosMarking = $DscpMarking
    }

    if ($IpPrecedence) {
        $Rule.QosType    = 'ip-precedence'
        $Rule.QosMarking = $IpPrecedence
    }

    if ($DisableSRI) { $Rule.DisableSRI = $true }

    if ($PassThru) {
        return $Rule
    }
}


###############################################################################
# HelperCheckPaConnection
function HelperCheckPaConnection {
    if (!($Global:PaDeviceObject)) {
        Throw "Not connected to any Palo Alto Devices."
    }
}

###############################################################################
# HelperCheckPaError
function HelperCheckPaError {
    [CmdletBinding()]
	Param (
	    [Parameter(Mandatory=$True,Position=0)]
	    $Response
    )

    $CmdletName = $MyInvocation.MyCommand.Name

    $Status = $Response.data.response.status
    HelperWriteCustomVerbose $CmdletName "Status returned: $Status"

    if ($Response.data.response.result.error) {
        $ErrorMessage = $Response.data.response.result.error
    }

    if ($Status -eq "error") {
        if ($Response.data.response.msg.line -eq "Command succeeded with no output") {
            HelperWriteCustomVerbose $CmdletName $Response.data.response.msg.line
            #placeholder for stupid restart api call
        } elseif ($Response.data.response.code) {
            $ErrorMessage  = "Error Code $($Response.data.response.code): "
            $ErrorMessage += $Response.data.response.result.msg
        } elseif ($Response.data.response.msg.line) {
            Write-Verbose "Line is: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg.line
        } elseif ($Response.error) {
            $ErrorMessage = $Response.error
        } else {
            Write-Verbose "Message: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg
        }
    }
    if ($ErrorMessage) {
        Throw "$ErrorMessage`."
    } else {
        return $Response.data.response.result
    }
}

###############################################################################
# HelperConvertFilterToPosh
function HelperConvertFilterToPosh {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$True,Position=0)]
		[string]$Filter,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$VariableName,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Property
    )

    $FilterSplit = $Filter.Split()

    $MatchString = "`$$VariableName | ? { "
    foreach ($f in $FilterSplit) {
        switch ($f) {
            { $_ -match '^(and|or)$' } { $MatchString += " -$f " }
                               default { $MatchString += "( `$_.$Property -contains `"$f`" )" }
        }
    }
    $MatchString += " }"

    return $MatchString
}

###############################################################################
# HelperCreateQueryString
function HelperCreateQueryString {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
		[hashtable]$QueryTable
    )

    $QueryString = [System.Web.httputility]::ParseQueryString("")

    foreach ($Pair in $QueryTable.GetEnumerator()) {
	    $QueryString[$($Pair.Name)] = $($Pair.Value)
    }

    return $QueryString.ToString()
}

###############################################################################
# HelperCreateXpath
function HelperCreateXpath {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
		[string]$Node
    )

    $DeviceType  = ($Global:PaDeviceObject).Type
    $DeviceGroup = ($Global:PaDeviceObject).DeviceGroup
    switch ($DeviceType) {
        panorama {
            switch ($DeviceGroup) {
                shared {
                    $Xpath = "/config/shared/$Node"
                    break
                }
                default {
                    $Xpath = "/config/devices/entry/device-group/entry[@name='$DeviceGroup']/$Node"
                    break
                }
            }
            break
        }
        firewall {
            $Xpath = "/config/devices/entry/vsys/entry/$Node"
            break
        }
    }
    
    return $Xpath
}

###############################################################################
# HelperGetPropertyMembers
function HelperGetPropertyMembers {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        $XmlObject,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$XmlProperty
    )

    $ReturnObject = @()
    
    if ($XmlObject.$XmlProperty) {
        foreach ($x in $XmlObject.$XmlProperty.member) { $ReturnObject += $x }
    }

    return $ReturnObject
}

###############################################################################
# HelperHttpQuery
function HelperHTTPQuery {
	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[string]$URL,

		[Parameter(Mandatory=$False)]
		[alias('xml')]
		[switch]$AsXML
	)

	try {
		$Response = $null
		$Request = [System.Net.HttpWebRequest]::Create($URL)
		$Response = $Request.GetResponse()
		if ($Response) {
			$StatusCode = $Response.StatusCode.value__
			$DetailedError = $Response.GetResponseHeader("X-Detailed-Error")
		}
	}
	catch {
		$ErrorMessage = $Error[0].Exception.ErrorRecord.Exception.Message
		$Matched = ($ErrorMessage -match '[0-9]{3}')
		if ($Matched) {
			throw ('HTTP status code was {0} ({1})' -f $HttpStatusCode, $matches[0])
		}
		else {
			throw $ErrorMessage
		}

		#$Response = $Error[0].Exception.InnerException.Response
		#$Response.GetResponseHeader("X-Detailed-Error")
	}

	if ($Response.StatusCode -eq "OK") {
		$Stream    = $Response.GetResponseStream()
		$Reader    = New-Object IO.StreamReader($Stream)
		$FullPage  = $Reader.ReadToEnd()

		if ($AsXML) {
			$Data = [xml]$FullPage
            if ($Global:PaDeviceObject) { $Global:PaDeviceObject.LastXmlResult = $Data }
		} else {
			$Data = $FullPage
		}

		$Global:LastResponse = $Data

		$Reader.Close()
		$Stream.Close()
		$Response.Close()
	} else {
		Throw "Error Accessing Page $FullPage"
	}

	$ReturnObject = "" | Select-Object StatusCode,DetailedError,Data
	$ReturnObject.StatusCode = $StatusCode
	$ReturnObject.DetailedError = $DetailedError
	$ReturnObject.Data = $Data
    
    

	return $ReturnObject
}

###############################################################################
# HelperWriteCustomVerbose
function HelperWriteCustomVerbose {
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$True,Position=0)]
	    [string]$Cmdlet,

	    [Parameter(Mandatory=$True,Position=1)]
	    [string]$Message
    )
    Write-Verbose "$Cmdlet`: $Message"
}

###############################################################################
## Export Cmdlets
###############################################################################

Export-ModuleMember *-*

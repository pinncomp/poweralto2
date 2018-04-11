Function Export-PaConfig {

Param (

    [Parameter(Mandatory=$True,Position=0)]
	[string]$Device,
    
    [Parameter(Mandatory=$True,Position=1)]
	[string]$Path
)

HelperCheckPaConnection

If (Test-Path "$env:HOMEPATH\Config") {} Else {
                                                New-Item -ItemType directory -Path "$path\Config"
                                                New-Item -ItemType directory -Path "$path\Config\Archive"
                                            }
$filecheck = Get-ChildItem -File "$path\Config" | where {$_.Name -notlike "temp.xml"}

If ( $filecheck -ne $null ) {


    $(Get-PAConfig).InnerXML | Out-File "$path\Config\temp.xml"
    $tempfile = Get-ChildItem -File "$path\Config" -Filter temp.xml

    If (diff -ReferenceObject $(Get-Content $tempfile.FullName)  -DifferenceObject $(Get-Content $filecheck.FullName) ) {
       Move-Item $filecheck.FullName -Destination "$path\Config\Archive"
        $(Get-PAConfig).InnerXML | Out-File "$path\Config\$((get-date).tostring("MMddyyyyHHmmss")).xml"
            Remove-Item -Force $tempfile.FullName        
    }
    Else { Remove-Item -Force $tempfile.FullName  }
}

If ( $filecheck -eq $null ) { $(Get-PAConfig).InnerXML | Out-File "$path\Config\$((get-date).tostring("MMddyyyyHHmmss")).xml" }

}
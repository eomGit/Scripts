param(
    [string] $assemblyName = $(throw 'assemblyName is required'),
    [object] $object
)

process {
	if ($_) {
		$object = $_
	}
	
	if (! $object) {
		throw 'must pass an -object parameter or pipe one in'
	}
	
	# load the required dll
	#$assembly = [System.Reflection.Assembly]::LoadWithPartialName($assemblyName)
	$assembly = [System.Reflection.Assembly]::LoadFile($assemblyName)
	
	# add each type as a member property
	try {
	$assembly.GetTypes() | 
	where {$_.ispublic -and !$_.IsSubclassOf( [Exception] ) -and $_.name -notmatch "event"} | 
	foreach { 
		# avoid error messages in case it already exists
		if (! ($object | get-member $_.name)) {
			add-member noteproperty $_.name $_ -inputobject $object
		}
	}
	}
	catch {
		write-host 'Wow!'
	  $object=$_
	  $_
	}
}
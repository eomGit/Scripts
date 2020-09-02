Function Set-InternetProxy
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[String[]]$Proxy,

		[Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[AllowEmptyString()]
		[String[]]$WirelessNIC,

		[Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[AllowEmptyString()]
		[String[]]$SSID,

		[Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[AllowEmptyString()]
		[String[]]$Password
	)

	Begin
	{
		$regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	}

	Process
	{
		if ($SSID -NE $null)
		{
			write-host "Setting $WirelessNIC to $SSID"
			$exec='netsh wlan connect name="' + $SSID + '" ssid="' + $SSID + '" interface="' +$WirelessNIC + '"' # key="' + $Password + '"'
			write-host $exec
			invoke-expression $exec
		}
		
		if ($proxy -eq $null)
		{
			write-host "Disabling proxy"
			Set-ItemProperty -path $regKey ProxyEnable -value 0
		}
		else
		{
			write-host "Setting proxy to $proxy"
			Set-ItemProperty -path $regKey ProxyEnable -value 1
			Set-ItemProperty -path $regKey ProxyServer -value $proxy
		}
		
		if($acs)
		{
			write-host "Setting autoconfig URL to $zcs"
			Set-ItemProperty -path $regKey AutoConfigURL -Value $acs
		}
	}
	End
	{
		if ($proxy -eq $null)
		{
			Write-Output "Proxy is now disabled"
		}
		else
		{
			Write-Output "Proxy is now enabled"
		}

		if ($acs)
		{
			Write-Output "Automatic Configuration Script : $acs"
		}
		else
		{
			Write-Output "Automatic Configuration Script : Not Defined"
		}
	}
}



<#
# Get the current IP Address
Function Get-IPAddress
{
return $env:HostIP = (
Get-NetIPConfiguration |
Where-Object {
$_.IPv4DefaultGateway -ne $null -and
$_.NetAdapter.Status -ne "Disconnected"
}
).IPv4Address.IPAddress

}

$ipAdress = Get-IPAddress
Write-Host $ipAdress

if ($ipAdress.substring(0,3) -eq "10.")
{
Write-Host "Set proxy"
Set-InternetProxy -proxy "proxy.com:8080"
}
else
{
Set-InternetProxy -disable
}
#>
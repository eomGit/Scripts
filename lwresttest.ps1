Param(
[string]$strUsername="username",
[string]$strPassWord="password",
[string]$strBaseURL="https://labworks.server.com/"
)
#$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$strJSON='{"connection":{"UserName":"' + $strUsername + '","Password":"' + $strPassWord + '","SourceSystem":"PSTESTER","SourceSystemVersion":"1.0","ServiceProviderId":""}}'
$strURL="$($strBaseURL)/lwwebapps/WLWservices/WLWAtlasServiceBus/AtlasServiceBus.asmx/Authenticate"
try
{
	write-host "Authenticating against $($strBaseURL)"
	$objReturn = Invoke-RestMethod -UseDefaultCredentials -Uri "$strURL" -Method Post -Body $strJSON -ContentType application/json

	$strSessionID = $objreturn.d.SessionID

	<#
	Foreach ($strPropertyName in $objreturn.d.psobject.properties.name)
	{
	 write-host "$strPropertyName ==> $($objreturn.d.$strPropertyName)"
	}
	#>
	write-host "Received $strSessionID as session ID"
	write-host "Getting Site list"
	$strURL="$($strBaseURL)/lwwebapps/WLWservices/WLWAtlasServiceBus/AtlasServiceBus.asmx/GetSites"
	$strJSON = '{"getSitesRequest":{"Session":{"SessionID":"' + $($strSessionID)+ '","PageName":"Atlas Service Bus Testing","BrandingCode":""},"BookmarkInfo":{"Bookmark":""}}}'
	#write-host $strURL
	#write-host $strJSON
	$objReturn2 = Invoke-RestMethod -UseDefaultCredentials -Uri "$strURL" -Method Post -Body $strJSON -ContentType application/json

	ConvertTo-json $objreturn2

	$xxx = $objreturn2.d.SiteList[0] 

	<#
	Foreach ($strPropertyName in $xxx.psobject.properties.name)
	{
	 write-host "$strPropertyName ==> $($XXX.$strPropertyName)"
	}

	<#
	SiteRowId ==> U14032
	ID ==> U14032
	Namespace ==> SITE111
	Name ==> 3A Clinic - UHC (U14032)
	Address1 ==>
	Address2 ==>
	Address3 ==>
	IsActive ==> True
	IsLiveSite ==> True
	IsPSCSite ==> False
	#>
	$strSiteRow = $xxx.SiteRowID

	write-host "First site is $($strSiteRow) - $($objreturn2.d.SiteList[0].Name)"
	$strJson='{"selectSiteRequest":{"Session":{"SessionID":"' + $($strSessionID) + '","PageName":"Atlas Service Bus Testing","BrandingCode":""},"Site":{"SiteRowId":"' + $($strSiteRow)+ '"}}}'
	#$strJson='{"selectSiteRequest":{"Session":{"SessionID":"' + $($strSessionID) + '","PageName":"Atlas Service Bus Testing","BrandingCode":""},"Site":{"SiteRowId":"2"}}}'
	write-host "Selecting site"
	$strURL="$($strBaseURL)/lwwebapps/wlwservices/wlwatlasservicebus/atlasservicebus.asmx/SelectSite"
	write-host "Site Selected"

	write-host $strJSON
	$objReturn3 = Invoke-RestMethod -UseDefaultCredentials -Uri "$strURL" -Method Post -Body $strJSON -ContentType application/json

	$strJson='{"createInfolinkIssueRequest":{"Session":{"SessionID":"' + $($strSessionID) + '","PageName":"Atlas Service Bus Testing","BrandingCode":""},"InfolinkIssue":{"IssueType":{"InfolinkIssueTypeRowId":"NTI1"},"Order":{"Number":"","Accession":""},"Patient":{"ID":"","PatientInsuranceList":[{"InsuranceProvider":{"ID":""}}]},"Status":"N","Distribution":"","Source":"","Recipients":"","Subject":"","Description":"NTI description","FieldName":"","RegEx":"","InformativeMessage":"","GenericFieldValue":"","Test":{"Code":""}},"InfolinkIssueNote":{"NoteBody":""}}}'
	$strURL="$($strBaseURL)/lwwebapps/wlwservices/wlwatlasservicebus/atlasservicebus.asmx/CreateInfolinkIssue"
	$objReturn4 = Invoke-RestMethod -UseDefaultCredentials -Uri "$strURL" -Method Post -Body $strJSON -ContentType application/json
	write-host "waaaaa?"
	ConvertTo-json $objReturn4
}
catch
{}
finally 
{
	$strJSON='{"logoutRequest":{"Session":{"SessionID":""' + $($strSessionID) + '"","PageName":"Atlas Service Bus Testing","BrandingCode":""}}}'
	$strURL="$($strBaseURL)/lwwebapps/wlwservices/wlwatlasservicebus/atlasservicebus.asmx/Logout"
	$objReturn5 = Invoke-RestMethod -UseDefaultCredentials -Uri "$strURL" -Method Post -Body $strJSON -ContentType application/json
}
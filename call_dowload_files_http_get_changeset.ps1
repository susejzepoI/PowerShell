#Description:       The aim of this script is to iterate the download_files_http_get_v1.ps1 script by changeset.
#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      June-26-2024
#Modified date:     July-01-2024

# JLopez: List of all changesets to be downloaded (add here your changesets).
[string[]]$ichangesetList = @(
    "1234149",
    "1231414",
    "1544315"
)
# JLopez: PAT
# JLopez: This parameter contains the Personal Access Token of your organization.
# JLopez: This parameter is personal, each account have a unique PAT.
# JLopez: To found the PAT of your account, you can found this over the azure devops porta > User settings > Personal Access Tokens > Regenerate.
$iPAT           = Read-Host "Enter your PAT "
$iOrganization  = Read-Host "Enter you Organization name "
$iDpath         = Read-Host "Enter the path that will be used to download all files "

# JLopez: Sorting the array ascending
$sortArrayofChangesets = $ichangesetList | Sort-Object

foreach ($ichangesetId in $sortArrayofChangesets) {
    $params = @{
        vOrganization   = $iOrganization
        vchangeset      = $ichangesetId
        vPAT            = $iPAT
        vdpath          = $iDpath
    }

	Write-Host "*************************************************"
	Write-Host "-------------------------------------------------"	
	Write-Host "/////////////////////////////////////////////////"
	Write-Host "-------------------------------------------------"
	Write-Host "*************************************************"
    Write-Host "Dowload the changeset: $ichangesetId"
    
    .\download_files_http_get_v1.ps1 @params

	Write-Host "Finished to download the changeset: $ichangesetId"	
	Write-Host "*************************************************"
	Write-Host "-------------------------------------------------"	
	Write-Host "/////////////////////////////////////////////////"
	Write-Host "-------------------------------------------------"
	Write-Host "*************************************************"
    Write-Host ""
    Write-Host ""
}
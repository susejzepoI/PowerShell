#Description:       The aim of this script is download all the files in specific changeset on Azure Devops.
#Author:            Jesus Lopez Mesia
#Linkedin:          https://www.linkedin.com/in/susejzepol/
#Created date:      June-26-2024
#Modified date:     July-01-2024


[CmdletBinding()]
param (
    # JLopez: This parameter contains the organization's name.
    [Parameter(Mandatory=$true)]
    [string]
    $vOrganization,

    # JLopez: This parameter contains the changesetid to be downloaded.
    [Parameter(Mandatory=$true)]
    [string]$vchangeset,
    
    # JLopez: This parameter contains the Personal Access Token of your organization.
    # JLopez: This parameter is personal, each account have a unique PAT for their virtual machine.
    [Parameter(Mandatory =$true, HelpMessage = "PAT of your account, you can found this over the azure devops porta > User settings > Personal Access Tokens > Regenerate.")]
    [string] $vPAT,

    # JLopez: Local path to be use to download all the files in the changeset.
    [Parameter(Mandatory=$true)]
    [string] $vdpath
)


# Variables
$organization   = $vOrganization
$changesetId    = $vchangeset
$pat            = $vPAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Base URI for Azure DevOps REST API
# $uri = "https://dev.azure.com/$organization/$project/_apis/tfvc/changesets/$changesetId/changes?api-version=6.0"
$uri = "https://dev.azure.com/$organization/_apis/tfvc/changesets/$changesetId/changes?api-version=6.0"

# Fetch Changeset Details
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")}

# Check if we have any changes in the response
if ($response.count -gt 0) {
    $folderPath = $vdpath
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath
    }

    foreach ($change in $response.value) {
        $filePath = $change.item.path
        $fileName = [System.IO.Path]::GetFileName($filePath)
        $fileUri = $change.item.url
        
        #JLopez: Download each file
        $tempFile = Join-Path $folderPath ($fileName + ".tmp")
        
        Invoke-RestMethod -Uri $fileUri -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")} -OutFile $tempFile

        #JLopez: Read the content from the temporary file as a byte array
        $byteResponse = [System.IO.File]::ReadAllBytes($tempFile)

        #JLopez: Save to disk
        #JLopez: Create the full path name for the new file.
        $fileFullPath = Join-Path $folderPath $fileName

        #JLopez: Write all the content over the new file.
        # [System.IO.File]::WriteAllText($fileFullPath, $fileResponse)
        [System.IO.File]::WriteAllBytes($fileFullPath, $byteResponse)
        Write-Host "Downloaded '$fileName' to '$fileFullPath'"

        #JLopez: Cleaning the temporary file
        Remove-Item -Path $tempFile
    }
} else {
    Write-Host "No changes found in the changeset."
}
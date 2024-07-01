
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$vchangeset,
    
    # JLopez: This parameter contains the Personal Access Token of your organization.
    # JLopez: This parameter is personal, each developer have a unique PAT for their virtual machine.
    [Parameter(Mandatory =$true, HelpMessage = "PAT of your account, you can found this over the azure devops porta > User settings > Personal Access Tokens > Regenerate.")]
    [string] $vPAT,

    # Download path
    [Parameter(Mandatory=$true)]
    [string] $vdpath
)


# Variables
# $organization = "nagnoitfs.visualstudio.com" ##
$organization = "nagnoitfs"
# $project = "StarsTrack"
$changesetId = $vchangeset
$pat = $vPAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Base URI for Azure DevOps REST API
# $uri = "https://$organization/$project/_apis/tfvc/changesets/$changesetId/changes?api-version=6.0"
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
        
        # Download each file
        # $fileResponse = Invoke-RestMethod -Uri $fileUri -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")}
        $fileResponse = Invoke-RestMethod -Uri $fileUri -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")} -ContentType 'application/octet-stream' -OutFile $null
        # Save to disk
        $fileFullPath = Join-Path $folderPath $fileName
        # [System.IO.File]::WriteAllText($fileFullPath, $fileResponse)
        [System.IO.File]::WriteAllBytes($fileFullPath, $fileResponse)
        Write-Host "Downloaded '$fileName' to '$fileFullPath'"
    }
} else {
    Write-Host "No changes found in the changeset."
}
# Change file owner to "Administrators" of this PC [PowerShell]

function Set-FileOwnership {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Validate if the target path exists and is a file
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        Write-Host "[!] Error: The specified path does not exist or is not a file." -ForegroundColor Red
        return
    }

    try {
        $newOwner = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
        $acl = Get-Acl -Path $FilePath

        if ($acl.Owner -ne $newOwner.Value) {

            # Check Administrator Privileges.
            $CurrentIdentity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            if (-not $CurrentIdentity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                Write-Host "[!] Error: You don't have Administrator privileges!" -ForegroundColor Red
                return
            }

            $acl.SetOwner($newOwner)

            # Apply the modified ACL back to the file
            Set-Acl -Path $FilePath -AclObject $acl -ErrorAction Stop

            Write-Host "Successfully changed owner of '$FilePath' to '$($newOwner.Value)'" -ForegroundColor Green
        }
    } catch {
        Write-Error "An unexpected error occurred during the process: $($_.Exception.Message)"
    }
}
# Set-FileOwnership -FilePath "%UserProfile%\Desktop\file.txt"

function Set-FolderFilesOwnership {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetFolderPath
    )

    # Validate if the target path exists and is a directory
    if (-not (Test-Path -Path $TargetFolderPath -PathType Container)) {
        Write-Host "[!] Error: The specified target folder path does not exist or is not a directory." -ForegroundColor Red
        return
    }

    try {
        $files = Get-ChildItem -Path $TargetFolderPath -File -ErrorAction Stop
        foreach ($file in $files) {
            Set-FileOwnership -FilePath $file.FullName
        }
    } catch {
        Write-Error "An unexpected error occurred during the process: $($_.Exception.Message)"
    }
}
# Set-FolderFilesOwnership -TargetFolderPath "%UserProfile%\Desktop\"

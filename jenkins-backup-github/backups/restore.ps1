# CONFIGURATION

$repoPath = "C:\users\subha\jenkins-backup-project\jenkins-backup-github"
$jenkinsHome = "C:\ProgramData\Jenkins.jenkins"

Write-Output "Starting Jenkins Restore Process..."

# STEP 1: Go to repository

Set-Location $repoPath

# STEP 2: Pull latest backups from GitHub

Write-Output "Pulling latest backup files from GitHub..."
git pull origin main

# STEP 3: Find latest backup ZIP

$latestBackup = Get-ChildItem "$repoPath\backups" -Filter "*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# STEP 4: Validate backup exists

if ($null -eq $latestBackup) {
Write-Output "ERROR: No backup ZIP file found."
exit 1
}

Write-Output "Latest backup found:"
Write-Output $latestBackup.FullName

# STEP 5: Stop Jenkins service

Write-Output "Stopping Jenkins service..."
Stop-Service jenkins -Force

# Wait for service to stop

Start-Sleep -Seconds 5

# STEP 6: Clean existing Jenkins home

if (Test-Path $jenkinsHome) {
Write-Output "Removing existing Jenkins data..."
Remove-Item "$jenkinsHome*" -Recurse -Force
}
else {
New-Item -ItemType Directory -Path $jenkinsHome -Force
}

# STEP 7: Extract backup

Write-Output "Restoring backup..."
Expand-Archive -Path $latestBackup.FullName -DestinationPath $jenkinsHome` -Force

# STEP 8: Start Jenkins service

Write-Output "Starting Jenkins service..."
Start-Service jenkins

# STEP 9: Verify Jenkins service

$serviceStatus = (Get-Service jenkins).Status

if ($serviceStatus -eq "Running") {
Write-Output "SUCCESS: Jenkins restored successfully."
}
else {
Write-Output "WARNING: Restore completed but Jenkins service is not running."
}

Write-Output "Restore Process Completed."

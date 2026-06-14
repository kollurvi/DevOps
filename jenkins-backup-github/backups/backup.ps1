# CONFIGURATION
$jenkinsHome = "C:\ProgramData\Jenkins\.jenkins"
$repoPath = "C:\jenkins-backup\jenkins-backup-repo"
$backupFolder = "$repoPath\backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# STEP 1: Ensure backup directory exists
New-Item -ItemType Directory -Force -Path $backupFolder

# STEP 2: Create temporary backup folder
$tempBackup = "$backupFolder\temp_$timestamp"
New-Item -ItemType Directory -Force -Path $tempBackup

# STEP 3: Copy Jenkins data
Copy-Item "$jenkinsHome\*" $tempBackup -Recurse -Force

# STEP 4: Zip backup
$zipFile = "$backupFolder\jenkins_backup_$timestamp.zip"
Compress-Archive -Path "$tempBackup\*" -DestinationPath $zipFile -Force

# STEP 5: Remove temp folder
Remove-Item $tempBackup -Recurse -Force

# STEP 6: Git operations
Set-Location $repoPath

git add backups/

git commit -m "Jenkins backup $timestamp"

git push origin master

Write-Output "Backup pushed to Git successfully at $timestamp"
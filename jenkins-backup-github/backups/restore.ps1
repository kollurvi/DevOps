$repoPath = "C:\users\subha\jenkins-backup-project\jenkins-backup-github"
$jenkinsHome = "C:\ProgramData\Jenkins\.jenkins"

Set-Location $repoPath

# Pull latest from GitHub
git pull origin main

# Get latest backup
$latestBackup = Get-ChildItem "$repoPath\backups" -Filter "*.zip" |
Sort-Object LastWriteTime -Descending |
Select-Object -First 1

# Stop Jenkins
Stop-Service jenkins

# Clear Jenkins data
Remove-Item "$jenkinsHome\*" -Recurse -Force

# Restore backup
Expand-Archive $latestBackup.FullName -DestinationPath $jenkinsHome -Force

# Start Jenkins
Start-Service jenkins

Write-Output "Jenkins restored successfully from GitHub backup"
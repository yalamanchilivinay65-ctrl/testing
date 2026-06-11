  # Install IIS Web Server Role
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Verify Installation
Get-WindowsFeature -Name Web-Server

# Ensure IIS Service is Running
Start-Service W3SVC
Set-Service W3SVC -StartupType Automatic

# Create Test Web Page
$WebRoot = "C:\inetpub\wwwroot"

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>IIS Test Page</title>
</head>
<body style="font-family:Arial;text-align:center;margin-top:100px;">
    <h1>IIS Successfully Installed</h1>
    <h2>Windows Server 2016 Datacenter</h2>
    <p>Provisioned using PowerShell</p>
    <p>Server Name: $env:COMPUTERNAME</p>
    <p>Date: $(Get-Date)</p>
</body>
</html>
"@

$html | Out-File "$WebRoot\index.html" -Encoding UTF8

# Remove default IIS page if present
Remove-Item "$WebRoot\iisstart.htm" -ErrorAction SilentlyContinue

# Restart IIS
iisreset

# Display Status
Write-Host "==================================" -ForegroundColor Green
Write-Host "IIS Installation Completed" -ForegroundColor Green
Write-Host "Browse to: http://localhost" -ForegroundColor Yellow
Write-Host "Server Name: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Green


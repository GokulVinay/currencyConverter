$ErrorActionPreference = "Stop"
if ($env:MVNW_VERBOSE -eq "true") {
  $VerbosePreference = "Continue"
}

# Read Maven distribution URL
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$distributionUrl = (Get-Content -Raw "$scriptDir/.mvn/wrapper/maven-wrapper.properties" | ConvertFrom-StringData).distributionUrl
if (!$distributionUrl) {
  Write-Error "Cannot read distributionUrl property in $scriptDir/.mvn/wrapper/maven-wrapper.properties"
}

# Compute Maven home path
$distributionUrlName = $distributionUrl -split '/' | Select-Object -Last 1
$MAVEN_HOME_PARENT = "$HOME/.m2/wrapper/dists"
$MAVEN_HOME_NAME = ([System.Security.Cryptography.MD5]::Create().ComputeHash([byte[]][char[]]$distributionUrl) | ForEach-Object { $_.ToString("x2") }) -join ''
$MAVEN_HOME = "$MAVEN_HOME_PARENT/$MAVEN_HOME_NAME"

if (Test-Path -Path "$MAVEN_HOME" -PathType Container) {
  Write-Output "MVN_CMD=$MAVEN_HOME/bin/mvn"
  exit 0
}

# Create directory
New-Item -ItemType Directory -Path "$MAVEN_HOME_PARENT" -Force | Out-Null

# Download Apache Maven
Write-Verbose "Downloading Maven from: $distributionUrl"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $distributionUrl -OutFile "$MAVEN_HOME_PARENT/$distributionUrlName"

# Extract and move
Expand-Archive -Path "$MAVEN_HOME_PARENT/$distributionUrlName" -DestinationPath "$MAVEN_HOME_PARENT" -Force
Rename-Item -Path "$MAVEN_HOME_PARENT/$distributionUrlName" -NewName $MAVEN_HOME_NAME -Force

Write-Output "MVN_CMD=$MAVEN_HOME/bin/mvn"

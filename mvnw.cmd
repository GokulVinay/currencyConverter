$ErrorActionPreference = "Stop"
if ($env:MVNW_VERBOSE -eq "true") {
  $VerbosePreference = "Continue"
}

# Read Maven distribution URL
$distributionUrl = (Get-Content -Raw "$scriptDir/.mvn/wrapper/maven-wrapper.properties" | ConvertFrom-StringData).distributionUrl
if (!$distributionUrl) {
  Write-Error "Cannot read distributionUrl property in $scriptDir/.mvn/wrapper/maven-wrapper.properties"
}

$distributionUrlName = $distributionUrl -replace '^.*/',''
$distributionUrlNameMain = $distributionUrlName -replace '\.[^.]*$','' -replace '-bin$',''
$MAVEN_HOME_PARENT = "$HOME/.m2/wrapper/dists/$distributionUrlNameMain"
$MAVEN_HOME_NAME = ([System.Security.Cryptography.MD5]::Create().ComputeHash([byte[]][char[]]$distributionUrl) | ForEach-Object {$_.ToString("x2")}) -join ''
$MAVEN_HOME = "$MAVEN_HOME_PARENT/$MAVEN_HOME_NAME"

if (Test-Path -Path "$MAVEN_HOME" -PathType Container) {
  Write-Output "MVN_CMD=$MAVEN_HOME/bin/mvn"
  exit $?
}

New-Item -Itemtype Directory -Path "$MAVEN_HOME_PARENT" -Force | Out-Null

# Download Apache Maven
Write-Verbose "Downloading Maven from: $distributionUrl"
$webclient = New-Object System.Net.WebClient
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$webclient.DownloadFile($distributionUrl, "$MAVEN_HOME_PARENT/$distributionUrlName") | Out-Null

# Extract and move
Expand-Archive "$MAVEN_HOME_PARENT/$distributionUrlName" -DestinationPath "$MAVEN_HOME_PARENT" | Out-Null
Rename-Item -Path "$MAVEN_HOME_PARENT/$distributionUrlNameMain" -NewName $MAVEN_HOME_NAME | Out-Null

Write-Output "MVN_CMD=$MAVEN_HOME/bin/mvn"

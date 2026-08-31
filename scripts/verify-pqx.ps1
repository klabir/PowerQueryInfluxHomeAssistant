param(
    [Parameter(Mandatory = $true)] [string] $MakePqxPath,
    [Parameter(Mandatory = $true)] [string] $PqxPath
)

$ErrorActionPreference = "Stop"
& $MakePqxPath verify $PqxPath
if ($LASTEXITCODE -ne 0) {
    throw "MakePQX signature verification failed with exit code $LASTEXITCODE."
}

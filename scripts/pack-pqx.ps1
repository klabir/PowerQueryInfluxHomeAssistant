param(
    [Parameter(Mandatory = $true)] [string] $MakePqxPath,
    [Parameter(Mandatory = $true)] [string] $MezPath,
    [Parameter(Mandatory = $true)] [string] $PqxPath
)

$ErrorActionPreference = "Stop"
& $MakePqxPath pack --mez $MezPath --target $PqxPath
if ($LASTEXITCODE -ne 0) {
    throw "MakePQX pack failed with exit code $LASTEXITCODE."
}

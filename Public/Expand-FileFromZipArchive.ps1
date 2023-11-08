function Expand-FileFromZipArchive
{
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string]$Path,

        [Parameter(Mandatory)]
        [string[]]$ZipEntryPath
    )
}
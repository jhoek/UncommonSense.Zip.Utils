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

    $ZipSize = switch ($PSCmdlet.ParameterSetName)
    {
        'Uri'
        {
            Get-ZipSize -Uri $Uri
        }

        'Path'
        {
            Get-ZipSize -Uri $Path
        }
    }

    $ZipBytes = byte[$ZipSize]
    $LastChunkOffset = $ZipSize - 50kb
    $LastChunkSize = $ZipSize - 1

    $LastChunk = switch ($PSCmdlet.ParameterSetName)
    {
        'Uri'
        {
            Get-ZipByte -Uri $Uri -Offset $LastChunkOffset -Size $LastChunkSize
        }

        'Path'
        {

        }
    }


}
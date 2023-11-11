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

    $ZipSize = Get-ZipSize -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)"
    $ZipBytes = byte[$ZipSize]

    $LastChunkOffset = $ZipSize - 50kb
    $LastChunkSize = $ZipSize - 1
    $LastChunk = Get-ZipByte -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)"
    $LastChunk.CopyTo($ZipBytes, $LastChunkOffset)

    $Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $LastChunkText = $Encoding.GetString($LastChunk)

    $LastChunkText
}
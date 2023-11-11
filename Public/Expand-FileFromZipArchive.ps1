function Expand-FileFromZipArchive
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
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
    Write-Verbose "Zip size is $ZipSize bytes"

    $ZipBytes = [byte[]]::new($ZipSize)

    $LastChunkOffset = [System.Math]::Min($ZipSize - 50kb, $ZipSize)
    $LastChunkSize = $ZipSize - 1
    $LastChunk = Get-ZipByte -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)" -Offset $LastChunkOffset -Size $LastChunkSize
    $LastChunk.CopyTo($ZipBytes, $LastChunkOffset)

    $Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $LastChunkText = $Encoding.GetString($LastChunk)

    $LastChunkText
}
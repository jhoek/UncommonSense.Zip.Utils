function Expand-FileFromZipArchive
{
    [CmdletBinding()]
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string]$Path,

        [Parameter(Mandatory)]
        [string[]]$ZipEntryPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Destination = '.',

        [switch]$Force
    )

    $Destination = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Destination)

    if ($Path) { $Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path) }

    $ZipSize = Get-ZipSize -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)"
    Write-Verbose "Zip size is $ZipSize bytes"

    $ZipBytes = [byte[]]::new($ZipSize)

    $LastChunkOffset = [System.Math]::Max($ZipSize - 50kb, 0)
    $LastChunkSize = $ZipSize - 1
    [byte[]]$LastChunk = Get-ZipByte -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)" -Offset $LastChunkOffset -Size $LastChunkSize
    $LastChunk.CopyTo($ZipBytes, $LastChunkOffset)

    $Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $LastChunkText = $Encoding.GetString($LastChunk)
    $EndOfCentralDirectoryText = [regex]::Match($LastChunkText, 'PK\x05\x06.*').Value
    $EndOfCentralDirectoryBytes = $Encoding.GetBytes($EndOfCentralDirectoryText)
    $CentralDirectoryInfo = Get-ZipCentralDirectoryInfo $EndOfCentralDirectoryBytes

    $CentralDirectoryBytes = [byte[]]::new($CentralDirectoryInfo.Size)
    [Array]::Copy($ZipBytes, $CentralDirectoryInfo.Offset, $CentralDirectoryBytes, 0, $CentralDirectoryInfo.Size)
    $CentralDirectoryText = $Encoding.GetString($CentralDirectoryBytes)

    $Files = [regex]::Split($CentralDirectoryText, 'PK\x01\x02')
    | Where-Object { $_.Length -ge 42 }
    | ForEach-Object {
        $FileHeader = $_
        $FileHeaderBytes = $Encoding.GetBytes($_)
        $FileNameLength = [BitConverter]::ToUInt16($FileHeaderBytes, 24)
        $FileName = $FileHeader.SubString(42, $FileNameLength)
        $FileCompressedSize = [BitConverter]::ToUInt32($FileHeaderBytes, 16)
        $FileOffset = [BitConverter]::ToUInt32($FileHeaderBytes, 38)

        [PSCustomObject]@{
            FileHeader         = $_
            FileHeaderBytes    = $FileHeaderBytes
            FileNameLength     = $FileNameLength
            FileName           = $FileName
            FileCompressedSize = $FileCompressedSize
            FileOffset         = $FileOffset
        }
    }

    $Files
    | Where-Object FileName -In $ZipEntryPath
    | ForEach-Object {
        [byte[]]$CompressedFileBytes = Get-ZipByte -Type $PSCmdlet.ParameterSetName -PathOrUri "$($Path)$($Uri)" -Offset $_.FileOffset -Size $_.FileCompressedSize
        $CompressedFileBytes.CopyTo($ZipBytes, $_.FileOffset)
    }

    $Files
    | Where-Object FileName -In $ZipEntryPath
    | ForEach-Object `
        -Begin {
        $ZipMemoryStream = [System.IO.MemoryStream]::new()
        $ZipMemoryStream.Write($ZipBytes, 0, $ZipBytes.Length)
        $ZipArchive = [System.IO.Compression.ZipArchive]::new($ZipMemoryStream)
    } `
        -Process {
        $ZipArchiveEntry = $ZipArchive.GetEntry($_.FileName)
        $DestinationPath = Join-Path -Path $Destination -ChildPath $_.FileName
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($ZipArchiveEntry, $DestinationPath, $Force)
    }
}
function Expand-FileFromZipArchive
{
    [CmdletBinding(DefaultParameterSetName = 'Expand')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Expand')]
        [string[]]$ZipEntryPath,

        [Parameter(ParameterSetName = 'Expand')]
        [ValidateNotNullOrEmpty()]
        [string]$Destination = '.',

        [Parameter(ParameterSetName = 'Expand')]
        [switch]$Force,

        [Parameter(ParameterSetName = 'Expand')]
        [Alias('FlattenDirStructure')]
        [switch]$NoContainer,

        [Parameter(Mandatory, ParameterSetName = 'ListOnly')]
        [switch]$ListOnly,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$CentralDirSize = 250kb
    )

    $Destination = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Destination)
    $Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")

    $ZipSize = Get-ZipSize -Uri $Uri
    Write-Verbose "Zip size is $ZipSize bytes"

    $ZipBytes = [byte[]]::new($ZipSize)

    $LastChunkOffset = [System.Math]::Max($ZipSize - $CentralDirSize, 0)
    $LastChunkSize = $ZipSize - 1
    [byte[]]$LastChunk = Get-ZipByte -Uri $Uri -Offset $LastChunkOffset -Size $LastChunkSize
    $LastChunk.CopyTo($ZipBytes, $LastChunkOffset)

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

    if ($ListOnly)
    {
        ($Files).FileName
        return
    }

    # FIXME: Consider looping through $ZipEntryPath instead, thus making it easier to detect if $ZipEntryPath is not present in the zip file

    $Files
    | Where-Object FileName -In $ZipEntryPath
    | ForEach-Object {
        [byte[]]$CompressedFileBytes = Get-ZipByte -Uri $Uri -Offset $_.FileOffset -Size $_.FileCompressedSize
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
        $CurrentItem = $_

        $DestinationPath = switch ($NoContainer)
        {
            $true { Join-Path -Path $Destination -ChildPath (Split-Path -Path $CurrentItem.FileName -Leaf) }
            $false { Join-Path -Path $Destination -ChildPath $CurrentItem.FileName }
        }

        $DestinationFolder = Split-Path -Path $DestinationPath -Parent

        if (-not (Test-Path -Path $DestinationFolder))
        {
            New-Item -Path $DestinationFolder -ItemType Directory
        }

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($ZipArchiveEntry, $DestinationPath, $Force)
    }
}
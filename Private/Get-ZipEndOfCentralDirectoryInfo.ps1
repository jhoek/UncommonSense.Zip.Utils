function Get-ZipCentralDirectoryInfo
{
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [byte[]]$InputObject
    )

    begin
    {
        $Bytes = [System.Collections.Generic.List[byte]]::new()
    }

    process
    {
        $Bytes.AddRange($InputObject)
    }

    end
    {
        [PSCustomObject]@{
            PSTypeName = 'UncommonSense.Zip.Utils.EOCDInfo'
            Offset     = [System.BitConverter]::ToUInt32($Bytes, 16)
            Size       = [System.BitConverter]::ToUInt32($Bytes, 12)
        }
    }
}
function Get-ZipEndOfCentralDirectoryInfo
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
        # FIXME: Take comments into account

        [PSCustomObject]@{
            PSTypeName             = 'UncommonSense.Zip.Utils.EOCDInfo'
            CentralDirectoryOffset = [System.BitConverter]::ToUInt32($Bytes, 16)
            CentralDirectorySize   = [System.BitConverter]::ToUInt32($Bytes, 12)
        }
    }
}

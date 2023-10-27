function Get-ZipEndOfCentralDirectoryInfo
{
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [byte[]]$InputObject
    )

    # FIXME: Take comments into account

    [PSCustomObject]@{
        PSTypeName             = 'UncommonSense.Zip.Utils.EOCDInfo'
        CentralDirectoryOffset = [System.BitConverter]::ToUInt32($InputObject, 16)
        CentralDirectorySize   = [System.BitConverter]::ToUInt32($InputObject, 12)
    }
}

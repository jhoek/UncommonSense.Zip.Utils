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
        $Pointer = 0

        $FileNameLength = [System.BitConverter]::ToUInt16($Bytes, $Pointer + 28)
        $ExtraFieldLength = [System.BitConverter]::ToUInt16($Bytes, $Pointer + 30)
        $FileCommentLength = [System.BitConverter]::ToUInt16($Bytes, $Pointer + 32)

        [PSCustomObject]@{
            FileNameLength    = $FileNameLength
            ExtraFieldLength  = $ExtraFieldLength
            FileCommentLength = $FileCommentLength
        }
    }
}
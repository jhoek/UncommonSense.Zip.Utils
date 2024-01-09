function Get-ZipByte
{
    [OutputType([byte])]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Uri,

        [Parameter(Mandatory, Position = 1)]
        [int]$Offset,

        [Parameter(Mandatory, Position = 2)]
        [int]$Size
    )

    Invoke-WebRequest `
        -Uri $Uri `
        -Headers @{'Range' = "bytes=$($Offset)-$($Offset + $Size - 1)" }
        | Select-Object -ExpandProperty Content
}
function Get-ZipByte
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([byte])]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Uri', Position = 0)]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)]
        [string]$Path,

        [Parameter(Mandatory, Position = 1)]
        [int]$Offset,

        [Parameter(Mandatory, Position = 2)]
        [int]$Size
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'Uri'
        {
            Invoke-WebRequest `
                -Uri $Uri `
                -Headers @{'Range' = "bytes=$($Offset)-$($Offset + $Size - 1)" }
            | Select-Object -ExpandProperty Content
        }

        'Path'
        {
            Get-Content `
                -Path $Path `
                -AsByteStream
            | Select-Object -Skip $Offset -First $Size
        }
    }
}
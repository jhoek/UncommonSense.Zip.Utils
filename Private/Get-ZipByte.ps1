function Get-ZipByte
{
    [OutputType([byte])]
    param
    (
        [Parameter(Position = 0)]
        [ValidateSet('Path', 'Uri')]
        [ValidateNotNullOrEmpty()]
        [string]$Type = 'Path',

        [Parameter(Mandatory, Position = 1)]
        [string]$PathOrUri,

        [Parameter(Mandatory, Position = 2)]
        [int]$Offset,

        [Parameter(Mandatory, Position = 3)]
        [int]$Size
    )

    switch ($Type)
    {
        'Uri'
        {
            Invoke-WebRequest `
                -Uri $PathOrUri `
                -Headers @{'Range' = "bytes=$($Offset)-$($Offset + $Size - 1)" }
            | Select-Object -ExpandProperty Content
        }

        'Path'
        {
            Get-Content `
                -Path $PathOrUri `
                -AsByteStream
            | Select-Object -Skip $Offset -First $Size
        }
    }
}
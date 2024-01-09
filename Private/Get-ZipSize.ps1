function Get-ZipSize
{
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Uri
    )

    Invoke-WebRequest `
        -Uri $Uri `
        -Method Head
    | Select-Object -ExpandProperty Headers
    | ForEach-Object { $_.'Content-Length' }
}
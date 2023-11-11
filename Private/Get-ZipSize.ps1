function Get-ZipSize
{
    [OutputType([int])]
    param
    (
        [Parameter(Position = 0)]
        [ValidateSet('Path', 'Uri')]
        [ValidateNotNullOrEmpty()]
        [string]$Type = 'Path',

        [Parameter(Mandatory, Position = 1)]
        [string]$PathOrUri
    )

    switch ($Type)
    {
        'Uri'
        {
            Invoke-WebRequest `
                -Uri $PathOrUri `
                -Method Head
            | Select-Object -ExpandProperty Headers
            | ForEach-Object { $_.'Content-Length' }
        }

        'Path'
        {
            Get-Item -Path $PathOrUri
            | Select-Object -ExpandProperty Size
        }
    }
}
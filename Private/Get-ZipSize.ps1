function Get-ZipSize
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Uri', Position = 0)]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)]
        [string]$Path
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'Uri'
        {
            Invoke-WebRequest `
                -Uri $Uri `
                -Method Head
            | Select-Object -ExpandProperty Headers
            | ForEach-Object { $_.'Content-Length' }
        }

        'Path'
        {
            Get-Item -Path $Path
            | Select-Object -ExpandProperty Size
        }
    }
}
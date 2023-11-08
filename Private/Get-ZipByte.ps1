function Get-ZipByte
{
    [OutputType([byte])]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [string]$Uri,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string]$Path,

        [Parameter(Mandatory)]
        [int]$Offset,

        [Parameter(Mandatory)]
        [int]$Size
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'Uri'
        {
            Invoke-WebRequest -Uri $Uri
        }

        'Path'
        {

        }
    }
}
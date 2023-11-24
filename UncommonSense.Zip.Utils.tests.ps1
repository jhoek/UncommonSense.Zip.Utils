Describe 'UncommonSense.Zip.Utils' {
    It 'Successfully extracts a file from a url' {
        Expand-FileFromZipArchive `
            -Uri 'https://bcartifacts.azureedge.net/onprem/19.4.35398.35482/de' `
            -ZipEntryPath 'Applications\BaseApp\Source\Microsoft_Base Application.app' `
            -Destination TestDrive:/FromUrl

        (Join-Path -Path TestDrive:/FromUrl -ChildPath 'Applications\BaseApp\Source\Microsoft_Base Application.app' ) | Should -Exist
    }
    It 'Successfully extracts a file from a local path' {
        Expand-FileFromZipArchive `
            -Path ./test.zip `
            -ZipEntryPath 'Applications\BaseApp\Source\Microsoft_Base Application.app' `
            -Destination TestDrive:/FromPath

        (Join-Path -Path TestDrive:/FromPath -ChildPath 'Applications\BaseApp\Source\Microsoft_Base Application.app' ) | Should -Exist
    }
}
# FIXME: Consider testing for destination file sizes and contents
# FIXME: Test with multiple extracted files
# FIXME: Test with existing destination file, both with and without -Force present

Describe 'UncommonSense.Zip.Utils' {
    It 'Successfully extracts a file from a url' {
        Expand-FileFromZipArchive `
            -Uri 'https://github.com/jhoek/UncommonSense.Zip.Utils/raw/main/test.zip' `
            -ZipEntryPath 'foo.txt' `
            -Destination TestDrive:/FromUrl

        (Join-Path -Path TestDrive:/FromUrl -ChildPath 'foo.txt' ) | Should -Exist
    }
    It 'Successfully extracts a file from a local path' {
        Expand-FileFromZipArchive `
            -Path ./test.zip `
            -ZipEntryPath 'foo.txt' `
            -Destination TestDrive:/FromPath

        (Join-Path -Path TestDrive:/FromPath -ChildPath 'foo.txt' ) | Should -Exist
    }
}
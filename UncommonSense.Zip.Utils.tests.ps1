. ./Private/Get-ZipByte.ps1

Get-ZipByte ~/Dropbox/test.zip 0 10
Get-ZipByte -Uri 'https://www.dropbox.com/scl/fi/73eei6vciw7e73x3vzb3m/test.zip?rlkey=xket6dhbe2qd1fnfh1yc13ni9&dl=1' 0 10

# Describe 'UncommonSense.Zip.Utils' {
#     Context 'From a url' {
#         It 'Successfully extracts a file' {}
#     }
#     Context 'From a file' {
#         It 'Successfully extracts a file' {}
#     }
# }

# $CentralDirectory = Get-Content -Path ~/Desktop/test.zip -AsByteStream
# | Select-Object -Last 22
# | Get-ZipEndOfCentralDirectoryInfo

# Get-Content -Path ~/Desktop/test.zip -AsByteStream
# | Select-Object -Skip $CentralDirectory.Offset -First $CentralDirectory.Size
# | Get-ZipCentralDirectoryInfo
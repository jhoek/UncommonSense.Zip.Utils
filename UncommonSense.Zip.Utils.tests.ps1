$CentralDirectory = Get-Content -Path ~/Desktop/test.zip -AsByteStream
| Select-Object -Last 22
| Get-ZipEndOfCentralDirectoryInfo

Get-Content -Path ~/Desktop/test.zip -AsByteStream
| Select-Object -Skip $CentralDirectory.Offset -First $CentralDirectory.Size
| Get-ZipCentralDirectoryInfo
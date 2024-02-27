namespace UncommonSense.Zip.Utils;

[Cmdlet(VerbsData.Expand, "FileFromZipArchive", DefaultParameterSetName = ParameterSetNames.Expand)]
public class ExpandFileFromZipArchiveCmdlet : PSCmdlet
{
    public static class ParameterSetNames
    {
        public const string Expand = nameof(Expand);
        public const string ListOnly = nameof(ListOnly);
    }

    [Parameter(Mandatory = true, Position = 0)]
    public string Uri { get; set; }

    [Parameter(Mandatory = true, Position = 1, ParameterSetName = ParameterSetNames.Expand)]
    public string[] ZipEntryPath { get; set; }

    [Parameter(ParameterSetName = ParameterSetNames.Expand)]
    [ValidateNotNullOrEmpty()]
    public string Destination { get; set; } = ".";

    [Parameter(ParameterSetName = ParameterSetNames.Expand)]
    public SwitchParameter Force { get; set; }

    [Parameter(ParameterSetName = ParameterSetNames.Expand)]
    [Alias("FlattenDirStructure")]
    public SwitchParameter NoContainer { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = ParameterSetNames.ListOnly)]
    public SwitchParameter ListOnly { get; set; }

    protected override void EndProcessing()
    {
        Destination = GetUnresolvedProviderPathFromPSPath(Destination);
        Directory.CreateDirectory(Destination);

        using var zipStream = new System.IO.Compression.HttpZipStream(Uri);
        var entries = zipStream.GetEntriesAsync().Result;

        switch (ParameterSetName)
        {
            case ParameterSetNames.ListOnly:
                WriteObject(entries, true);
                break;

            case ParameterSetNames.Expand:
                ZipEntryPath
                    .Select(p => new { LocalPath = BuildLocalFilePath(p, NoContainer, Destination), ZipEntry = entries.Single(e => e.FileName.Matches(p)) })
                    .ToList()
                    .ForEach(p => File.WriteAllBytes(p.LocalPath, zipStream.ExtractAsync(p.ZipEntry).Result));

                break;
        }
    }

    private string BuildLocalFilePath(string zipEntryPath, bool noContainer, string destination) =>
        Path.Combine(Destination, noContainer ? zipEntryPath.Split('/', '\\').Last() : zipEntryPath);
}
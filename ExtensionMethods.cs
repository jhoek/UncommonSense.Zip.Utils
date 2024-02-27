namespace UncommonSense.Zip.Utils;

public static class ExtensionMethods
{
    public static bool Matches(this string text, string value) =>
        // FIXME: Wildcard support?
        text.Equals(value, StringComparison.InvariantCultureIgnoreCase);
}
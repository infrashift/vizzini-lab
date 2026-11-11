namespace Shop.Legacy;

public static class ReportFormatter
{
    public static string Header(string title)
    {
        int width;
        return $"== {title} ==";
    }
}

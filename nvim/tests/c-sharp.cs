
public class Foo
{
    private static int NumberOfInstances = 0;

    public Foo()
    {
        NumberOfInstances++;
    }

    public static int GetNumberOfInstances()
    {
        return NumberOfInstances;
    }
}

namespace Xpirit.EscapeRoom.IntegrationTests;

public class PerTestFixture<T> : IAsyncLifetime where T : new()
{
    protected T Context => _context != null ? _context : throw new InvalidOperationException("Context was not instantiated");
    private T _context;

    public virtual async Task InitializeAsync()
    {
        _context = new T();
        if (Context is IAsyncLifetime asyncLifetime)
        {
            await asyncLifetime.InitializeAsync();
        }
    }

    public virtual async Task DisposeAsync()
    {
        if (Context is IDisposable disposable)
        {
            disposable.Dispose();
        }
        if (Context is IAsyncLifetime asyncLifetime)
        {
            await asyncLifetime.DisposeAsync();
        }
        _context = default(T);
    }
}
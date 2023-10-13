using Rebus.Bus;

namespace Xpirit.EscapeRoom.Broker;

public class RebusQueue : IQueue
{
    private readonly IBus _bus;

    public RebusQueue(IBus bus)
    {
        _bus = bus ?? throw new ArgumentNullException(nameof(bus));
    }

    public async Task Enqueue<T>(T payload)
    {
        await _bus.Send(payload);
    }

    public async Task Enqueue<T>(IEnumerable<T> payloads)
    {
        foreach (T payload in payloads)
        {
            await Enqueue(payload);
        }
    }
}
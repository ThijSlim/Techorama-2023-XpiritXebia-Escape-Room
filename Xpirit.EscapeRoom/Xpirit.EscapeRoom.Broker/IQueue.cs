namespace Xpirit.EscapeRoom.Broker;

public interface IQueue
{
    Task Enqueue<T>(T payload);

    Task Enqueue<T>(IEnumerable<T> payload);
}
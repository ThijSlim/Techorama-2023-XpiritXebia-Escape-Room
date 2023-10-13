namespace Xpirit.EscapeRoom.Domain.Ports;

public interface IBoardQueue
{
    Task<IEnumerable<Team>> GetQueue();
    
    Task<Team?> PopFromQueue();
}
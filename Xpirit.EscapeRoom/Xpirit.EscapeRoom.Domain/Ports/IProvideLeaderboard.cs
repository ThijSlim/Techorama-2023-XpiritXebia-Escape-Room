namespace Xpirit.EscapeRoom.Domain.Ports;

public interface IProvideLeaderboard
{
    Task<IEnumerable<LeaderboardTeam>> GetLeaderboard();
    
}
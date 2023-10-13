namespace Xpirit.EscapeRoom.Domain.Ports;

public interface INewLeaderboardTeam
{
    Task AddLeaderboardTeam(LeaderboardTeam leaderboardTeam);
}
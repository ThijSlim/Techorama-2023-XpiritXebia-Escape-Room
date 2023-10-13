namespace Xpirit.EscapeRoom.Domain.Ports;

public interface INewTeam
{
    Task AddNewTeamAsync(Team teamName);
}
using Rebus.Handlers;
using Xpirit.EscapeRoom.Broker.Models;
using Xpirit.EscapeRoom.Domain;
using Xpirit.EscapeRoom.Domain.Ports;
using Puzzle = Xpirit.EscapeRoom.Domain.Puzzle;

namespace Xpirit.EscapeRoom.Broker.Handlers.Events;

public class GameCompletedHandler : IHandleMessages<GameCompleted>
{
    private readonly INewLeaderboardTeam _newLeaderboardTeam;

    public GameCompletedHandler(INewLeaderboardTeam newLeaderboardTeam)
    {
        _newLeaderboardTeam = newLeaderboardTeam;
    }
    
    public async Task Handle(GameCompleted message)
    {
        var puzzles = message.Puzzles != null ? message.Puzzles.ToList().Select(x => x.ToDomain()).ToList() : new List<Puzzle>();
        var leaderboardTeam = new LeaderboardTeam("", message.TeamName, message.PlayerNames, message.TimeLeft, message.GameCompletedSuccessful, puzzles);

        await _newLeaderboardTeam.AddLeaderboardTeam(leaderboardTeam);
    }
}
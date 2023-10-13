using MongoDB.Driver;
using Xpirit.EscapeRoom.Domain;
using Xpirit.EscapeRoom.Domain.Ports;
using Xpirit.EscapeRoom.Persistence.Models;

namespace Xpirit.EscapeRoom.Persistence.Repositories;

public class LeaderboardRepository : INewLeaderboardTeam, IProvideLeaderboard
{
    private readonly IMongoDatabase _mongoDatabase;
    private const string LeaderboardCollectionName = "Leaderboard";

    public LeaderboardRepository(IMongoDatabase mongoDatabase)
    {
        _mongoDatabase = mongoDatabase;
    }

    public async Task AddLeaderboardTeam(LeaderboardTeam leaderboardTeam)
    {
        var leaderboardTeamModel = new LeaderboardTeamModel
        {
            TeamName = leaderboardTeam.TeamName,
            PlayerNames = leaderboardTeam.PlayerNames,
            TimeLeft = leaderboardTeam.TimeLeft,
            GameCompletedSuccessful = leaderboardTeam.GameCompletedSuccessful,
            Puzzles =  leaderboardTeam.Puzzles.Select(PuzzleModel.FromDomain).ToList(),
            PuzzlesSolvedCount = leaderboardTeam.Puzzles.Count(x => x.Solved)
        };

        await _mongoDatabase.GetCollection<LeaderboardTeamModel>(LeaderboardCollectionName)
            .InsertOneAsync(leaderboardTeamModel);
    }

    public async Task<IEnumerable<LeaderboardTeam>> GetLeaderboard()
    {
        var leaderboard = await _mongoDatabase.GetCollection<LeaderboardTeamModel>(LeaderboardCollectionName)
            .Find(Builders<LeaderboardTeamModel>.Filter.Empty).ToListAsync();

        var orderedLeaderboard = leaderboard.OrderByDescending(x => x.GameCompletedSuccessful).ThenByDescending(x => x.TimeLeft).ThenByDescending(x => x.PuzzlesSolvedCount);

        return orderedLeaderboard.Select(x => new LeaderboardTeam(x.Id.ToString(), x.TeamName, x.PlayerNames, x.TimeLeft, x.GameCompletedSuccessful,
            x.Puzzles != null ? x.Puzzles.Select(puzzle => puzzle.ToDomain()).ToList() : new List<Puzzle>()
        ));
    }
}
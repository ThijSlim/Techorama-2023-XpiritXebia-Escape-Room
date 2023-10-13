using MongoDB.Bson;
using MongoDB.Driver;
using Xpirit.EscapeRoom.Domain;
using Xpirit.EscapeRoom.Domain.Ports;
using Xpirit.EscapeRoom.Persistence.Models;

namespace Xpirit.EscapeRoom.Persistence.Repositories;

public class TeamRepository : INewTeam, IBoardQueue
{
    private IMongoDatabase _mongoDatabase;
    private const string LeaderboardCollectionName = "TeamQueue";

    public TeamRepository(IMongoDatabase mongoDatabase)
    {
        _mongoDatabase = mongoDatabase;
    }

    public async Task AddNewTeamAsync(Team team)
    {
        var teamModel = new TeamModel
        {
            Name = team.Name,
            PlayerNames = team.PlayerNames,
            CreationTime = team.CreationTime
        };

        await _mongoDatabase.GetCollection<TeamModel>(LeaderboardCollectionName).InsertOneAsync(teamModel);
    }


    public async Task<IEnumerable<Team>> GetQueue()
    {
        var queue = await _mongoDatabase.GetCollection<TeamModel>(LeaderboardCollectionName).Find(Builders<TeamModel>.Filter.Empty).ToListAsync();

        var orderedQueue = queue
            .OrderBy(x => x.CreationTime);

        return orderedQueue.Select(x => new Team(x.Id.ToString(), x.Name, x.PlayerNames, x.CreationTime));
    }

    public async Task<Team?> PopFromQueue()
    {
        var queue = await GetQueue();
        var firstTeam = queue.FirstOrDefault();
        if (firstTeam == null)
        {
            return null;
        }
        
        await _mongoDatabase.GetCollection<TeamModel>(LeaderboardCollectionName).DeleteOneAsync(x => x.Id == ObjectId.Parse(firstTeam.Id));
        return new Team(firstTeam.Id, firstTeam.Name, firstTeam.PlayerNames, firstTeam.CreationTime);
    }
}
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Xpirit.EscapeRoom.Persistence.Models;

public class LeaderboardTeamModel
{
    [BsonId]
    public ObjectId Id { get; set; }
    
    public string TeamName { get; set; }
    
    public List<string> PlayerNames { get; set; }
    
    public TimeSpan TimeLeft { get; set; }
    
    public bool GameCompletedSuccessful { get; set; }
    
    public List<PuzzleModel> Puzzles { get; set; }
    
    public int PuzzlesSolvedCount { get; set; }
}
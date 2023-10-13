using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Xpirit.EscapeRoom.Persistence.Models;

public class PuzzleModel
{
    [BsonId]
    public ObjectId Id { get; set; }
    
    public string PuzzleType { get; set; }
    
    public bool Solved { get; set; }
    
    public TimeSpan? SolveTime { get; set; }

    public Domain.Puzzle ToDomain()
    {
        return new Domain.Puzzle(
            Enum.Parse<Domain.PuzzleType>(PuzzleType),
            Solved,
            SolveTime);
    }

    public static PuzzleModel FromDomain(Domain.Puzzle puzzle)
    {
        return new PuzzleModel
        {
            SolveTime = puzzle.SolveTime,
            Solved = puzzle.Solved,
            PuzzleType = puzzle.PuzzleType.ToString()
        };
    }
}
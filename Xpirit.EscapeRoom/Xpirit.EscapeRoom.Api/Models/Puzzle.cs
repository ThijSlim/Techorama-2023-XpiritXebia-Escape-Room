namespace Xpirit.EscapeRoom.Api.Models;

public class Puzzle
{
    public string PuzzleType { get; set; }
    
    public bool Solved { get; set; }
    
    public TimeSpan? SolveTime { get; set; }
    
    public static Puzzle FromDomain(Domain.Puzzle puzzle)
    {
        return new Puzzle
        {
            PuzzleType = puzzle.PuzzleType.ToString(),
            Solved = puzzle.Solved,
            SolveTime = puzzle.SolveTime
        };
    }

    public Broker.Models.Puzzle ToBroker()
    {
        return new Broker.Models.Puzzle
        {
            PuzzleType = PuzzleType,
            Solved = Solved,
            SolveTime = SolveTime
        };
    }
}
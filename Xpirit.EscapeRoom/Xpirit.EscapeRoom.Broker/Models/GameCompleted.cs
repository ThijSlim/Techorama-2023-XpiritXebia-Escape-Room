namespace Xpirit.EscapeRoom.Broker.Models;

public class GameCompleted
{
    public string TeamName { get; set; }

    public List<string> PlayerNames { get; set; }

    public TimeSpan TimeLeft { get; set; }

    public bool GameCompletedSuccessful { get; set; }

    public List<Puzzle>? Puzzles { get; set; }
}

public class Puzzle
{
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
}
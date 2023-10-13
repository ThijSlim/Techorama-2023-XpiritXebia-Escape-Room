namespace Xpirit.EscapeRoom.Domain;

public class Puzzle
{
    public PuzzleType PuzzleType { get; }

    public bool Solved { get; set; }

    public TimeSpan? SolveTime { get; set; }

    public Puzzle(PuzzleType puzzleType, bool solved, TimeSpan? solveTime)
    {
        PuzzleType = puzzleType;
        Solved = solved;
        SolveTime = solveTime;
    }
}
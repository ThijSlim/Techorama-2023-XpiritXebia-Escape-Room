namespace Xpirit.EscapeRoom.Api.Models;

public class GameState
{
    public GameStatus GameStatus { get; set; }

    public TimeSpan TimeLeft { get; set; }
    
    public string? ReadyTeam { get; set; }

    public string? ActiveTeam { get; set; }

    public string? ActiveQuestion { get; set; }
    
    public bool? GameCompletedSuccessful { get; set; }

    public PuzzleType? ActivePuzzleType { get; set; }

    public IEnumerable<Puzzle> GameProgress { get; set; }
    
    public string? ActivatedHint { get; set; }
    
    public TimeSpan? TimeTillHintIsEnabled { get; set; }
    
    public TimeSpan? TimeTillNextAnswerTry { get; set; }
}
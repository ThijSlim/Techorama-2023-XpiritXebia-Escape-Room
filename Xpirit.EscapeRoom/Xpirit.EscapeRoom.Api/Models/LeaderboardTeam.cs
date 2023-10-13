namespace Xpirit.EscapeRoom.Api.Models;

public class LeaderboardTeam
{
    public string TeamName { get; set; }
    
    public List<string> PlayerNames { get; set; }
    
    public TimeSpan TimeLeft { get; set; }

    public bool GameCompletedSuccessful { get; set; }
    
    public List<Puzzle> Puzzles { get; set; }
}
namespace Xpirit.EscapeRoom.Domain;

public class LeaderboardTeam
{
    public string? Id { get; }

    public string TeamName { get; }
    
    public List<string> PlayerNames { get; set; }
    
    public TimeSpan TimeLeft { get; set; }

    public bool GameCompletedSuccessful { get; set; }
    
    public List<Puzzle> Puzzles { get; set; }

    public LeaderboardTeam(string? id, string teamName, List<string> playerNames, TimeSpan timeLeft, bool gameCompletedSuccessful, List<Puzzle> puzzles)
    {
        Id = id;
        TeamName = teamName;
        PlayerNames = playerNames;
        TimeLeft = timeLeft;
        GameCompletedSuccessful = gameCompletedSuccessful;
        Puzzles = puzzles;
    }
}
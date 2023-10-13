namespace Xpirit.EscapeRoom.Domain;

public class Team
{
    public string? Id { get; }

    public string Name { get; }
    
    public List<string> PlayerNames {get; set;}

    public DateTime CreationTime { get; }

    public Team(string? id, string name, List<string> playerNames, DateTime creationTime)
    {
        Id = id;
        Name = name;
        PlayerNames = playerNames;
        CreationTime = creationTime;
    }  
}
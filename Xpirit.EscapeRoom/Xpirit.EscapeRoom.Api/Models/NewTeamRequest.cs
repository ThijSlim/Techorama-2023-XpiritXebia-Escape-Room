namespace Xpirit.EscapeRoom.Api.Models;

public class NewTeamRequest
{
    public string TeamName { get; set; }

    public List<string> PlayerNames { get; set; }
}
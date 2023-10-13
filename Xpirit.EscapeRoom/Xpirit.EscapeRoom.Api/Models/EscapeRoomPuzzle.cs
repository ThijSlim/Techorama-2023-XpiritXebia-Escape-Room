namespace Xpirit.EscapeRoom.Api.Models;

public record EscapeRoomPuzzle
{
    public PuzzleType Type { get; set; }
    
    public string Question { get; set; }
    
    public string Hint { get; set; }
    
    public int Answer { get; set; }
}
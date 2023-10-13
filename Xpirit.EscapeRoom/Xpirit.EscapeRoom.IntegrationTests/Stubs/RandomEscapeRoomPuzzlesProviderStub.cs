using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;

namespace Xpirit.EscapeRoom.IntegrationTests.Stubs;

public class RandomEscapeRoomPuzzlesProviderStub : IRandomEscapeRoomPuzzlesProvider
{
    public IEnumerable<EscapeRoomPuzzle> GetRandomPuzzles(int amount)
    {
        return _puzzles;
    }
    
    private readonly IEnumerable<EscapeRoomPuzzle> _puzzles = new List<EscapeRoomPuzzle>
    {
        new()
        {
            Type = PuzzleType.Blinky,
            Question = "Question 3",
            Answer = 1,
            Hint = "This is a hint",
        },
        new()
        {
            Type = PuzzleType.Bookshelf,
            Question =
                "Question 1",
            Answer = 3,
            Hint = "This is a new hint",
        },
        new()
        {
            Type = PuzzleType.Magazine,
            Question =
            "Question 4",

            Answer = 7,
            Hint = "",
        },
    };
}
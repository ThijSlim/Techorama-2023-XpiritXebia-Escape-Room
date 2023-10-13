using Xpirit.EscapeRoom.Api.Models;

namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public class RandomEscapeRoomPuzzlesProvider : IRandomEscapeRoomPuzzlesProvider
{
    public IEnumerable<EscapeRoomPuzzle> GetRandomPuzzles(int amount)
    {
        var random = new Random();
        var puzzles = new List<EscapeRoomPuzzle>();
        var puzzleTypes = Enum.GetValues<PuzzleType>().Where(x => x != _fixedPuzzle.Type).ToList();
        for (var i = 0; i < Math.Min(amount, _randomPuzzles.Count()); i++)
        {
            if (i == 2)
            {
                puzzles.Add(_fixedPuzzle);
                continue;
            }
            
            var puzzleType = puzzleTypes[random.Next(puzzleTypes.Count)];
            puzzleTypes.Remove(puzzleType);
            puzzles.Add(_randomPuzzles.First(p => p.Type == puzzleType));
        }

        return puzzles;
    }

    private readonly EscapeRoomPuzzle _fixedPuzzle = new()
    {
        Type = PuzzleType.DevOps,
        Question = "We like solving complex puzzles for our customers.\n\nFind the cypher and solve the puzzle.\nWhat number can you make of the symbol that goes with the answer?",
        Hint = "Find the puzzle! Look how the dots are placed inside the shapes to find a word. Once you have the word, what is the symbol for this way of working? Rotate it 90° to find the number.",
        Answer = 8,
    };
    
    private readonly IEnumerable<EscapeRoomPuzzle> _randomPuzzles = new List<EscapeRoomPuzzle>
    {
        new()
        {
            Type = PuzzleType.Blinky,
            Question =
                "Blinky is our informal 'Do Epic Shit!' logo that can light up using IoT technology.\n\nBlinky is flashing a special code for you to decode. What number are we looking for?",
            Answer = 6,
            Hint = "You've found Blinky, alright? It's not hard - it blinks. Quick, try and decode it's code using an object in the room.",
        },
        new()
        {
            Type = PuzzleType.Magazine,
            Question =
                "XPRT. is our magazine that consists of high quality articles. Often with bold statements, like \"99% of code isn't yours\".\n\nIn which edition can you find this article? (PS: you have the latest edition in your goodiebag - enjoy reading!)",
            Answer = 9,
            Hint = "Some of our magazines are displayed in front of you. Find the article title and look for the edition.",
        },
        new()
        {
            Type = PuzzleType.FlightBadges,
            Question = "We employ Azure and DevOps experts all over the world.\n\nLook around, can you find the Dutch crew? Now look closely, as we've hidden a number.",
            Hint = "You should focus on back-end more. Connect the dots.",
            Answer = 5,
        },
        new()
        {
            Type = PuzzleType.CoreValues,
            Question = "We are proud of our values. They are what we stand for and guide us in making decisions.\n\nLook around, how many values do you count? ",
            Hint = "They are all around you, look on the walls and ceilings. They're not many. Just enough. We trust you can do the counting.",
            Answer = 4,
        },
        new()
        {
            Type = PuzzleType.Bookshelf,
            Question = "X|X'ers can order as many books as they like, no questions asked.\nWe brought a few, that we consider as our pocket guides.\n\nFind the hidden number!",
            Hint = "The human eye can't see everything. Use an object in the room to expand your vision and give light to this answer.\nMake sure to look closely at all the books.",
            Answer = 3,
        },
        new()
        {
            Type = PuzzleType.GitHub,
            Question = "We 🧡GitHub. We are official partner and have accredited GitHub trainers and educate Microsoft employees & partners and users on GitHub.\n\nWhat number is relevant for our partner status in Europe?",
            Hint = "Find Mona. She will guide you to the right answer.",
            Answer = 1,
        },
        new()
        {
            Type = PuzzleType.GlobalMap,
            Question = "We are a proud part of Xebia and employ Microsoft and GitHub experts all over the world.\n\nIn how many countries are we located currently?",
            Hint = "We grow so fast, the room will guide you. Find the map and you'll know how fast!",
            Answer = 4,
        },
        new ()
        {
            Type = PuzzleType.CoPilot,
            Question = "This Escape Room is built with the help of generative AI.\n\nWhat tool shares its name with the second most important person on an airplane?",
            Hint = "An airplane needs a CoPilot to fly",
            Answer = 2,
        }
    };
}
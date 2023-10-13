using Xpirit.EscapeRoom.Api.Models;

namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public interface IRandomEscapeRoomPuzzlesProvider
{
    IEnumerable<EscapeRoomPuzzle> GetRandomPuzzles(int amount);
}
using Xpirit.EscapeRoom.Api.Controllers;
using Xpirit.EscapeRoom.Api.Models;
using Team = Xpirit.EscapeRoom.Domain.Team;

namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public interface IActiveEscapeRoom
{
    void StartGame();
    

    GameState GetGameState();
    
    bool ValidateGameHasEnded();
    
    bool AnswerQuestion(int answer);

    void EndGame();
    
    bool LastGameCompletedAtLeast15SecondsAgo();
    
    void StartIntroForNewTeam(Domain.Team nextTeamInQueue);
    
    void IdleGame();
    bool IsIdle();
    Team? GetActiveTeam();
    void ReadyNewGame(IEnumerable<EscapeRoomPuzzle> puzzles);
    void ActivateHint();
}
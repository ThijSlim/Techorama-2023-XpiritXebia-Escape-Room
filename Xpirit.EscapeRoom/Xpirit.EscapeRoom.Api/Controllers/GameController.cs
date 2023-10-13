using Microsoft.AspNetCore.Mvc;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;
using Xpirit.EscapeRoom.Broker;
using Xpirit.EscapeRoom.Broker.Models;
using Xpirit.EscapeRoom.Domain.Ports;

namespace Xpirit.EscapeRoom.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class GameController : ControllerBase
{
    private readonly ILogger<GameController> _logger;
    private readonly IActiveEscapeRoom _activeEscapeRoom;
    private readonly IRandomEscapeRoomPuzzlesProvider _randomEscapeRoomPuzzlesProvider;
    private readonly IQueue _queue;

    public GameController(ILogger<GameController> logger, IActiveEscapeRoom activeEscapeRoom,
        IRandomEscapeRoomPuzzlesProvider randomEscapeRoomPuzzlesProvider, IBoardQueue boardQueue, IQueue queue)
    {
        _logger = logger;
        _queue = queue;
        _randomEscapeRoomPuzzlesProvider = randomEscapeRoomPuzzlesProvider;
        _activeEscapeRoom = activeEscapeRoom;
    }

    [HttpPost]
    [Route("readyGame")]
    public void ReadyNewGame()
    {
        var puzzles = _randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(4);
        _activeEscapeRoom.ReadyNewGame(puzzles);
    }

    [HttpPost]
    [Route("startGame")]
    public void StartGame()
    {
        _activeEscapeRoom.StartGame();
    }

    [HttpPost]
    [Route("endGame")]
    public void EndGame()
    {
        _activeEscapeRoom.EndGame();
    }


    [HttpPost]
    [Route("activateHint")]
    public void ActivateHint()
    {
        _activeEscapeRoom.ActivateHint();
    }

    [HttpPost]
    [Route("answerQuestion")]
    public async Task<AnswerQuestionResponse> AnswerQuestion([FromBody] AnswerQuestionRequest request)
    {
        var isCorrect = _activeEscapeRoom.AnswerQuestion(request.Answer);

        if (_activeEscapeRoom.GetGameState().GameStatus == GameStatus.Completed)
        {
            await PublishCompletedGame();
        }

        return new AnswerQuestionResponse
        {
            IsCorrect = isCorrect
        };
    }

    public async Task PublishCompletedGame()
    {
        var puzzles = _activeEscapeRoom.GetGameState().GameProgress.Select(x => x.ToBroker()).ToList();
        await _queue.Enqueue(new GameCompleted
        {
            TeamName = _activeEscapeRoom.GetActiveTeam()!.Name,
            TimeLeft = _activeEscapeRoom.GetGameState().TimeLeft,
            PlayerNames = _activeEscapeRoom.GetActiveTeam()!.PlayerNames,
            GameCompletedSuccessful = _activeEscapeRoom.GetGameState().GameCompletedSuccessful!.Value,
            Puzzles = puzzles
        });
    }

    [HttpGet]
    [Route("currentGameState")]
    public async Task<GameState> GetGameState()
    {
        bool gameHasEnded = _activeEscapeRoom.ValidateGameHasEnded();
        if (gameHasEnded)
        {
            await PublishCompletedGame();
        }

        var lastGameCompletedAtLeast15SecondsAgo = _activeEscapeRoom.LastGameCompletedAtLeast15SecondsAgo();
        if (lastGameCompletedAtLeast15SecondsAgo)
        {
            _activeEscapeRoom.IdleGame();
        }

        var gameState = _activeEscapeRoom.GetGameState();
        return gameState;
    }
}
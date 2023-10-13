using Microsoft.AspNetCore.Mvc;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;
using Xpirit.EscapeRoom.Domain.Ports;

namespace Xpirit.EscapeRoom.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class TeamController : ControllerBase
{
    private readonly ILogger<TeamController> _logger;
    private readonly INewTeam _newTeam;
    private readonly IBoardQueue _boardQueue;
    private readonly IDateTimeProvider _dateTimeProvider;
    private readonly IProvideLeaderboard _provideLeaderboard;
    private IActiveEscapeRoom _activeEscapeRoom;

    public TeamController(ILogger<TeamController> logger,  IActiveEscapeRoom activeEscapeRoom, INewTeam newTeam, IBoardQueue boardQueue, IProvideLeaderboard provideLeaderboard, IDateTimeProvider dateTimeProvider)
    {
        _activeEscapeRoom = activeEscapeRoom;
        _provideLeaderboard = provideLeaderboard;
        _dateTimeProvider = dateTimeProvider;
        _boardQueue = boardQueue;
        _newTeam = newTeam;
        _logger = logger;
    }

    [HttpPost]
    [Route("newTeam")]
    public async Task NewTeam([FromBody] NewTeamRequest request)
    {
        var creationTime = _dateTimeProvider.Now();
        var team = new Domain.Team(null, request.TeamName, request.PlayerNames, creationTime);
        
        _activeEscapeRoom.StartIntroForNewTeam(team);
    }
    
    [HttpGet]
    [Route("leaderboard")]
    public async Task<IEnumerable<LeaderboardTeam>> GetLeaderboard()
    {
        var leaderboard = await _provideLeaderboard.GetLeaderboard();
        
        return leaderboard.Select(x => new LeaderboardTeam
        {
            TeamName = x.TeamName,
            TimeLeft = x.TimeLeft,
            PlayerNames = x.PlayerNames,
            GameCompletedSuccessful = x.GameCompletedSuccessful,
            Puzzles = x.Puzzles.Select(Puzzle.FromDomain).ToList()
        });
    }
}
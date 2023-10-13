using Xpirit.EscapeRoom.Api.Controllers;
using Xpirit.EscapeRoom.Api.Models;
using Team = Xpirit.EscapeRoom.Domain.Team;

namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public class ActiveEscapeRoom : IActiveEscapeRoom
{
    private readonly IDateTimeProvider _dateTimeProvider;
    private const int SecondsBeforeHint = 30;
    private const int SecondsBeforeNextTry = 10;
    private const int SecondsBeforeGameAutoCompletes = 30;

    const int GameDurationInMinutes = 4;

    private DateTime? _gameStartedTime;
    private DateTime? _gameEndTime;
    private bool? _gameCompletedSuccessfully;

    private DateTime? _lastQuestionStartedTime;
    private DateTime? _lastWrongAnswerTime;

    private IEnumerable<EscapeRoomPuzzle> _puzzles = new List<EscapeRoomPuzzle>();
    private readonly IDictionary<PuzzleType, TimeSpan> _puzzleSolvedTimes = new Dictionary<PuzzleType, TimeSpan>();
    private int _activePuzzleIndex;
    private readonly GameStateMachine _gameStateMachine;
    private Domain.Team? _activeTeam;
    private bool _isHintActivated;

    public ActiveEscapeRoom(IDateTimeProvider dateTimeProvider, GameStateMachine gameStateMachine)
    {
        _gameStateMachine = gameStateMachine;
        _dateTimeProvider = dateTimeProvider;
    }

    public void StartIntroForNewTeam(Team team)
    {
        _gameStateMachine.StartIntroNewGame();
        ResetActiveGame();
        _activeTeam = team;
    }

    public void ReadyNewGame(IEnumerable<EscapeRoomPuzzle> puzzles)
    {
        _gameStateMachine.ReadyNewGame();
        _puzzles = puzzles;
    }

    private TimeSpan? GetTimeTillHintIsEnabled()
    {
        if (_lastQuestionStartedTime == null)
        {
            return null;
        }

        var timeTillHintIsEnabled=  TimeSpan.FromSeconds(SecondsBeforeHint) - (_dateTimeProvider.Now() - _lastQuestionStartedTime.Value);
        
        if (timeTillHintIsEnabled < TimeSpan.Zero)
        {
            return TimeSpan.Zero;
        }

        return timeTillHintIsEnabled;
    }
    
    private TimeSpan? GetTimeTillNextAnswerTry()
    {
        if (_lastWrongAnswerTime == null)
        {
            return null;
        }

        var timeTillHintIsEnabled=  TimeSpan.FromSeconds(SecondsBeforeNextTry) - (_dateTimeProvider.Now() - _lastWrongAnswerTime.Value);
        
        if (timeTillHintIsEnabled < TimeSpan.Zero)
        {
            return TimeSpan.Zero;
        }

        return timeTillHintIsEnabled;
    }

    public void ActivateHint()
    {
        var isHintEnabled = GetTimeTillHintIsEnabled() <= TimeSpan.Zero;
        if (isHintEnabled)
        {
            _isHintActivated = true;
        }
    }

    public void StartGame()
    {
        _gameStateMachine.StartGame();
        _gameStartedTime = _dateTimeProvider.Now();
        _lastQuestionStartedTime = _gameStartedTime;
    }

    public void IdleGame()
    {
        _gameStateMachine.IdleGame();
    }

    public bool IsIdle()
    {
        return _gameStateMachine.GetState() == GameStatus.Idle;
    }

    public Team? GetActiveTeam()
    {
        return _activeTeam;
    }


    private void ResetActiveGame()
    {
        _gameStartedTime = null;
        _gameEndTime = null;
        _gameCompletedSuccessfully = null;

        _puzzles = new List<EscapeRoomPuzzle>();
        _activePuzzleIndex = 0;
        _puzzleSolvedTimes.Clear();
        _activeTeam = null;
        _isHintActivated = false;
    }

    public GameState GetGameState()
    {
        var gameStatus = _gameStateMachine.GetState();
        var timeLeft = GetTimeLeft();
        var activePuzzle = GetActivePuzzle();
        var activatedHint = GetActivatedHint();
        var timeTillHintIsEnabled = GetTimeTillHintIsEnabled();
        var timeTillNextAnswerTry = GetTimeTillNextAnswerTry();
        
        return new GameState
        {
            GameStatus = gameStatus,
            TimeLeft = timeLeft,
            ActiveTeam = _activeTeam?.Name,
            ActiveQuestion = activePuzzle?.Question,
            ActivePuzzleType = activePuzzle?.Type,
            ActivatedHint = activatedHint,
            TimeTillHintIsEnabled = timeTillHintIsEnabled,
            TimeTillNextAnswerTry = timeTillNextAnswerTry,
            GameCompletedSuccessful = _gameCompletedSuccessfully,
            GameProgress = _puzzles.Select(puzzle => new Puzzle
            {
                PuzzleType = puzzle.Type.ToString(),
                Solved = _puzzles.TakeWhile(p => p != puzzle).Count() < _activePuzzleIndex,
                SolveTime = _puzzleSolvedTimes.TryGetValue(puzzle.Type, out var solveTime) ? solveTime : null
            })
        };
    }


    private string? GetActivatedHint()
    {
        var activePuzzle = GetActivePuzzle();
        if (activePuzzle == null)
        {
            return null;
        }

        if (!_isHintActivated)
        {
            return null;
        }

        return activePuzzle.Hint;
    }

    private TimeSpan GetTimeLeft()
    {
        if (!_gameStartedTime.HasValue)
        {
            return TimeSpan.Zero;
        }

        if (_gameEndTime.HasValue)
        {
            var timeLeftInCompletedGame = _gameStartedTime.Value.AddMinutes(GameDurationInMinutes) - _gameEndTime.Value;

            if (timeLeftInCompletedGame < TimeSpan.Zero)
            {
                return TimeSpan.Zero;
            }

            return timeLeftInCompletedGame;
        }

        var timeLeftInActiveGame = _gameStartedTime.Value.AddMinutes(GameDurationInMinutes) - _dateTimeProvider.Now();

        if (timeLeftInActiveGame < TimeSpan.Zero)
        {
            return TimeSpan.Zero;
        }

        return timeLeftInActiveGame;
    }

    public bool ValidateGameHasEnded()
    {
        var gameHasEnded = _gameStateMachine.GetState() == GameStatus.InProgress && GetTimeLeft() <= TimeSpan.Zero;
        if (gameHasEnded)
        {
            FailGame();
            return true;
        }

        return false;
    }

    public bool LastGameCompletedAtLeast15SecondsAgo()
    {
        return _gameStateMachine.GetState() == GameStatus.Completed && _gameEndTime.HasValue && _gameEndTime.Value.AddSeconds(SecondsBeforeGameAutoCompletes) < _dateTimeProvider.Now();
    }

    public bool AnswerQuestion(int answer)
    {
        var activePuzzle = GetActivePuzzle();

        if (activePuzzle == null)
        {
            throw new InvalidOperationException("No active puzzle");
        }

        if (GetTimeTillNextAnswerTry() > TimeSpan.Zero)
        {
            throw new InvalidOperationException("Too early to answer");
        }

        if (activePuzzle.Answer != answer)
        {
            _lastWrongAnswerTime = _dateTimeProvider.Now();
            return false;
        }

        // Puzzle is solved
        var puzzleSolvedTime = _dateTimeProvider.Now() - _lastQuestionStartedTime;
        _puzzleSolvedTimes.Add(activePuzzle.Type, puzzleSolvedTime!.Value);
        
        _activePuzzleIndex++;

        if (AllPuzzlesSolved())
        {
            SucceedGame();
        }

        _lastQuestionStartedTime = _dateTimeProvider.Now();
        _isHintActivated = false;
        _lastWrongAnswerTime = null;
        
        return true;
    }

    public bool AllPuzzlesSolved()
    {
        return _activePuzzleIndex == _puzzles.Count();
    }

    public EscapeRoomPuzzle? GetActivePuzzle()
    {
        if (!_puzzles.Any() || _activePuzzleIndex >= _puzzles.Count())
        {
            return null;
        }

        return _puzzles.ElementAt(_activePuzzleIndex);
    }

    public void EndGame()
    {
        _gameStateMachine.EndGame();
    }


    private void SucceedGame()
    {
        _gameStateMachine.CompleteGame();
        _gameEndTime = _dateTimeProvider.Now();
        _gameCompletedSuccessfully = true;
    }

    private void FailGame()
    {
        _gameStateMachine.CompleteGame();
        _gameEndTime = _dateTimeProvider.Now();
        _gameCompletedSuccessfully = false;
    }
}
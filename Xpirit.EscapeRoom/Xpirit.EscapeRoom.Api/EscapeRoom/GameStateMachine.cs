using Stateless;
using Xpirit.EscapeRoom.Api.Models;

namespace Xpirit.EscapeRoom.Api.EscapeRoom;

public class GameStateMachine
{
    private readonly StateMachine<GameStatus, Triggers> _machine;

    private GameStatus _state = GameStatus.Idle;
    
    public GameStateMachine()
    {
        _machine = new StateMachine<GameStatus, Triggers>(() => _state, s => _state = s);

        _machine.Configure(GameStatus.Idle)
            .Permit(Triggers.ToIntro, GameStatus.Intro);

        _machine.Configure(GameStatus.Intro)
            .Permit(Triggers.ToReadyToStart, GameStatus.ReadyToStart);
     
        _machine.Configure(GameStatus.ReadyToStart)
            .Permit(Triggers.ToInProgress, GameStatus.InProgress);

        _machine.Configure(GameStatus.InProgress)
            .Permit(Triggers.ToCompleted, GameStatus.Completed);

        _machine.Configure(GameStatus.Completed)
            .Permit(Triggers.ToIdle, GameStatus.Idle)
            .Permit(Triggers.ToReadyToStart, GameStatus.ReadyToStart);
    }

    public GameStatus GetState()
    {
        return _state;
    }
    
    public void IdleGame()
    {
        _machine.Fire(Triggers.ToIdle);
    }
    
    public void StartGame()
    {
        _machine.Fire(Triggers.ToInProgress);
    }

    public void CompleteGame()
    {
        _machine.Fire(Triggers.ToCompleted);
    }

    public void EndGame()
    {
        _machine.Fire(Triggers.ToIdle);
    }
    
    public void StartIntroNewGame()
    {
        _machine.Fire(Triggers.ToIntro);
    }

    public void ReadyNewGame()
    {
        _machine.Fire(Triggers.ToReadyToStart);
    }
}
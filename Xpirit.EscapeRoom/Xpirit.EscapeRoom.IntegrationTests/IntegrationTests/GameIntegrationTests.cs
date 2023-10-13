using System.Net;
using System.Text;
using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;
using Xpirit.EscapeRoom.IntegrationTests.Stubs;

namespace Xpirit.EscapeRoom.IntegrationTests.IntegrationTests;

public class GameIntegrationTests : PerTestFixture<CustomWebApplicationFactory<Api.Program>>
{
    [Fact]
    public async Task When_NoGameHasStarted_ShouldReturnIdle()
    {
        // Arrange
        var client = Context.CreateClient();

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.Idle);
    }
    
    [Fact]
    public async Task When_NewTeamIsBoarded_ShouldReturnReadyToStart()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.ActiveTeam.Should().Be("Team 1");
        gameState.GameStatus.Should().Be(GameStatus.Intro);
    }
    
    [Fact]
    public async Task When_GameHasStarted_ShouldReturnActive()
    {
        // Arrange
        var client = Context.CreateClient();
        
        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);

        // Ready the new game
        await ReadyNewGame(client);
        
        var response = await client.PostAsync("/game/startGame", null);
        response.EnsureSuccessStatusCode();

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActiveTeam.Should().Be("Team 1");
        gameState.ReadyTeam.Should().Be(null);
    }

    [Fact]
    public async Task When_GameHasStarted_ShouldStartWithTimer()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        // Ready the new game
        await ReadyNewGame(client);

        await client.PostAsync("/game/startGame", null);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.TimeLeft.Should().Be(TimeSpan.FromMinutes(4));
    }

    [Fact]
    public async Task When_WhenTimePasses_ShouldUpdateTime()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);

        await client.PostAsync("/game/startGame", null);

        var twoMinutesLater = now.AddMinutes(2);
        dateTimeProviderStub.SetNow(twoMinutesLater);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.TimeLeft.Should().Be(TimeSpan.FromMinutes(2));
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
    }

    [Fact]
    public async Task When_WhenActiveGameHasPassed_ShouldFailGame()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);

        await client.PostAsync("/game/startGame", null);

        var fourMinutesLater = now.AddMinutes(4).AddSeconds(1);
        dateTimeProviderStub.SetNow(fourMinutesLater);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.TimeLeft.Should().Be(TimeSpan.FromSeconds(0));
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        gameState.GameCompletedSuccessful.Should().BeFalse();
    }

    [Fact]
    public async Task When_GameIsInProgress_ShouldGiveActivePuzzle()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActiveQuestion.Should().Be("Question 3");
        gameState.ActivePuzzleType.Should().Be(PuzzleType.Blinky);
    }
    
    [Fact]
    public async Task When_GameIsInProgress_ShouldNotActivateHintByDefault()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        await client.PostAsync("/game/startGame", null);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActivatedHint.Should().BeNull();
        gameState.TimeTillHintIsEnabled.Should().Be(TimeSpan.FromSeconds(30));
    }
    
    [Fact]
    public async Task When_GameIsInProgress_ShouldNotBePossibleToEnableHintWithin1Minute()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        await client.PostAsync("/game/startGame", null);

        // Act
        var twoMinutesLater = now.AddSeconds(29);
        dateTimeProviderStub.SetNow(twoMinutesLater);

        await client.PostAsync("/game/activateHint", null);

        var gameState = await GetGameState(client);
        
        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActivatedHint.Should().BeNull();
        gameState.TimeTillHintIsEnabled.Should().Be(TimeSpan.FromSeconds(1));
    }
    
    [Fact]
    public async Task When_GameIsInProgress_ShouldEnableHintAfter1MinuteAndResetWhenNewQuestion()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        await client.PostAsync("/game/startGame", null);

        // Act
        var oneMinutesLater = now.AddMinutes(1);
        dateTimeProviderStub.SetNow(oneMinutesLater);

        await client.PostAsync("/game/activateHint", null);

        var gameState = await GetGameState(client);
        
        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActivatedHint.Should().Be("This is a hint");
        gameState.TimeTillHintIsEnabled.Should().Be(TimeSpan.FromMinutes(0));
        
        await PostAnswerQuestion(client, 1);
        
        var gameState2 = await GetGameState(client);
        gameState2.ActivatedHint.Should().BeNull();
        gameState2.TimeTillHintIsEnabled.Should().Be(TimeSpan.FromSeconds(30));
    }

    [Fact]
    public async Task When_QuestionAnsweredCorrectly_ShouldGiveNextActivePuzzle()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        var response = await PostAnswerQuestion(client, 1);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        response.IsCorrect.Should().BeTrue();
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActiveQuestion.Should().Be("Question 1");
        gameState.ActivePuzzleType.Should().Be(PuzzleType.Bookshelf);
    }

    [Fact]
    public async Task When_QuestionAnsweredIncorrectly_ShouldReturnIncorrectAndStickToCurrentQuestion()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        await client.PostAsync("/game/startGame", null);

        var response = await PostAnswerQuestion(client, 0);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        response.IsCorrect.Should().BeFalse();
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.ActiveQuestion.Should().Be("Question 3");
        gameState.TimeTillNextAnswerTry.Should().Be(TimeSpan.FromSeconds(10));
        gameState.ActivePuzzleType.Should().Be(PuzzleType.Blinky);
    }

    [Fact] public async Task When_QuestionAnsweredIncorrectly_ShouldWaitUntilNextAnswerCanBeGiven()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        await client.PostAsync("/game/startGame", null);
        
        await PostAnswerQuestion(client, 0);
        var gameState1 = await GetGameState(client);
        gameState1.TimeTillNextAnswerTry.Should().Be(TimeSpan.FromSeconds(10));
        gameState1.ActiveQuestion.Should().Be("Question 3");

        var nineSecondsLater = now.AddSeconds(9);
        dateTimeProviderStub.SetNow(nineSecondsLater);
        try
        {
            await PostAnswerQuestion(client, 0);
        }
        catch (Exception _)
        {
            //
        }

        var gameState2 = await GetGameState(client);
        gameState2.TimeTillNextAnswerTry.Should().Be(TimeSpan.FromSeconds(1));
        gameState2.ActiveQuestion.Should().Be("Question 3");

        var tenSecondsLater = now.AddSeconds(10);
        dateTimeProviderStub.SetNow(tenSecondsLater);
        
        await PostAnswerQuestion(client, 1);

        var gameState3 = await GetGameState(client);
        gameState3.ActiveQuestion.Should().Be("Question 1");
        gameState3.TimeTillNextAnswerTry.Should().BeNull();


    }

    [Fact]
    public async Task When_WhenPuzzleIsAnsweredIncorrectly_ShouldNotProgressInGame()
    {
        // Arrange
        var client = Context.CreateClient();
        
        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 0);
        
        // After penalty
        var thirtySecondsLater = now.AddSeconds(30);
        dateTimeProviderStub.SetNow(thirtySecondsLater);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);


        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
    }

    [Fact]
    public async Task When_WhenNotAllPuzzleQuestionsAreAnsweredCorrectly_ShouldHaveGameInProgress()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);
        await PostAnswerQuestion(client, 3);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
    }

    [Fact]
    public async Task When_WhenAllPuzzleQuestionsAreAnsweredCorrectly_ShouldSucceedGame()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        await client.PostAsync("/game/startGame", null);

        var threeMinutesLater = now.AddMinutes(3);
        dateTimeProviderStub.SetNow(threeMinutesLater);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);
        await PostAnswerQuestion(client, 7);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        gameState.GameCompletedSuccessful.Should().BeTrue();
        gameState.TimeLeft.Should().Be(TimeSpan.FromMinutes(1));
    }

    [Fact]
    public async Task When_GameIsInProgress_ShouldNotBeAbleToStartNewGame()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);

        try
        {
            var startGameResponse = await client.PostAsync("/game/startGame", null);
            startGameResponse.StatusCode.Should().Be(HttpStatusCode.InternalServerError);
        }
        catch (Exception e)
        {
            //
        }
    }

    [Fact]
    public async Task When_GameIsSucceeded_ShouldNotEndTheGameForAShortWhile()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);
        
        
        var twoMinutesLater = now.AddMinutes(2);
        dateTimeProviderStub.SetNow(twoMinutesLater);
        await PostAnswerQuestion(client, 7);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        
        var twoMinutesAnd14SecondsLater = now.AddMinutes(2).AddSeconds(14);
        dateTimeProviderStub.SetNow(twoMinutesAnd14SecondsLater);
        await GetGameState(client);

        var newGameState = await GetGameState(client);
        newGameState.GameStatus.Should().Be(GameStatus.Completed);
    }
    
    [Fact]
    public async Task When_GameIsSucceeded_ShouldEndTheGameAndTurnToIdleAfter30Seconds()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);
        
        
        var twoMinutesLater = now.AddMinutes(2);
        dateTimeProviderStub.SetNow(twoMinutesLater);
        await PostAnswerQuestion(client, 7);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        
        var twoMinutesAnd31SecondsLater = now.AddMinutes(2).AddSeconds(31);
        dateTimeProviderStub.SetNow(twoMinutesAnd31SecondsLater);
        await GetGameState(client);

        var newGameState = await GetGameState(client);
        newGameState.GameStatus.Should().Be(GameStatus.Idle);
    }
    
    [Fact]
    public async Task When_GameIsSucceeded_ShouldBeAbleToEndGameByForce()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);
        await PostAnswerQuestion(client, 7);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.Completed);

        var startGameResponse = await client.PostAsync("/game/endGame", null);
        startGameResponse.EnsureSuccessStatusCode();

        var newGameState = await GetGameState(client);
        newGameState.GameStatus.Should().Be(GameStatus.Idle);
    }
    
    [Fact]
    public async Task When_GameIsFailed_ShouldStartNewGameWithFreshState()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);

        await client.PostAsync("/game/startGame", null);

        var fourMinutesLater = now.AddMinutes(4).AddSeconds(1);
        dateTimeProviderStub.SetNow(fourMinutesLater);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.TimeLeft.Should().Be(TimeSpan.FromSeconds(0));
        gameState.ActiveTeam.Should().Be("Team 1");
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        gameState.GameCompletedSuccessful.Should().BeFalse();
        
        var fiveMinutesLater = now.AddMinutes(5);
        dateTimeProviderStub.SetNow(fiveMinutesLater);
        
        // Trigger Game state to end game
        await GetGameState(client);
        
        await CreateNewTeam(client, "Team 2");
        
        // Trigger Game state to ready game
        await GetGameState(client);
        
        // Ready the new game
        await ReadyNewGame(client);
        
        await client.PostAsync("/game/startGame", null);

        var eightMinutesLater = now.AddMinutes(8);
        dateTimeProviderStub.SetNow(eightMinutesLater);
        
        var newGameState = await GetGameState(client);
        newGameState.GameStatus.Should().Be(GameStatus.InProgress);
        newGameState.TimeLeft.Should().Be(TimeSpan.FromMinutes(1));
        newGameState.ActiveQuestion.Should().Be("Question 3");
        newGameState.ActiveTeam.Should().Be("Team 2");
        newGameState.ActivePuzzleType.Should().Be(PuzzleType.Blinky);
        newGameState.GameCompletedSuccessful.Should().BeNull();

    }

    [Fact]
    public async Task When_QuestionAnsweredCorrectly_ShouldGiveGameProgress()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");
        
        // Trigger Game state to ready game
        await GetGameState(client);

        // Ready the new game
        await ReadyNewGame(client);
        
        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);
        await client.PostAsync("/game/startGame", null);

        var twoMinutesLater = now.AddMinutes(2);
        dateTimeProviderStub.SetNow(twoMinutesLater);

        await PostAnswerQuestion(client, 1);
        await PostAnswerQuestion(client, 3);

        // Act
        var gameState = await GetGameState(client);

        // Assert
        gameState.GameStatus.Should().Be(GameStatus.InProgress);
        gameState.GameProgress.Count().Should().Be(3);

        gameState.GameProgress.ElementAt(0).PuzzleType.Should().Be(PuzzleType.Blinky.ToString());
        gameState.GameProgress.ElementAt(0).Solved.Should().Be(true);
        gameState.GameProgress.ElementAt(1).PuzzleType.Should().Be(PuzzleType.Bookshelf.ToString());
        gameState.GameProgress.ElementAt(1).Solved.Should().Be(true);
        gameState.GameProgress.ElementAt(2).PuzzleType.Should().Be(PuzzleType.Magazine.ToString());
        gameState.GameProgress.ElementAt(2).Solved.Should().Be(false);
    }

    private async Task ReadyNewGame(HttpClient client)
    {
        var response = await client.PostAsync("/game/readyGame", null);
        response.EnsureSuccessStatusCode();
    }

    
    // create team
    private async Task CreateNewTeam(HttpClient client, string teamName)
    {
        var playerNames = new List<string>
        {
            "WILSOONNN","BILLY"
        };
        var request = new NewTeamRequest
        {
            TeamName = teamName,
            PlayerNames = playerNames
        };

        var requestContent = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");

        await client.PostAsync("/team/newTeam", requestContent);
    }

    private async Task<GameState> GetGameState(HttpClient client)
    {
        var gameStateResponse = await client.GetAsync("/game/currentGameState");

        // Assert
        gameStateResponse.EnsureSuccessStatusCode();
        var response = await gameStateResponse.Content.ReadAsStringAsync();
        var gameState = JsonConvert.DeserializeObject<GameState>(response);
        return gameState;
    }

    private async Task<AnswerQuestionResponse> PostAnswerQuestion(HttpClient client, int answer)
    {
        var answerQuestionResponse = await client.PostAsync("/game/answerQuestion", new StringContent(JsonConvert.SerializeObject(new AnswerQuestionRequest
        {
            Answer = answer
        }), Encoding.UTF8, "application/json"));

        var response = await answerQuestionResponse.Content.ReadAsStringAsync();

        return JsonConvert.DeserializeObject<AnswerQuestionResponse>(response);
    }
}
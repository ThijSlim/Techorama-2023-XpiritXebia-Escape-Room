using System.Text;
using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;
using Xpirit.EscapeRoom.IntegrationTests.Stubs;

namespace Xpirit.EscapeRoom.IntegrationTests.IntegrationTests;

public class LeaderboardIntegrationTests : PerTestFixture<CustomWebApplicationFactory<Api.Program>>
{
    [Fact]
    public async Task When_GameIsSucceeded_ShouldAddToLeaderboard()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");

        // Trigger Game state to ready game
        await GetGameState(client);

        await ReadyNewGame(client);

        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);

        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        
        var oneMinutesLater = now.AddSeconds(59);
        dateTimeProviderStub.SetNow(oneMinutesLater);
        
        await PostAnswerQuestion(client, 3);

        var threeMinutesLater = now.AddMinutes(3).AddSeconds(1);
        dateTimeProviderStub.SetNow(threeMinutesLater);

        await PostAnswerQuestion(client, 7);

        var gameState = await GetGameState(client);
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        gameState.TimeLeft.Should().Be(TimeSpan.FromSeconds(59));
        gameState.GameCompletedSuccessful.Should().BeTrue();

        Thread.Sleep(1000);

        var leaderboard = await GetLeaderboard(client);
        leaderboard.Should().HaveCount(1);
        var leaderboardTeam = leaderboard.First();
        leaderboardTeam.TeamName.Should().Be("Team 1");
        leaderboardTeam.PlayerNames.Should().BeEquivalentTo(new List<string>
        {
            "WILSOONNN", "BILLY"
        });
        leaderboardTeam.TimeLeft.Should().Be(TimeSpan.FromSeconds(59));
        leaderboardTeam.GameCompletedSuccessful.Should().BeTrue();
        
        leaderboardTeam.Puzzles.Should().HaveCount(3);
        
        var firstPuzzle = leaderboardTeam.Puzzles.First();
        firstPuzzle.PuzzleType.Should().Be(PuzzleType.Blinky.ToString());
        firstPuzzle.SolveTime.Should().Be(TimeSpan.FromSeconds(0));
        firstPuzzle.Solved.Should().Be(true);

        var secondPuzzle = leaderboardTeam.Puzzles.ElementAt(1);
        secondPuzzle.PuzzleType.Should().Be(PuzzleType.Bookshelf.ToString());
        secondPuzzle.SolveTime.Should().Be(TimeSpan.FromSeconds(59));
        secondPuzzle.Solved.Should().Be(true);

        var thirdPuzzle = leaderboardTeam.Puzzles.ElementAt(2);
        thirdPuzzle.PuzzleType.Should().Be(PuzzleType.Magazine.ToString());
        thirdPuzzle.SolveTime.Should().Be(TimeSpan.FromMinutes(2).Add(TimeSpan.FromSeconds(2)));
        thirdPuzzle.Solved.Should().Be(true);
    }
    
      [Fact]
    public async Task When_GameIsFailed_ShouldAddToLeaderboard()
    {
        // Arrange
        var client = Context.CreateClient();

        await CreateNewTeam(client, "Team 1");

        // Trigger Game state to ready game
        await GetGameState(client);

        await ReadyNewGame(client);

        var now = new DateTime(2021, 1, 1, 12, 0, 0);
        var dateTimeProviderStub = Context.Services.GetRequiredService<IDateTimeProvider>() as DateTimeProviderStub;
        dateTimeProviderStub.SetNow(now);

        await client.PostAsync("/game/startGame", null);

        await PostAnswerQuestion(client, 1);
        
        var oneMinutesLater = now.AddSeconds(59);
        dateTimeProviderStub.SetNow(oneMinutesLater);
        
        await PostAnswerQuestion(client, 3);

        var fourMinutesLater = now.AddMinutes(4).AddSeconds(1);
        dateTimeProviderStub.SetNow(fourMinutesLater);


        var gameState = await GetGameState(client);
        gameState.GameStatus.Should().Be(GameStatus.Completed);
        gameState.TimeLeft.Should().Be(TimeSpan.FromSeconds(0));
        gameState.GameCompletedSuccessful.Should().BeFalse();

        Thread.Sleep(1000);

        var leaderboard = await GetLeaderboard(client);
        leaderboard.Should().HaveCount(1);
        var leaderboardTeam = leaderboard.First();
        leaderboardTeam.TeamName.Should().Be("Team 1");
        leaderboardTeam.PlayerNames.Should().BeEquivalentTo(new List<string>
        {
            "WILSOONNN", "BILLY"
        });
        leaderboardTeam.TimeLeft.Should().Be(TimeSpan.FromSeconds(0));
        leaderboardTeam.GameCompletedSuccessful.Should().BeFalse();
        
        leaderboardTeam.Puzzles.Should().HaveCount(3);
        
        var firstPuzzle = leaderboardTeam.Puzzles.First();
        firstPuzzle.PuzzleType.Should().Be(PuzzleType.Blinky.ToString());
        firstPuzzle.SolveTime.Should().Be(TimeSpan.FromSeconds(0));
        firstPuzzle.Solved.Should().Be(true);

        var secondPuzzle = leaderboardTeam.Puzzles.ElementAt(1);
        secondPuzzle.PuzzleType.Should().Be(PuzzleType.Bookshelf.ToString());
        secondPuzzle.SolveTime.Should().Be(TimeSpan.FromSeconds(59));
        secondPuzzle.Solved.Should().Be(true);

        var thirdPuzzle = leaderboardTeam.Puzzles.ElementAt(2);
        thirdPuzzle.PuzzleType.Should().Be(PuzzleType.Magazine.ToString());
        thirdPuzzle.SolveTime.Should().BeNull();
        thirdPuzzle.Solved.Should().Be(false);
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
            "WILSOONNN", "BILLY"
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

    private async Task<IEnumerable<LeaderboardTeam>> GetLeaderboard(HttpClient client)
    {
        var gameStateResponse = await client.GetAsync("/team/leaderboard");

        // Assert
        gameStateResponse.EnsureSuccessStatusCode();
        var response = await gameStateResponse.Content.ReadAsStringAsync();
        var leaderboardTeams = JsonConvert.DeserializeObject<IEnumerable<LeaderboardTeam>>(response);
        return leaderboardTeams;
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
using FluentAssertions;
using Xpirit.EscapeRoom.Api.EscapeRoom;
using Xpirit.EscapeRoom.Api.Models;

namespace Xpirit.EscapeRoom.Api.Tests;

public class RandomEscapeRoomPuzzlesProviderTests
{
    [Fact]
    public void EscapeRoomPuzzlesShouldBeUnique()
    {
        // Arrange
        var randomEscapeRoomPuzzlesProvider = new RandomEscapeRoomPuzzlesProvider();

        // Act
        var puzzles = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(9);

        // Assert
        puzzles.Should().OnlyHaveUniqueItems();
    }

    [Fact]
    public void EscapeRoomPuzzlesShouldBeInRandomOrder()
    {
        // Arrange
        var randomEscapeRoomPuzzlesProvider = new RandomEscapeRoomPuzzlesProvider();

        // Act
        var puzzlesOne = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(9);
        var puzzlesTwo = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(9);

        // Assert
        puzzlesOne.Should().NotBeEquivalentTo(puzzlesTwo, options
            => options.WithStrictOrdering());
    }
    
    [Fact]
    public void EscapeRoomPuzzlesCanOnlyHaveUniquePuzzleTypes()
    {
        // Arrange
        var randomEscapeRoomPuzzlesProvider = new RandomEscapeRoomPuzzlesProvider();

        // Act
        var puzzles = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(9);

        // Assert
        puzzles.Select(p => p.Type).Should().OnlyHaveUniqueItems();
    }
    
    [Fact]
    public void EscapeRoomPuzzlesCanGiveTheMaxOfTheAmountOfPuzzles()
    {
        // Arrange
        var randomEscapeRoomPuzzlesProvider = new RandomEscapeRoomPuzzlesProvider();

        // Act
        var puzzles = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(15);

        // Assert
        puzzles.Should().HaveCount(7);
    }
    
    [Fact]
    public void ThirdPuzzleShouldAlwaysBeDevOps()
    {
        // Arrange
        var randomEscapeRoomPuzzlesProvider = new RandomEscapeRoomPuzzlesProvider();

        // Act
        var puzzles = randomEscapeRoomPuzzlesProvider.GetRandomPuzzles(9);

        // Assert
        puzzles.Select(p => p.Type).ElementAt(2).Should().Be(PuzzleType.DevOps);
    }
}
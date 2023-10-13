import 'package:escape_room_game/services/game-service.dart';
import 'package:flutter/material.dart';

import '../../Palette.dart';
import '../../models/puzzle-state.dart';
import '../game/active_game/game-artifact.dart';

class LeaderboardListItem extends StatelessWidget {
  const LeaderboardListItem({
    super.key,
    required this.position,
    required this.leaderboardTeam,
    required this.width,
  });

  final int position;
  final LeaderboardTeam leaderboardTeam;
  final double width;

  @override
  Widget build(BuildContext context) {
    var isFirstPlace = position == 1;
    var isWorthy = leaderboardTeam.gameCompletedSuccessful && position <= 3;
    var timeLeftFormatted = leaderboardTeam.timeLeft.toString().substring(3, 7);

    return DefaultTextStyle(
      style: TextStyle(
        fontSize: isFirstPlace ? width * 0.07 : width * 0.05,
        color: isFirstPlace
            ? Palette.xpiritColor
            : leaderboardTeam.gameCompletedSuccessful
                ? Colors.white
                : Colors.grey.shade500,
        fontWeight: isFirstPlace ? FontWeight.bold : FontWeight.normal,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: width * 0.07,
                  height: width * 0.07,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFirstPlace
                        ? Palette.xpiritColor
                        : isWorthy
                            ? Colors.white
                            : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(
                    "$position",
                    style: TextStyle(
                      color: isFirstPlace
                          ? Colors.white
                          : isWorthy
                              ? Palette.xpiritColor
                              : leaderboardTeam.gameCompletedSuccessful
                                  ? Colors.white
                                  : Colors.grey.shade500,
                      fontSize: width * 0.04,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leaderboardTeam.teamName),
                      SizedBox(
                        height: width * 0.005,
                      ),
                      Row(children: [
                        renderPlayerName(leaderboardTeam.playerNames[0], width),
                        const SizedBox(
                          width: 20,
                        ),
                        renderPlayerName(leaderboardTeam.playerNames[1], width),
                        const SizedBox(
                          width: 20,
                        ),
                        if (leaderboardTeam.playerNames.length > 2)
                          renderPlayerName(
                              leaderboardTeam.playerNames[2], width)
                      ]),
                    ],
                  ),
                ),
                SizedBox(
                  width: width * 0.30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.right,
                        timeLeftFormatted,
                      ),
                      const SizedBox(height: 4),
                      artifactsCollected(leaderboardTeam.puzzles, width)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget renderPlayerName(String playerName, double width) {
    return Text(
      playerName,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: width * 0.03,
      ),
    );
  }

  Widget artifactsCollected(List<PuzzleState> puzzles, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // puzzles to game loop to game artifacts
        for (var puzzle in puzzles)
          if (puzzle.solved)
            Padding(
              padding: EdgeInsets.only(left: width * 0.005),
              child: GameArtifact(
                puzzleType: puzzle.puzzleType,
                width: width * 0.045,
                height: width * 0.045,
              ),
            )
      ],
    );
  }
}

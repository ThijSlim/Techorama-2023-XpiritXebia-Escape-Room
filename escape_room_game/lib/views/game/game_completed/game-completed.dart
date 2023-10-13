import 'package:escape_room_game/views/game/game_completed/game-completed-artifacts.dart';
import 'package:flutter/material.dart';

import '../../../models/puzzle-state.dart';

class GameCompleted extends StatelessWidget {
  const GameCompleted({Key? key, required this.puzzles, required this.timeLeft})
      : super(key: key);

  final List<PuzzleState> puzzles;
  final Duration timeLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/abandoned-jungle.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: GameCompletedArtifacts(
          solvedPuzzles: puzzles,
          timeLeft: timeLeft,
        ),
      ),
    );
  }
}

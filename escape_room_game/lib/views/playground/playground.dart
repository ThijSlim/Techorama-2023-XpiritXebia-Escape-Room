import 'package:escape_room_game/models/puzzle-state.dart';
import 'package:escape_room_game/views/game/active_game/game-progress.dart';
import 'package:escape_room_game/views/onboard/boarding-gate.dart';
import 'package:flutter/material.dart';

import '../game/active_game/game-artifact-collect-animation.dart';
import '../game/game_completed/game-completed.dart';
import '../intro/intro-video.dart';

class Playground extends StatefulWidget {
  const Playground({Key? key}) : super(key: key);

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground>
    with SingleTickerProviderStateMixin {
  late Animation sizeAnimation;
  late Animation colorAnimation;

  List<PuzzleState> solvedPuzzles = [
    PuzzleState(
      puzzleType: PuzzleType.Blinky,
      solved: true,
    ),
    PuzzleState(
      puzzleType: PuzzleType.GlobalMap,
      solved: true,
    ),
    PuzzleState(
      puzzleType: PuzzleType.FlightBadges,
      solved: true,

    ),
    PuzzleState(
      puzzleType: PuzzleType.GitHub,
      solved: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: GameCompleted(
              puzzles: solvedPuzzles,
              timeLeft: Duration(seconds: 49),
            ),
          ),
          // Expanded(
          //   child: BoardingGate(teamName: "AbC3XX0rrr"),
          // ),
          //Expanded(child: IntroVideoPlayer()),
        ],
      ),
    );
  }
}

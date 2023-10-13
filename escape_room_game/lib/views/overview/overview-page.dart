import 'package:escape_room_game/models/game-state.dart';
import 'package:escape_room_game/providers/game-provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio-controller.dart';
import '../game/game.dart';
import '../intro/intro.dart';
import '../leaderboard/leaderboard.dart';
import '../onboard/onboard.dart';

class Overview extends ConsumerStatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  ConsumerState<Overview> createState() => _OverviewState();
}

class _OverviewState extends ConsumerState<Overview> {
  final double spacing = 10;

  @override
  Widget build(BuildContext context) {
    var gameStatusProvider = ref.watch(gameStateProvider);
    var gameStatus = gameStatusProvider.gameStatus;

    var isOnboarding =
        gameStatus == GameStatus.Idle || gameStatus == GameStatus.Intro;

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
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Row(
                  children: [
                    SizedBox(width: 400, child: Intro()),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: 900,
                              height: isOnboarding ? 700 : 200,
                              child: const Onboard()),
                          SizedBox(
                              width: 900,
                              height: isOnboarding ? 200 : 600,
                              child: const Game()),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing),
                    SizedBox(
                        width: 500,
                        child: Column(
                          children: const [
                            Expanded(child: Leaderboard()),
                            AudioController(),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

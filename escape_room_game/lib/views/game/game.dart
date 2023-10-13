import 'dart:io';

import 'package:escape_room_game/views/game/game_completed/game-completed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../models/game-state.dart';
import '../../models/puzzle-state.dart';
import '../../providers/game-provider.dart';
import '../shared/inactive.dart';
import 'active_game/game-in-progress.dart';
import 'ready_to_start/ready-to-start.dart';

class Game extends ConsumerStatefulWidget {
  const Game({super.key});

  @override
  ConsumerState<Game> createState() => _GameState();
}

class _GameState extends ConsumerState<Game> {
  @override
  Widget build(BuildContext context) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    final GameState gameState = gameStateProviderWatch;

    final gameSucceeded = gameState.gameCompletedSuccessful;
    final puzzles = gameState.gameProgress;

    final timeLeft = gameState.timeLeft;

    return Container(
      child: renderScreen(gameState.gameStatus, gameSucceeded, puzzles, timeLeft),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    enterFullScreen();
  }

  void enterFullScreen(){
    if (!kIsWeb && Platform.isWindows) {
      WindowManager.instance.setFullScreen(true).then((value){
        // entered full screen
      });
    }
  }

  renderScreen(GameStatus gameStatus, bool? gameSucceeded, List<PuzzleState> puzzles, Duration? timeLeft) {
    switch (gameStatus) {
      case GameStatus.Idle:
        return const Inactive(text: "WAITING FOR GAME TO START");
      case GameStatus.Intro:
        return const Inactive(text: "INTRO PLAYING");
      case GameStatus.ReadyToStart:
        return const ReadyToStart();
      case GameStatus.InProgress:
        return GameInProgress();
      case GameStatus.Completed:
        return GameCompleted(puzzles: puzzles, timeLeft: timeLeft!);
      default:
        return const Placeholder();
    }
  }





}

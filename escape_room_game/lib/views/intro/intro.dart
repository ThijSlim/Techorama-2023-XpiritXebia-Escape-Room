import 'dart:io';

import 'package:escape_room_game/views/intro/skip-intro-video.dart';
import 'package:escape_room_game/views/shared/inactive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game-state.dart';
import '../../providers/game-provider.dart';
import 'game-status-screen.dart';
import 'intro-video.dart';

class Intro extends ConsumerStatefulWidget {
  @override
  ConsumerState<Intro> createState() => _IntroState();
}

class _IntroState extends ConsumerState<Intro> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    final GameState gameState = gameStateProviderWatch;

    return Container(
      color: Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        key: ValueKey(gameState.gameStatus),
        child: FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: renderScreen(gameState.gameStatus)),
      ),
    );
  }

  renderScreen(GameStatus gameStatus) {
    if (gameStatus == GameStatus.Intro) {
      if (!kIsWeb && Platform.isWindows) {
        return const IntroVideoPlayer();
      } else {
        return const SkipIntroVideo();
      }
    }

    if (gameStatus == GameStatus.ReadyToStart) {
      return const Inactive(text: "PUSH BUTTON TO START GAME");
    }

    if (gameStatus == GameStatus.InProgress ||
        gameStatus == GameStatus.Completed) {
      return const GameStatusScreen();
    }

    return const Inactive(text: "WAITING FOR GAME TO START");
  }
}

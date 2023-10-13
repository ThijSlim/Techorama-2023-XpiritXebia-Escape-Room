import 'package:escape_room_game/views/onboard/boarding-gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game-state.dart';
import '../../providers/game-provider.dart';
import '../shared/inactive.dart';
import 'team-boarding.dart';

class Onboard extends ConsumerWidget {
  const Onboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    final GameState gameState = gameStateProviderWatch;

    return Container(
      color: Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        key: ValueKey(gameState.gameStatus),
        child: FadeTransition(
          opacity: const AlwaysStoppedAnimation(1.0),
          child: renderScreen(gameState.gameStatus, gameState.activeTeam ?? ""),
        ),
      ),
    );
  }

  renderScreen(GameStatus gameStatus, String teamName) {
    if (gameStatus == GameStatus.Idle) {
      return const TeamBoarding();
    }

    if (gameStatus == GameStatus.Intro) {
      return BoardingGate(teamName: teamName);
    }

    return const Inactive(text: "GAME IN PROGRESS");
  }
}

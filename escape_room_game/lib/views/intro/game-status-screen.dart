import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game-state.dart';
import '../../providers/game-provider.dart';

class GameStatusScreen extends ConsumerWidget {
  const GameStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    final GameState gameState = gameStateProviderWatch;

    var timeLeftText = gameState.timeLeft.toString().substring(3, 7);

    var timeLeft = gameState.timeLeft ?? Duration(seconds: 0);

    bool isUrgent =
        timeLeft.inSeconds <= 30 && gameState.gameStatus == GameStatus.InProgress;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/abandoned-jungle.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Text(
          timeLeftText,
          style: TextStyle(
              color: isUrgent ? Colors.red : Colors.white,
              fontSize: 120,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

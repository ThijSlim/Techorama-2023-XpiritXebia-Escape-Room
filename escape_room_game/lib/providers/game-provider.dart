import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:escape_room_game/models/game-state.dart';
import 'package:escape_room_game/services/game-service.dart';
import 'package:retry/retry.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final apiStateNotifier = GameStateNotifier();
  final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    apiStateNotifier.fetchData();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return apiStateNotifier;
});

final listenToGameStatusProvider = Provider((ref) {
  ref.listen<GameStatus>(gameStatusProvider,
      (GameStatus? previous, GameStatus next) {
    if (next == GameStatus.ReadyToStart) {
      ref.read(readyToStartCountdownStateNotifier.notifier).startCountdown(10);
    }

    if (next == GameStatus.InProgress) {
      ref.read(readyToStartCountdownStateNotifier.notifier).updateState(null);
    }
  });

  return "Test";
});

final listenToCountdownProvider = Provider((ref) {
  ref.listen<int?>(readyToStartCountdownStateNotifier, (int? previous, int? next) async {
    print("listenToCountdownProvider" + next.toString());

    if (next == 0) {
      print("POST START GAME");
      await retry(
        () => postStartGame().timeout(const Duration(seconds: 5)),
        maxAttempts: 5,
      );
    }
  });

  return "Test";
});

final gameStatusProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  return gameState.gameStatus;
});

final timeTillHintEnabledProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  if (gameState.timeTillHintIsEnabled == null) {
    return const Duration(seconds: 0);
  }

  return gameState.timeTillHintIsEnabled as Duration;
});

final hintActivatedProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  return gameState.activatedHint;
});

final timeTillNextAnswerTryProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  if (gameState.timeTillNextAnswerTry == null ||
      gameState.timeTillNextAnswerTry == const Duration(seconds: 0)) {
    return null;
  }

  return gameState.timeTillNextAnswerTry;
});

final gameProgressProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  return gameState.gameProgress;
});

final gameTimeProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  if (gameState.timeLeft == null) {
    return const Duration(seconds: 0);
  }

  return gameState.timeLeft as Duration;
});

final gameQuestionProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);
  if (gameState.activeQuestion == null) {
    return "";
  }

  return gameState.activeQuestion as String;
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier()
      : super(GameState(
            gameStatus: GameStatus.Idle,
            activeTeam: "",
            activeQuestion: null,
            gameCompletedSuccessful: null,
            timeLeft: Duration(seconds: 120),
            activatedHint: "",
            timeTillHintIsEnabled: Duration(seconds: 60),
            timeTillNextAnswerTry: null,
            gameProgress: []));

  Future<void> fetchData() async {
    fetchGameState().then((value) {
      state = value;
    });
  }
}

// Countdown provider
final countdownProvider = Provider((ref) {
  final gameState = ref.watch(gameStateProvider);

  if (gameState.gameStatus == GameStatus.InProgress) {
    return gameState.timeLeft;
  }

  return const Duration(seconds: 0);
});

class ReadyToStartCountdownStateNotifier extends StateNotifier<int?> {
  ReadyToStartCountdownStateNotifier() : super(null);

  void updateState(int? secondsRemaining) {
    state = secondsRemaining;
  }

  startCountdown(int seconds) {
    updateState(seconds);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        updateState(null);
      } else {
        seconds--;
        updateState(seconds);
      }
    });
  }
}

final readyToStartCountdownStateNotifier =
    StateNotifierProvider<ReadyToStartCountdownStateNotifier, int?>((ref) {
  return ReadyToStartCountdownStateNotifier();
});

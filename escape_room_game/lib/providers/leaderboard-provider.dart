
import 'dart:async';

import 'package:escape_room_game/services/game-service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leaderboardStateProvider =
StateNotifierProvider<LeaderboardStateNotifier, List<LeaderboardTeam>>((ref) {
  final apiStateNotifier = LeaderboardStateNotifier();
  final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    apiStateNotifier.fetchData();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return apiStateNotifier;
});

class LeaderboardStateNotifier extends StateNotifier<List<LeaderboardTeam>> {
  LeaderboardStateNotifier()
      : super([]);

  Future<void> fetchData() async {
    fetchLeaderboard().then((value) {
      state = value;
    });
  }
}
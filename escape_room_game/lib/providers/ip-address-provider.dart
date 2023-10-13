
import 'dart:async';

import 'package:escape_room_game/services/game-service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backendIpAddressStateProvider =
StateNotifierProvider<BackendIpAddressStateNotifier, String>((ref) {

  return BackendIpAddressStateNotifier();
});

class BackendIpAddressStateNotifier extends StateNotifier<String> {
  BackendIpAddressStateNotifier()
      : super("");

  void setIpAddress(String ipAddress) async {
    state = ipAddress;
  }
}
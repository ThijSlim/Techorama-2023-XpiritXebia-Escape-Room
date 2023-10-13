import 'dart:async';

import 'package:escape_room_game/providers/game-provider.dart';
import 'package:escape_room_game/services/game-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retry/retry.dart';

class ReadyToStart extends ConsumerStatefulWidget {
  const ReadyToStart({Key? key}) : super(key: key);

  @override
  ConsumerState<ReadyToStart> createState() => _ReadyToStartState();
}

class _ReadyToStartState extends ConsumerState<ReadyToStart> {

  @override
  Widget build(BuildContext context) {
    var secondRemaining = ref.watch(readyToStartCountdownStateNotifier);

    // Button with push to start
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/abandoned-jungle.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.5),
                  spreadRadius: 10,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                postStartGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                elevation: 0,
              ),
              child: const Text(
                "START\nGAME",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            "Automatically starts in ${secondRemaining ?? 0} seconds",
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

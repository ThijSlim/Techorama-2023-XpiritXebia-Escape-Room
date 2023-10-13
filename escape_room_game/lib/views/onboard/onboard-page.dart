import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game-state.dart';
import '../../providers/game-provider.dart';
import 'team-boarding.dart';
import 'onboard.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          kDebugMode ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ) : const SizedBox(),
          const Expanded(
            child: Onboard(),
          ),
        ],
      ),
    );
  }

  Widget renderScreen(GameStatus gameStatus) {
    if (gameStatus == GameStatus.Idle) {
      return const TeamBoarding();
    }

    return const Placeholder(child: Center(child: Text("GAME IN PROGRESS!")));
  }
}

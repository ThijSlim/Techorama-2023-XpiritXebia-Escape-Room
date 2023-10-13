import 'dart:io';

import 'package:escape_room_game/services/game-service.dart';
import 'package:escape_room_game/views/leaderboard/leaderboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          kDebugMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                )
              : const SizedBox(),
          const Expanded(
            child: Leaderboard(),
          ),
        ],
      ),
    );
  }
}

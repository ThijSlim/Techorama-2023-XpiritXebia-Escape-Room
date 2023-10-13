import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retry/retry.dart';

import '../../services/game-service.dart';

class IntroVideoPlayer extends StatefulWidget {
  const IntroVideoPlayer({super.key});

  @override
  _IntroVideoPlayerState createState() => _IntroVideoPlayerState();
}

class _IntroVideoPlayerState extends State<IntroVideoPlayer> {
  Player player = Player(id: 0);
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      player.playbackStream.listen((value) async {
        if (value.isCompleted) {
          await onReadyGame();
        }
      });

      player.errorStream.listen((event) {
        print('libVLC error.');
      });

      player.open(
        Media.file(File("C:\\natascha-onboard.mp4")),
        autoStart: false,
      );

      Future.delayed(
        const Duration(seconds: 15),
        () {
          player.play();
          setState(() {
            isPlaying = true;
          });
        },
      );
    }
  }

  onReadyGame() async {
    await retry(
      () => postReadyGame().timeout(const Duration(seconds: 5)),
      maxAttempts: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Video(
          player: player,
          fit: BoxFit.fitWidth,
          showControls: false,
        ),
        !isPlaying
            ? Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "FASTEN YOUR SEATBELTS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "THE GAME IS ABOUT TO BEGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}

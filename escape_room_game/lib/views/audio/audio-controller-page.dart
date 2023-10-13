import 'package:escape_room_game/views/audio/audio-controller.dart';
import 'package:flutter/material.dart';

class AudioControllerPage extends StatelessWidget {
  const AudioControllerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          const Expanded(
            child: AudioController(),
          ),
        ],
      ),
    );
  }
}

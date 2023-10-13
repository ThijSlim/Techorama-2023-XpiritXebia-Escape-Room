import 'dart:io';

import 'package:escape_room_game/views/intro/intro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

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
              : SizedBox(),
          Expanded(
            child: Intro(),
          ),
        ],
      ),
    );
  }
}

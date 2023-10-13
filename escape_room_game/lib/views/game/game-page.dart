import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'game.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

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
          const Expanded(
            child: Game(),
          ),
        ],
      ),
    );
  }
}

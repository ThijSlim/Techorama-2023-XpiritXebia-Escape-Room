import 'package:flutter/material.dart';

import '../../services/game-service.dart';

class SkipIntroVideo extends StatelessWidget {
  const SkipIntroVideo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await postReadyGame();
        },
        child: const Text('Skip intro video'),
      ),
    );
  }
}

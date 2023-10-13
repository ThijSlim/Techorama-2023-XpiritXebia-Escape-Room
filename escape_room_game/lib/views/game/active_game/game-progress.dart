import 'package:escape_room_game/Palette.dart';
import 'package:escape_room_game/providers/game-provider.dart';
import 'package:escape_room_game/views/game/active_game/game-artifact-collect-animation.dart';
import 'package:escape_room_game/views/game/active_game/game-artifact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/puzzle-state.dart';

class GameProgress extends ConsumerStatefulWidget {
  final List<PuzzleState> solvedPuzzles;
  const GameProgress({Key? key, required this.solvedPuzzles}) : super(key: key);

  @override
  ConsumerState<GameProgress> createState() => _GameProgressState();
}

class _GameProgressState extends ConsumerState<GameProgress>
    with SingleTickerProviderStateMixin {
  final int totalArtifacts = 4;
  final double logoSize = 120;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints boxConstraints) {
        return Stack(
          children: [
            // foreach solved puzzles

            for (int i = 0; i < totalArtifacts; i++) renderArtifactPlaceholder(i),

            for (int i = 0; i < widget.solvedPuzzles.length; i++)
              AnimatedCollectedGameArtifact(
                puzzleType: widget.solvedPuzzles[i].puzzleType,
                totalArtifacts: totalArtifacts,
                boxConstraints: boxConstraints,
                index: i,
                logoSize: logoSize,
              ),
          ],
        );
      },
    );
  }

  renderArtifactPlaceholder(int index) {
    var floatRight = index * logoSize;

    return Positioned(
      top: 0,
      right: floatRight,
      child: SizedBox(
        width: logoSize,
        height: logoSize,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

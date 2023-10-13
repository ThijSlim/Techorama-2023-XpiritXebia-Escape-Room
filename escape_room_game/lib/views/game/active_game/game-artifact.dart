import 'package:escape_room_game/models/puzzle-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Palette.dart';

class GameArtifact extends StatelessWidget {
  GameArtifact({Key? key, required this.width, required this.height, required this.puzzleType})
      : super(key: key);

  final PuzzleType puzzleType;
  final double width;
  final double height;

  Map<PuzzleType, String> puzzleAssets = {
    PuzzleType.Blinky: "assets/images/artifacts/Artifact-Blinky.png",
    PuzzleType.GlobalMap: "assets/images/artifacts/Artifact-Country.png",
    PuzzleType.DevOps: "assets/images/artifacts/Artifact-DevOps.png",
    PuzzleType.Magazine: "assets/images/artifacts/Artifact-XPRT.png",
    PuzzleType.CoreValues: "assets/images/artifacts/Artifact_Values.png",
    PuzzleType.FlightBadges: "assets/images/artifacts/Artifacts-Badge-People.png",
    PuzzleType.Bookshelf: "assets/images/artifacts/Artifacts-Books.png",
    PuzzleType.GitHub: "assets/images/artifacts/Artifacts-GitHub-Mona.png",
  };


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width,
      child: Image.asset(
        puzzleAssets[puzzleType]!,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/puzzle-state.dart';
import '../active_game/game-artifact-collect-animation.dart';

class GameCompletedArtifacts extends StatefulWidget {
  const GameCompletedArtifacts({Key? key, required this.solvedPuzzles, required this.timeLeft})
      : super(key: key);

  final List<PuzzleState> solvedPuzzles;
  final Duration timeLeft;

  @override
  State<GameCompletedArtifacts> createState() => _GameCompletedArtifactsState();
}

class _GameCompletedArtifactsState extends State<GameCompletedArtifacts> {
  Map<int, bool> puzzleCorrectnessShown = {};
  var logoSize = 200.0;

  bool isResultShown = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setCorrectness(0);
  }

  setCorrectness(int i) {
    var solvedPuzzle = widget.solvedPuzzles[i];
    setState(() {
      puzzleCorrectnessShown[i] = solvedPuzzle.solved;
    });

    var nextIndex = i + 1;

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (nextIndex >= widget.solvedPuzzles.length) {
        setState(() {
          isResultShown = true;
        });
        return;
      }

      setCorrectness(nextIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: logoSize * 4,
      height: logoSize * 2.5,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints boxConstraints) {
          return Stack(
            children: [
              for (int i = 0; i < widget.solvedPuzzles.length; i++)
                renderArtifactPlaceholder(i),

              // loop through puzzleCorrectnessShown key value map
              for (var puzzleCorrectness in puzzleCorrectnessShown.entries)
                puzzleCorrectness.value
                    ? AnimatedCollectedGameArtifact(
                        totalArtifacts: widget.solvedPuzzles.length,
                        boxConstraints: boxConstraints,
                        puzzleType: widget
                            .solvedPuzzles[puzzleCorrectness.key].puzzleType,
                        index: puzzleCorrectness.key,
                        logoSize: logoSize,
                      )
                    : renderWrong(puzzleCorrectness.key),

                AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  scale: isResultShown ? 1 : 0,
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      child: renderGameResult()),
                ),
            ],
          );
        },
      ),
    );
  }

  // all puzzles solved method true
  bool allPuzzlesSolved(){
    return widget.solvedPuzzles.every((puzzle) => puzzle.solved);
  }

  renderGameResult() {

    var timeLeft = widget.timeLeft.toString().substring(3, 7);

    if(allPuzzlesSolved()){
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children:  [
          Text(timeLeft,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 0.7,
              )),
          const Text(
            'You Escaped',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(timeLeft,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        const Text(
          'Time\'s up!',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  renderWrong(int index) {
    var floatRight = index * logoSize;

    return Positioned(
      top: 0,
      left: floatRight,
      child: const Icon(
        Icons.close,
        color: Colors.red,
        size: 200,
      ),
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

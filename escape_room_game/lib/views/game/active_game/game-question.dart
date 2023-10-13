import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:escape_room_game/models/game-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/game-provider.dart';
import 'game-progress.dart';

class GameQuestion extends ConsumerStatefulWidget {
  const GameQuestion({super.key, required this.answerFeedback});

  final bool? answerFeedback;

  @override
  GameQuestionState createState() => GameQuestionState();
}

class GameQuestionState extends ConsumerState<GameQuestion> {
  Color getBackgroundColor() {
    if (widget.answerFeedback == null) {
      return Colors.transparent;
    } else if (widget.answerFeedback!) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var question = ref.read(gameQuestionProvider);

    setState(() {
      activeQuestion = question;
    });
  }

  String activeQuestion = "";

  delayQuestion(String question) {
    setQuestion("");

    Future.delayed(const Duration(milliseconds: 2000), () {
      setQuestion(question);
    });
  }

  setQuestion(String question) {
    setState(() {
      activeQuestion = question;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    ref.listen<String>(gameQuestionProvider,
        (String? previousQuestion, String currentQuestion) {
      if (previousQuestion == null) {
        setQuestion(currentQuestion!);
      } else {
        delayQuestion(currentQuestion!);
      }
    });

    var backgroundColor = getBackgroundColor();

    final GameState gameState = gameStateProviderWatch;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/abandoned-jungle.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: backgroundColor.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: constraints.maxWidth / 1.5,
                    alignment: Alignment.center,
                    child: DefaultTextStyle(
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: constraints.maxWidth / 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        // overflow: TextOverflow.clip,
                      ),
                      child: Stack(
                        children: [
                          // Transparent text to have the correct height of the container
                          Opacity(opacity: 0.0, child: Text(activeQuestion)),
                          AnimatedTextKit(
                            key: Key(activeQuestion),
                            animatedTexts: [
                              TypewriterAnimatedText(
                                activeQuestion,
                                speed: const Duration(milliseconds: 30),
                              ),
                            ],

                            isRepeatingAnimation: false,
                            totalRepeatCount: 1,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 600,
                      child: Text(
                        gameState.activatedHint ?? "",
                        style: const TextStyle(fontSize: 26, color: Colors.white),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                GameProgress(
                  solvedPuzzles: gameState.gameProgress
                      .where((element) => element.solved)
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

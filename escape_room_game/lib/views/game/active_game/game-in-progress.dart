import 'package:flutter/material.dart';

import '../../../services/game-service.dart';
import 'game-input.dart';
import 'game-question.dart';

class GameInProgress extends StatefulWidget {
  GameInProgress({Key? key}) : super(key: key);


  @override
  State<GameInProgress> createState() => _GameInProgressState();
}

class _GameInProgressState extends State<GameInProgress> {
  int? _answeredNumber;
  bool? answerFeedback;

  Future<void> onAnswerQuestion() async {
    var isCorrect = await postAnswer(_answeredNumber!);

    setState(() {
      answerFeedback = isCorrect;

      // timer to reset answer feedback
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          answerFeedback = null;
          _answeredNumber = null;
        });
      });
    });
  }

  void onNumberSelected(int number) {
    setState(() {
      _answeredNumber = number;
    });
  }

  void onNumberCleared() {
    setState(() {
      _answeredNumber = null;
    });
  }

  Future<void> onActivateHint() async {
    await postActivateHint();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // fill the rest of the screen with the game question
        Expanded(
          flex: 3,
          child: GameQuestion(
            answerFeedback: answerFeedback,
          ),
        ),
        Expanded(
          flex: 1,
          child: GameInput(
            selectedNumber: _answeredNumber,
            answerFeedback: answerFeedback,
            onAnswerQuestion: onAnswerQuestion,
            onNumberSelected: onNumberSelected,
            onClearNumber: onNumberCleared,
            onActivateHint: onActivateHint,
          ),
        ),
      ],
    );
  }
}

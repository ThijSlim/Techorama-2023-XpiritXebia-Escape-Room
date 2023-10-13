import 'package:escape_room_game/services/game-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/game-provider.dart';
import 'answer-text.dart';
import 'numerical-input.dart';

class GameInput extends ConsumerStatefulWidget {
  GameInput({
    Key? key,
    required this.selectedNumber,
    required this.answerFeedback,
    required this.onAnswerQuestion,
    required this.onNumberSelected,
    required this.onClearNumber,
    required this.onActivateHint,
  }) : super(key: key);

  bool? answerFeedback;
  int? selectedNumber;

  VoidCallback onAnswerQuestion;
  Function(int) onNumberSelected;
  VoidCallback onClearNumber;
  VoidCallback onActivateHint;

  @override
  ConsumerState<GameInput> createState() => _GameInputState();
}

class _GameInputState extends ConsumerState<GameInput> {

  bool isQuestionAnsweredJustNow = false;

  onAnswerQuestion(){
    widget.onAnswerQuestion();

    setState(() {
      isQuestionAnsweredJustNow = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if(!mounted){
        return;
      }

      setState(() {
        isQuestionAnsweredJustNow = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);
    var timeTillNextAnswerTry = gameStateProviderWatch.timeTillNextAnswerTry;
    var isPenalty =
        timeTillNextAnswerTry != null && timeTillNextAnswerTry > Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.black87,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NumericalInput(
            isDisabled: isPenalty,
            onNumberPressed: widget.onNumberSelected,
            onClearPressed: widget.onClearNumber,
          ),
          AnswerText(
            answer: widget.selectedNumber?.toString() ?? "",
            answerFeedback: widget.answerFeedback,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth / 2) - 10;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  renderHintButton(
                      width,
                      gameStateProviderWatch.timeTillHintIsEnabled,
                      gameStateProviderWatch.activatedHint),
                  renderAnswerButton(
                    width,
                    isPenalty,
                    timeTillNextAnswerTry,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget renderAnswerButton(
      double width, bool isPenalty, Duration? timeTillNextAnswerTry) {
    var penaltyBackgroundColor = Colors.red.shade600;

    var penaltyTimeText =
        isPenalty ? timeTillNextAnswerTry.toString().substring(3, 7) : "";

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPenalty ? penaltyBackgroundColor : Colors.teal,
        foregroundColor: Colors.white,
        minimumSize: Size(width * 1.5, width / 2),
        disabledBackgroundColor:
            isPenalty ? penaltyBackgroundColor : Colors.black12,
      ),
      onPressed: !isQuestionAnsweredJustNow && widget.selectedNumber != null ? onAnswerQuestion : null,
      child: Text(
        isPenalty ? penaltyTimeText : "ANSWER",
        style: TextStyle(fontSize: width / 5, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget renderHintButton(
    double width,
    Duration? timeTillHint,
    String? activatedHint,
  ) {
    var isHintEnabled = timeTillHint != null &&
        timeTillHint <= Duration.zero &&
        activatedHint == null;

    var timeTillHintText = timeTillHint != null && timeTillHint > Duration.zero
        ? "\n${timeTillHint.toString().substring(3, 7)}"
        : "";

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width / 2, width / 2),
        backgroundColor: isHintEnabled ? Colors.amber : Colors.grey,
        disabledBackgroundColor: Colors.black12,
      ),
      onPressed: isHintEnabled ? widget.onActivateHint : null,
      child: Text(
        "HINT$timeTillHintText",
        style: TextStyle(
          fontSize: width / 7,
          color: isHintEnabled || activatedHint != null
              ? Colors.black
              : Colors.white24,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnswerText extends StatefulWidget {
  final bool? answerFeedback;
  final String answer;

  const AnswerText(
      {super.key, required this.answer, required this.answerFeedback});

  @override
  State<AnswerText> createState() => _AnswerTextState();
}

class _AnswerTextState extends State<AnswerText> {
  Color getBackgroundColor() {
    if (widget.answerFeedback == null) {
      return Colors.black38;
    } else if (widget.answerFeedback!) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          width: constraints.maxWidth,
          height: constraints.maxWidth / 2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
            color: getBackgroundColor(),
          ),
          child: Center(
            child: Text(
              widget.answer,
              style: TextStyle(
                fontSize: constraints.maxWidth / 3,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

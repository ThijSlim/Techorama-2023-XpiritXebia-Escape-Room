import 'package:flutter/material.dart';

class NumericalInput extends StatefulWidget {

  const NumericalInput(
      {super.key, required this.onNumberPressed, required this.onClearPressed, required this.isDisabled});

  final Function(int) onNumberPressed;
  final bool isDisabled;
  final VoidCallback onClearPressed;

  @override
  State<NumericalInput> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NumericalInput> {


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        NumberButton('1'),
        NumberButton('2'),
        NumberButton('3'),
      ]),
      Row(children: [
        NumberButton('4'),
        NumberButton('5'),
        NumberButton('6'),
      ]),
      Row(children: [
        NumberButton('7'),
        NumberButton('8'),
        NumberButton('9'),
      ]),
      Row(children: [
        NumberButton('', disabled: true),
        NumberButton('0'),
        NumberButton('C', isNumber: false),
      ]),
    ]);
  }

  Widget NumberButton(String number,
      {bool isNumber = true, bool disabled = false}) {
    return Expanded(
      flex: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth * 0.05;

          var size = constraints.maxWidth - (padding * 2);

          return Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                maximumSize: Size(size, size),
                minimumSize: Size(size, size),
              ),
              onPressed: !disabled && !widget.isDisabled ? () {
                if (isNumber) {
                  widget.onNumberPressed(int.parse(number));
                } else {
                  widget.onClearPressed();
                }
              } : null,
              child: Text(
                number,
                style: TextStyle(
                  fontSize: size / 3,
                  fontWeight: FontWeight.bold,
                  color: isNumber ? Colors.white : Colors.white60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

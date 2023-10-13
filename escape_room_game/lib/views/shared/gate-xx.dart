import 'package:flutter/material.dart';

import '../../Palette.dart';

class GateXX extends StatelessWidget {
  const GateXX({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          "GATE ",
          style: TextStyle(
              fontSize: 50,
              color: Colors.white,
              height: 1,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "X",
          style: TextStyle(
              fontSize: 50,
              color: Colors.purple,
              height: 1,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "|",
            style: TextStyle(fontSize: 45, color: Colors.white),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "X",
          style: TextStyle(
              fontSize: 50,
              color: Palette.xpiritColor,
              height: 1,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

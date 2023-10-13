import 'package:escape_room_game/views/shared/gate-xx.dart';
import 'package:flutter/material.dart';

class BoardingGate extends StatelessWidget {
  const BoardingGate({Key? key, required this.teamName}) : super(key: key);

  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(teamName, style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold, height: 1),),
          Text(
            "PLEASE BOARD",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          GateXX()
        ],
      )),
    );
  }
}

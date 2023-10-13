import 'package:escape_room_game/services/game-service.dart';
import 'package:escape_room_game/views/onboard/player-seat.dart';
import 'package:escape_room_game/views/onboard/team-input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class TeamBoarding extends StatefulWidget {
  const TeamBoarding({Key? key}) : super(key: key);

  @override
  State<TeamBoarding> createState() => _TeamBoardingState();
}

class _TeamBoardingState extends State<TeamBoarding> {
  bool isBoardingNow = false;

  final Map<int, String?> claimedSeats = kDebugMode
      ? {
          1: "WILSONN",
          2: "Billy",
          3: null,
        }
      : {
          1: null,
          2: null,
          3: null,
        };

  Map<int, String?> seatName = {
    1: "A",
    2: "B",
    3: "C",
  };

  String teamName = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/airplane_checking_in.png"),
              // colorFilter: ColorFilter.mode(backgroundColor, BlendMode.dstATop),
              fit: BoxFit.cover,
              // gradient
            ),
          ),
          width: double.infinity,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              stops: [0.0, 0.3, 0.4, 1.0],
              colors: [
                Color.fromRGBO(0, 0, 0, 0.0),
                Color.fromRGBO(0, 0, 0, 0.3),
                Color.fromRGBO(0, 0, 0, 0.5),
                Color.fromRGBO(0, 0, 0, 1.0),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "FASTEN YOUR SEATBELTS",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            playerSeats(),
            TeamInput(
              teamName: teamName,
              onClaimPressed: _onOpenTeamNameDialog,
              onClearTeamPressed: _onClearTeam,
            ),
            readyForTakeOffButton(),
          ],
        ),
      ],
    );
  }

  Widget readyForTakeOffButton() {
    var amountSeatsClaimed = amountOfClaimedSeats();

    var isEnabled =
        teamName.isNotEmpty && amountSeatsClaimed >= 2 && !isBoardingNow;


    var seatLeftText = isEnabled ? "" : "$amountSeatsClaimed / 2-3";

    return ElevatedButton(
      onPressed: isEnabled ? onReadyForTakeOf : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.white24,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Column(
        children: [
          isEnabled
              ? const Icon(Icons.flight_takeoff, size: 50)
              : Text(seatLeftText),
          const Text("Ready for Take-Off", textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> onReadyForTakeOf() async {
    await takeOff();

    setState(() {
      isBoardingNow = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if(!mounted){
        return;
      }

      setState(() {
        isBoardingNow = false;
      });
    });
  }

  Widget playerSeats() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Foreach claimedSeats
        for (var i = 1; i <= claimedSeats.length; i++)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: PlayerSeat(
              seatNumber: i,
              isClaimed: claimedSeats[i] != null,
              claimedBy: claimedSeats[i],
              onClaimPressed: onClaimedSeatPressed,
              onClearSeatPressed: onClearSeatPressed,
            ),
          ),
      ],
    );
  }

  onClaimedSeatPressed(int seatNumber) async {
    await _onOpenPlayerNameDialog(seatNumber);
  }

  onClearSeatPressed(int index) {
    setState(() {
      claimedSeats[index] = null;
    });
  }

  _onClearTeam() {
    setState(() {
      teamName = "";
    });
  }

  int amountOfClaimedSeats() {
    int amount = 0;
    for (var i = 1; i <= claimedSeats.length; i++) {
      if (claimedSeats[i] != null) {
        amount++;
      }
    }
    return amount;
  }

  Future<void> takeOff() async {
    List<String> players = claimedSeats.entries
        .map((e) => e.value)
        .where((e) => e != null)
        .toList()
        .cast<String>();

    await postNewTeam(teamName, players);
  }

  Future<void> _onOpenPlayerNameDialog(int seatNumber) async {
    TextEditingController playerNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seat ${seatName[seatNumber]} - Add Player',
            style: const TextStyle(color: Colors.black, fontSize: 30),
          ),
          backgroundColor: Colors.white,
          content: TextField(
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            maxLength: 16,
            controller: playerNameController,
            decoration:
                const InputDecoration(labelText: 'Player Name (min length: 3)'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (playerNameController.text.length < 3) {
                  return;
                }

                setState(() {
                  claimedSeats[seatNumber] = playerNameController.text;
                });

                Navigator.of(context).pop();
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onOpenTeamNameDialog() async {
    TextEditingController teamNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Team name',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          backgroundColor: Colors.white,
          content: TextField(
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            maxLength: 16,
            controller: teamNameController,
            decoration:
                const InputDecoration(labelText: 'Name (min length: 3)'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (teamNameController.text.length < 3) {
                  return;
                }

                setState(() {
                  teamName = teamNameController.text;
                });

                Navigator.of(context).pop();
              },
              child: const Text('BOARD', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }
}

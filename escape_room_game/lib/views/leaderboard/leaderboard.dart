import 'package:escape_room_game/models/game-state.dart';
import 'package:escape_room_game/views/leaderboard/leaderboard-list-item.dart';
import 'package:escape_room_game/views/shared/gate-xx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game-provider.dart';
import '../../providers/leaderboard-provider.dart';

class Leaderboard extends ConsumerStatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  ConsumerState<Leaderboard> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends ConsumerState<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    final gameStateProviderWatch = ref.watch(gameStateProvider);

    var gameStatus = gameStateProviderWatch.gameStatus;
    var teamName = gameStateProviderWatch.activeTeam ?? "";
    var timeLeft = gameStateProviderWatch.timeLeft ?? const Duration();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/leaderboard-background.png"),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              var width = constraints.maxWidth;

              return Stack(
                children: [
                  leaderboardHeading(width),
                  leaderboardPanel(width),
                ],
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Center(child: renderProgress(gameStatus, teamName, timeLeft)),
        )
      ],
    );
  }



  Widget leaderboardHeading(double width) {
    var innerWidth = width * 0.48;
    var marginTop = width * 0.15;
    var marginBottom = width * 0.20;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: innerWidth / 2),
      child: Container(
        margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
        // width: innerWidth,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
            height: width * 0.14,
            width: width * 0.50,
            alignment: Alignment.center,
            child: const Text("Leaderboard",
                style: TextStyle(color: Colors.white, fontSize: 50))),
      ),
    );
  }

  Widget leaderboardPanel(double width) {
    final leaderboardProviderWatch = ref.watch(leaderboardStateProvider);

    var innerWidth = width * 0.74;
    var marginTop = width * 0.38;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: innerWidth / 6),
      child: Container(
        margin: EdgeInsets.only(top: marginTop),
        // width: innerWidth,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboardProviderWatch.length,
          itemBuilder: (context, index) {
            return LeaderboardListItem(
              leaderboardTeam: leaderboardProviderWatch[index],
              position: index + 1,
              width: innerWidth,
            );
          },
        ),
      ),
    );
  }

  Widget renderProgress(
      GameStatus gameStatus, String teamName, Duration timeLeft) {
    if (gameStatus == GameStatus.Intro ||
        gameStatus == GameStatus.ReadyToStart) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Now Boarding",
              style: TextStyle(fontSize: 40, color: Colors.white, height: 1)),
          const SizedBox(
            height: 10,
          ),
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 50,
              color: Colors.white,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    if (gameStatus == GameStatus.InProgress) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Currently in flight mode",
              style: TextStyle(fontSize: 40, color: Colors.white, height: 1),
              textAlign: TextAlign.center),
          const SizedBox(
            height: 10,
          ),
          Text(
            timeLeft.toString().substring(3, 7),
            style: const TextStyle(
              fontSize: 50,
              color: Colors.white,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Ready for Boarding",
            style:
                const TextStyle(fontSize: 40, color: Colors.white, height: 1)),
        SizedBox(
          height: 10,
        ),
        GateXX()
      ],
    );
  }
}

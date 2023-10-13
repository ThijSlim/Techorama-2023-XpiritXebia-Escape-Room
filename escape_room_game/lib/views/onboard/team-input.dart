import 'package:flutter/material.dart';

class TeamInput extends StatelessWidget {
  TeamInput({
    Key? key,
    required this.teamName,
    required this.onClaimPressed,
    required this.onClearTeamPressed,
  }) : super(key: key);

  final String teamName;
  VoidCallback onClaimPressed;
  VoidCallback onClearTeamPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 500,
          height: 140,
          decoration: BoxDecoration(
            color: teamName.isNotEmpty ? Colors.green : Colors.white24,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              teamName.isEmpty
                  ? claimButton()
                  : Text(
                      teamName,
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
              const SizedBox(width: 10),
              teamName.isEmpty ? planeIcon(teamName.isNotEmpty) : const SizedBox(),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        teamName.isNotEmpty
            ? clearTeamButton()
            : const SizedBox(
                height: 40,
              ),
      ],
    );
  }

  Widget planeIcon(bool isClaimed) {
    return Icon(
      isClaimed ? Icons.airplane_ticket : Icons.airplane_ticket_outlined,
      size: 75,
      color: Colors.white,
    );
  }

  Widget claimButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: const Size(200, 65),
      ),
      onPressed: () {
        onClaimPressed();
      },
      child: const Text(
        'TEAM NAME',
        style: TextStyle(
          fontSize: 26,
        ),
      ),
    );
  }

  Widget clearTeamButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
        elevation: 5,
        fixedSize: const Size(200, 40),
      ),
      onPressed: () {
        onClearTeamPressed();
      },
      child: const Text(
        'CLEAR TEAM',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}

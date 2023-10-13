import 'package:flutter/material.dart';

class PlayerSeat extends StatelessWidget {
  PlayerSeat({
    Key? key,
    required this.seatNumber,
    required this.isClaimed,
    required this.claimedBy,
    required this.onClaimPressed,
    required this.onClearSeatPressed,
  }) : super(key: key);

  final int seatNumber;
  final bool isClaimed;
  final String? claimedBy;
  Function(int) onClaimPressed;
  Function(int) onClearSeatPressed;

  Map<int, String?> seatName = {
    1: "A",
    2: "B",
    3: "C",
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onClaimPressed(seatNumber),
          child: Container(
            width: 230,
            height: 230,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isClaimed ? Colors.green : Colors.white24,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                seatIcon(isClaimed),
                isClaimed ? seatText() : claimButton(seatNumber),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        isClaimed ? clearSeatButton() : const SizedBox(height: 40),
      ],
    );
  }

  Widget seatText() {
    return Column(
      children: [
        Text(
          claimedBy ?? "",
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        const Text(
          "READY",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget claimButton(int seatNumber) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: const Size(200, 65),
      ),
      onPressed: (){
        onClaimPressed(seatNumber);
      } ,
      child: Text(
        'SEAT ${seatName[seatNumber]}',
        style: const TextStyle(
          fontSize: 26,
        ),
      ),
    );
  }

  Widget seatIcon(bool isClaimed) {
    return Icon(
      isClaimed ? Icons.event_seat : Icons.event_seat_outlined,
      size: 120,
      color: Colors.white,
    );
  }

  Widget clearSeatButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
        elevation: 5,
        fixedSize: const Size(200, 40),
      ),
      onPressed: (){
        onClearSeatPressed(seatNumber);
      } ,
      child: const Text(
        'CLEAR SEAT',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}

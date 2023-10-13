import 'package:flutter/material.dart';

class AirplaneAnimation extends StatefulWidget {
  const AirplaneAnimation({Key? key, required this.animationController})
      : super(key: key);

  final AnimationController animationController;

  @override
  _AirplaneAnimationState createState() => _AirplaneAnimationState();
}

class _AirplaneAnimationState extends State<AirplaneAnimation>
    with TickerProviderStateMixin {
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Create an animation controller and duration

    // Create a Tween animation between -1.0 and 0.0 (off-screen left to on-screen)
    _animation = Tween<Offset>(
      begin: const Offset(-2, 1),
      end: const Offset(1.1, -1.0),
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeIn
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SlideTransition(
          position: _animation,
          child: Transform.rotate(
            angle: 0.7,
            child: Icon(
              Icons.airplanemode_active_rounded,
              size: constraints.maxHeight * 1.5,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

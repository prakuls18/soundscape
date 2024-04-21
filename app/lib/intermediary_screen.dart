import 'package:flutter/material.dart';
import 'dart:async';
import 'music_screen.dart';
import 'dart:math' as math;

class IntermediaryScreen extends StatefulWidget {
  @override
  _IntermediaryScreenState createState() => _IntermediaryScreenState();
}

class _IntermediaryScreenState extends State<IntermediaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    startTimer();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _animation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 1),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 0),
          weight: 1,
        ),
      ],
    ).animate(_animationController);
  }

  startTimer() async {
    var duration = Duration(seconds: 10);
    return Timer(duration, navigateToMusicScreen);
  }

  navigateToMusicScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => MusicScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.8,
              colors: [
                Color.lerp(Color.fromARGB(255, 204, 127, 121),
                    Color.fromARGB(255, 172, 172, 172), _animation.value)!,
                Color.lerp(Color.fromARGB(255, 160, 160, 160),
                    Color.fromRGBO(118, 174, 199, 1), _animation.value)!,
                Color.lerp(Color.fromARGB(255, 111, 92, 192)!,
                    Color.fromARGB(255, 175, 175, 175), _animation.value)!,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 310,
                      height: 310,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.7),
                            blurRadius: 40,
                            spreadRadius: -15 -
                                30 *
                                    math.sin(_animationController.value *
                                        2 *
                                        math.pi),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Center(
                  child: Text(
                    'Take a deep breath... \n \n Look around you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'ProductSans',
                      fontStyle: FontStyle.italic,
                      color: const Color.fromARGB(255, 47, 47, 47),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

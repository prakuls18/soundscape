import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _wavyAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
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

    _wavyAnimationController = AnimationController(
      duration: const Duration(seconds: 1), // Increased frequency
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _wavyAnimationController.dispose();
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
                Color.lerp(Colors.red, Colors.white, _animation.value)!,
                Color.lerp(Colors.white, Colors.lightBlue, _animation.value)!,
                Color.lerp(
                    Colors.deepPurpleAccent, Colors.white, _animation.value)!,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _wavyAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(0, 0, 0, 0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: -10 -
                                  10 *
                                      math.sin(_wavyAnimationController.value *
                                          2 *
                                          math.pi), // Increased amplitude
                            ),
                          ],
                        ),
                        child: MiniMusicVisualizer(
                          color: Color.fromARGB(255, 163, 217, 165),
                          width: 50,
                          height: 200,
                          radius: 10,
                          animate: true,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 70,
                  left: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 50,
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

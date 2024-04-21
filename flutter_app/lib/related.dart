import 'package:flutter/material.dart';

class Related extends StatefulWidget {
  const Related({Key? key}) : super(key: key);

  @override
  State<Related> createState() => _RelatedState();
}

class _RelatedState extends State<Related> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
                Color.lerp(Color(0xFF2774AE), Colors.white, _animation.value)!,
                Color.lerp(Colors.white, Color.fromARGB(255, 255, 209, 110),
                    _animation.value)!,
                Color.lerp(Color(0xFF003B5C), Colors.white, _animation.value)!,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Image.asset('assets/logo.png', width: 32, height: 32),
                ),
              ],
              title: Text(
                'Recommended Tracks',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Here\'s some tracks for you:',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSongItem('I Wanna Be Yours', 'Arctic Monkeys',
                            'Indie Rock', '3:04'),
                        _buildSongItem('This Charming Man ', 'The Smiths',
                            'Alt Brit Rock, 80s', '2:41'),
                        _buildSongItem('Cigarette Daydreams',
                            'Cage The Elephant', 'Indie Rock', '3:28'),
                        // Add more song items as needed
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongItem(
      String name, String artist, String genre, String length) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        '$artist - $genre',
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      trailing: Text(
        length,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

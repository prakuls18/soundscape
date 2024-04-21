import 'package:flutter/material.dart';
import 'intermediary_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundscape',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Soundscape Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPressed = false;
  bool _isAnimated = false;

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

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
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
                  Color.lerp(Color.fromARGB(255, 248, 108, 98), Colors.white,
                      _animation.value)!,
                  Color.lerp(Colors.white, Color.fromRGBO(91, 203, 255, 1),
                      _animation.value)!,
                  Color.lerp(
                      Colors.deepPurpleAccent, Colors.white, _animation.value)!,
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _isAnimated ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 600),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          transform: Matrix4.translationValues(
                              0, _isAnimated ? 0 : -20, 0),
                          child: Text(
                            'Soundscape',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _isAnimated ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 600),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          transform: Matrix4.translationValues(
                              0, _isAnimated ? 0 : -20, 0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isPressed = true;
                              });
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                setState(() {
                                  _isPressed = false;
                                });
                              });
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(
                                      milliseconds:
                                          800), // Adjust the duration as needed
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      IntermediaryScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(0.0,
                                        1.0); // Start from the bottom of the screen
                                    var end = Offset
                                        .zero; // End at the center of the screen
                                    var curve = Curves
                                        .ease; // Adjust the curve as needed
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: _isPressed
                                  ? MediaQuery.of(context).size.width *
                                      0.55 // Expanded to 110% (0.5 * 1.1)
                                  : MediaQuery.of(context).size.width * 0.5,
                              height: _isPressed
                                  ? MediaQuery.of(context).size.width *
                                      0.54 // Expanded to 110% (0.5 * 1.1)
                                  : MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(200, 255, 255, 255),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/logo.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _isAnimated ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 600),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          transform: Matrix4.translationValues(
                              0, _isAnimated ? 0 : -20, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                0.8, // 80% of the screen width
                            child: const Text(
                              'Tap here for real-time, immersive, generative musical environments.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                      AnimatedOpacity(
                        opacity: _isAnimated ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 600),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          transform: Matrix4.translationValues(
                              0, _isAnimated ? 0 : -20, 0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isPressed = true;
                              });
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                setState(() {
                                  _isPressed = false;
                                });
                              });
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: _isPressed
                                  ? MediaQuery.of(context).size.width * 0.65
                                  : MediaQuery.of(context).size.width * 0.6,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF1DB954),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Link to Spotify (optional)',
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 7, 7, 7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}

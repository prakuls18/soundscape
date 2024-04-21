import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'related.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class LocationService {
  final Location location = Location();

  Future<LocationData?> getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Inform the user that location services are necessary
        return null;
      }
    }

    // Check for location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Inform the user that permissions are necessary
        return null;
      }
    }

    // Try getting the location
    try {
      locationData = await location.getLocation();
    } catch (e) {
      print('Failed to get location: $e');
      return null;
    }

    return locationData;
  }
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _wavyAnimationController;

  Timer? timer;
  bool isActive = true; // flag

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
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    checkServerConnectivity("192.168.61.134");

    startPeriodic();
  }

  Future<void> checkServerConnectivity(String serverIP) async {
    var url = Uri.parse('http://$serverIP:4000/api/location');

    print('Trying to connect to server');

    try {
      var response = await http.post(url);
      if (response.statusCode == 200) {
        print('Successfully connected to $serverIP');
        print('Response: ${response.body}');
      } else {
        print(
            'Failed to connect to $serverIP, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error connecting to $serverIP: $e');
    }
  }

  void startPeriodic() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      if (isActive) {
        try {
          var data = await LocationService().getLocation();
          if (data != null) {
            print(data);
          } else {
            print("No location data received.");
          }

          var dio = Dio();

          var response = await dio.post(
            'http://192.168.61.134:4000/api/location',
            data: {
              'latitude': data?.latitude.toString(),
              'longitude': data?.longitude.toString(),
              'radius': '10.0',
            },
          );
          print(response);
          if (mounted) {
            setState(() {
              print("hi");
            });
          }
        } catch (error) {
          print('Error loading data: $error');
          // Optionally, cancel the timer if a fatal error occurs
          // timer.cancel();
        }
      } else {
        timer.cancel(); // Stop the timer
        print("Timer canceled.");
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _wavyAnimationController.dispose();
    // timer?.cancel();
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
                'Player',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            body: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 0,
                  right: 0,
                  child: Center(
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
                                blurRadius: 18,
                                spreadRadius: -10 -
                                    10 *
                                        math.sin(
                                            _wavyAnimationController.value *
                                                2 *
                                                math.pi), // Increased amplitude
                              ),
                            ],
                          ),
                          child: MiniMusicVisualizer(
                            color: Color.fromARGB(117, 181, 181, 181),
                            width: 40,
                            height: 180,
                            animate: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(
                                milliseconds:
                                    800), // Adjust the duration as needed
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    Related(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0,
                                  0.0); // Start from the right side of the screen
                              var end = Offset
                                  .zero; // End at the center of the screen
                              var curve =
                                  Curves.ease; // Adjust the curve as needed
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
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.8), // Adjust the opacity as needed
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          'See related tracks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height *
                      0.7, // Adjusted top value
                  left: MediaQuery.of(context).size.width * 0.125,
                  right: MediaQuery.of(context).size.width * 0.125,
                  child: GestureDetector(
                    onTap: () {
                      isActive = false;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.8), // Adjust the opacity as needed
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Stop playback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

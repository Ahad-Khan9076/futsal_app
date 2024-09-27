import 'package:flutter/material.dart';
import 'dart:async';

import 'intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // Navigate to intro screen after 4 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300, // Adjust height
              width: 300,  // Adjust width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(5, 5),
                  )
                ],
              ),
              clipBehavior: Clip.hardEdge, // Ensures the image stays within the rounded corners
              child: Image.asset(
                'assets/splashscreen.jpg',
                fit: BoxFit.cover, // Options: cover, contain, fill, etc.
              ),
            ),
            const SizedBox(height: 20),

            // Text with background decoration
            Stack(
              children: [
                // Background decoration behind text
                Container(
                  height: 60,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: const Text(
                      'FUTSAL ARENA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // More attractive circular progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
                  strokeWidth: 6.0, // Thicker stroke width
                  backgroundColor: Colors.black.withOpacity(0.2),
                ),
                const Icon(
                  Icons.sports_soccer,
                  color: Colors.black, // Add an icon in the middle for an attractive effect
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


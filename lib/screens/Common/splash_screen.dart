import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'signup.dart';
import '../Athlete/AthleteDashboardPage.dart';
import '../Coach/CoachDashboardPage.dart';
import '../Organization/OrganizationDashboardPage.dart';
import '../Cardiologist/CardiologistDashboardPage.dart';
import '../Dietitian/DietitianDashboardPage.dart';
import '../Physician/PhysicianDashboardPage.dart';
import '../Psychologist/PsychologistDashboardPage.dart';

void main() {
  runApp(const AthleticsApp());
}

class AthleticsApp extends StatelessWidget {
  const AthleticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showTextAndButton = false; // To show the text and button after the animation
  double _logoMargin = 0.0; // Variable to dynamically change the margin for the logo
  final Color buttonColor = Colors.green; // Color for the button and circles

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Animation duration set to 4 seconds
      vsync: this,
    )..forward(); // Start the animation

    // After 4 seconds, stop the animation and show the text and button
    Timer(const Duration(seconds: 4), () {
      setState(() {
        _showTextAndButton = true;
        _logoMargin = 20.0; // Set margin to move logo down after animation (reduced from 40)
      });
    });
  }

  Future<void> _navigateBasedOnProfession(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch the user's data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String profession = userData['profession'] ?? '';
          String specialization = userData['specialization'] ?? '';

          // Navigate to the respective dashboard based on profession
          if (profession == 'Athlete') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AthleteDashboardPage()),
            );
          } else if (profession == 'Coach') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CoachDashboardPage()),
            );
          } else if (profession == 'Organization') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OrganizationDashboardPage()),
            );
          } else if (profession == 'Doctor') {
            // Handle navigation for Doctor based on specialization
            if (specialization == 'Dietitian') {
              // Navigate to a Dietitian dashboard (create this page if needed)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DietitianDashboardPage()),
              );
            } else if (specialization == 'Psychologist') {
              // Navigate to a Psychologist dashboard (create this page if needed)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PsychologistDashboardPage()),
              );
            } else if (specialization == 'Physician') {
              // Navigate to a Physician dashboard (create this page if needed)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhysicianDashboardPage()),
              );
            } else if (specialization == 'Cardiologist') {
              // Navigate to a Cardiologist dashboard (create this page if needed)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CardiologistDashboardPage()),
              );
            } else {
              // Default to signup if specialization is not found
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            }
          } else {
            // If profession is not found, default to signup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          }
        } else {
          // If user document doesn't exist, navigate to signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }
      } catch (e) {
        // Handle Firestore errors (e.g., no internet)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      }
    } else {
      // If no user is logged in, navigate to signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stack for positioning the logo and rotating circles on top
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated circles - only show during animation
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return _showTextAndButton
                          ? SizedBox.shrink() // Hide circles after 4 seconds
                          : CustomPaint(
                        size: const Size(150, 150),
                        painter: CirclePainter(_controller.value, buttonColor),
                      );
                    },
                  ),
                  // Conditional check for the splash icon
                  Image.asset(
                    _showTextAndButton
                        ? 'assets/splashicon2.png' // Show splashicon2 after animation
                        : 'assets/splashicon1.png', // Show splashicon1 during animation
                    width: 100, // Decreased size of the icon
                    height: 100, // Decreased size of the icon
                  ),
                ],
              ),
              SizedBox(height: 20), // Reduced gap between logo and text
              if (_showTextAndButton)
                Column(
                  children: [
                    Text(
                      'Welcome to Athletix',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: buttonColor, // Set text color to button color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20), // Space between text and button
                    ElevatedButton(
                      onPressed: () => _navigateBasedOnProfession(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        backgroundColor: buttonColor,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white, // Set button text color to white
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double animationValue; // Value from the animation controller (0 to 1)
  final Color circleColor;

  CirclePainter(this.animationValue, this.circleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = circleColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Number of circles
    int numCircles = 3;

    // Circles should start at the center, then move to their final positions as animation progresses
    for (int i = 0; i < numCircles; i++) {
      // Angle to position the circles initially around the center
      double angle = 2 * pi * (i / numCircles);

      // As the animation progresses, the circles move outward and rotate around the center
      double adjustedAngle = angle + (animationValue * 2 * pi);

      // Calculate the circle's position
      final offset = Offset(
        center.dx + radius * cos(adjustedAngle),
        center.dy + radius * sin(adjustedAngle),
      );

      // Draw each circle in its updated position
      canvas.drawCircle(offset, 10, paint);
    }

    // After 75% of the animation time, move the circles back to the center
    if (animationValue > 0.75) {
      // Return circles to center as animation nears completion
      for (int i = 0; i < numCircles; i++) {
        canvas.drawCircle(center, 10, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
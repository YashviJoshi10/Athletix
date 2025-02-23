import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'signup.dart';
import '../Athlete/athlete_dashboard_page.dart';
import '../Coach/coach_dashboard_page.dart';
import '../Organization/organization_dashboard_page.dart';
import '../Cardiologist/cardiologist_dashboard_page.dart';
import '../Dietitian/dietitian_dashboard_page.dart';
import '../Physician/physician_dashboard_page.dart';
import '../Psychologist/psychologist_dashboard_page.dart';

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
  bool _showTextAndButton = false;
  double _logoMargin = 0.0;
  final Color buttonColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showTextAndButton = true;
          _logoMargin = 20.0;
        });
      }
    });
  }

  Future<void> _navigateBasedOnProfession(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String profession = userData['profession'] ?? '';

          // Ensure widget is mounted before using context
          if (mounted) {
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
            } else if (profession == 'Dietitian') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DietitianDashboardPage()),
              );
            } else if (profession == 'Psychologist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PsychologistDashboardPage()),
              );
            } else if (profession == 'Physician') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhysicianDashboardPage()),
              );
            } else if (profession == 'Cardiologist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CardiologistDashboardPage()),
              );
            }
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            }
          }
        } else {
          // Check if widget is mounted before using context
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data: $e')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      }
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
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return _showTextAndButton
                          ? SizedBox.shrink()
                          : CustomPaint(
                        size: const Size(150, 150),
                        painter: CirclePainter(_controller.value, buttonColor),
                      );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: _logoMargin),
                    child: Image.asset(
                      _showTextAndButton
                          ? 'assets/splashicon2.png'
                          : 'assets/splashicon1.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_showTextAndButton)
                Column(
                  children: [
                    Text(
                      'Welcome to Athletix',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          color: Colors.white,
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
  final double animationValue;
  final Color circleColor;

  CirclePainter(this.animationValue, this.circleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = circleColor.withValues(alpha: circleColor.alpha * 0.5) // Keep alpha as double
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    int numCircles = 3;

    for (int i = 0; i < numCircles; i++) {
      double angle = 2 * pi * (i / numCircles);
      double adjustedAngle = angle + (animationValue * 2 * pi);

      final offset = Offset(
        center.dx + radius * cos(adjustedAngle),
        center.dy + radius * sin(adjustedAngle),
      );

      canvas.drawCircle(offset, 10, paint);
    }

    if (animationValue > 0.75) {
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
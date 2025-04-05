import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
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

class _SplashScreenState extends State<SplashScreen> {
  final Color buttonColor = Colors.green;

  // Remove the automatic navigation from initState

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
            } else {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.greenAccent], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Directly display the logo without animation
              Container(
                child: Image.asset(
                  'assets/splashicon1.png', // Use the default logo
                  width: 150, // Logo size
                  height: 150,
                ),
              ),
              SizedBox(height: 40), // Increased spacing
              // Display text and button after logo
              Column(
                children: [
                  Text(
                    'Welcome to Athletix',
                    style: TextStyle(
                      fontSize: 30.0, // Larger font size
                      color: Colors.white, // White text color
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // Increased space between text and button
                  ElevatedButton(
                    onPressed: () => _navigateBasedOnProfession(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Bigger button padding
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 20,
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

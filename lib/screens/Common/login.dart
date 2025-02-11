import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/Athlete/AthleteDashboardPage.dart';
import 'package:myapp/screens/Coach/CoachDashboardPage.dart';
import 'package:myapp/screens/Organization/OrganizationDashboardPage.dart';
import 'package:myapp/screens/Common/signup.dart';
import 'package:myapp/screens/Physician/PhysicianDashboardPage.dart';
import 'package:myapp/screens/Dietitian/DietitianDashboardPage.dart';
import 'package:myapp/screens/Psychologist/PsychologistDashboardPage.dart';
import 'package:myapp/screens/Cardiologist/CardiologistDashboardPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to login the user
  Future<void> _login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if the email is verified
      if (userCredential.user!.emailVerified) {
        // Fetch the user's profession from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String profession = userDoc.get('profession'); // Fetch profession

          // Redirect based on profession
          if (profession == 'Athlete') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AthleteDashboardPage()),
            );
          } else if (profession == 'Coach') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CoachDashboardPage()),
            );
          } else if (profession == 'Organization') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrganizationDashboardPage()),
            );
          } else if (profession == 'Doctor') {
            // Fetch specialization for doctors
            String specialization = userDoc.get('specialization');

            if (specialization == 'Physician') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhysicianDashboardPage()),
              );
            } else if (specialization == 'Dietitian') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DietitianDashboardPage()),
              );
            } else if (specialization == 'Psychologist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PsychologistDashboardPage()),
              );
            } else if (specialization == 'Cardiologist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CardiologistDashboardPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unknown specialization: $specialization')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown profession: $profession')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data not found in Firestore')),
          );
        }
      } else {
        // Show message to verify email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email address before logging in.')),
        );
        // Optionally, resend the verification email
        await userCredential.user!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: true, // Ensure layout adjusts when keyboard appears
      body: SingleChildScrollView( // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Circular Logo
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/applogo.png'), // Replace with your logo asset
              ),
              SizedBox(height: 20),
              // App Name or Tagline
              Text(
                'Athletix',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40), // Space between name and email field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

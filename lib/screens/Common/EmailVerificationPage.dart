import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // Import your login screen

class EmailVerificationPage extends StatelessWidget {
  final String email;

  // Constructor to receive the email
  const EmailVerificationPage({super.key, required this.email});

  // This is the method that will be used to send the verification email again
  Future<void> _sendVerificationEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        // Show the snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent to $email')),
        );
      }
    } catch (e) {
      // Show the snack bar for error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email verification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We have sent a verification email to $email.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendVerificationEmail(context), // Pass context to the method
              child: Text('Resend Verification Email'),
            ),
            SizedBox(height: 20), // Add space between buttons
            TextButton(
              onPressed: () {
                // Navigate to the LoginScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your LoginScreen
                );
              },
              child: Text('Login', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

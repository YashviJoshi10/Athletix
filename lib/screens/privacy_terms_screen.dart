import 'package:flutter/material.dart';
// This screen displays the privacy policy and terms of service for the Athletix app.

class PrivacyTermsPage extends StatelessWidget {
  const PrivacyTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth < 600 ? 16.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy & Terms',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('''
At Athletix, we respect your privacy. This policy applies to all users, including Athletes, Coaches, Doctors, and Organizations.

- We collect personal and professional information to enhance your experience.
- Your data is shared only with authorized individuals in your role's ecosystem.
- We do not sell your data to third parties.
- You may request deletion of your data at any time.
                      ''', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 32),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('''
By using Athletix, you agree to:

1. Provide accurate registration and profile information.
2. Use the platform respectfully and responsibly.
3. Not misuse access to other users' data or communication tools.
4. Accept that Athletix is not liable for any misuse of health or performance data.

Each role (Athlete, Coach, Doctor, Organization) must adhere to guidelines specific to their access and responsibilities.
                      ''', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

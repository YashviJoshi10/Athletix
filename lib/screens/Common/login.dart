import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/Athlete/athlete_dashboard_page.dart';
import 'package:myapp/screens/Coach/coach_dashboard_page.dart';
import 'package:myapp/screens/Organization/organization_dashboard_page.dart';
import 'package:myapp/screens/Common/signup.dart';
import 'package:myapp/screens/Physician/physician_dashboard_page.dart';
import 'package:myapp/screens/Dietitian/dietitian_dashboard_page.dart';
import 'package:myapp/screens/Psychologist/psychologist_dashboard_page.dart';
import 'package:myapp/screens/Cardiologist/cardiologist_dashboard_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user!.emailVerified) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String profession = userDoc.get('profession');

          switch (profession) {
            case 'Athlete':
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AthleteDashboardPage()));
              break;
            case 'Coach':
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CoachDashboardPage()));
              break;
            case 'Organization':
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrganizationDashboardPage()));
              break;
            case 'Doctor':
              String specialization = userDoc.get('specialization');
              switch (specialization) {
                case 'Physician':
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhysicianDashboardPage()));
                  break;
                case 'Dietitian':
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DietitianDashboardPage()));
                  break;
                case 'Psychologist':
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PsychologistDashboardPage()));
                  break;
                case 'Cardiologist':
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CardiologistDashboardPage()));
                  break;
                default:
                  _showError('Unknown specialization: $specialization');
              }
              break;
            default:
              _showError('Unknown profession: $profession');
          }
        } else {
          _showError('User data not found in Firestore');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email address before logging in.')),
        );
        await userCredential.user!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/applogo.png'),
              ),
              SizedBox(height: 16),
              Text(
                'Athletix',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text('Login', style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Text('Create an account', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, IconData? icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}

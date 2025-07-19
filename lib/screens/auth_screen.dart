import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  String email = '', password = '';
  String name = '', sport = '';
  DateTime? dob;

  void submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || (!isLogin && dob == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    _formKey.currentState?.save();

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save profile in Firestore
        await FirebaseFirestore.instance
            .collection('athletes')
            .doc(cred.user!.uid)
            .set({
          'name': name,
          'sport': sport,
          'dob': dob!.toIso8601String(),
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Signup')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (!isLogin)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter your name'
                        : null,
                    onSaved: (val) => name = val ?? '',
                  ),
                if (!isLogin)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sport'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter your sport'
                        : null,
                    onSaved: (val) => sport = val ?? '',
                  ),
                if (!isLogin)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dob == null
                              ? 'Select Date of Birth'
                              : 'DOB: ${dob!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dob = picked;
                            });
                          }
                        },
                        child: const Text('Pick Date'),
                      )
                    ],
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
                  onSaved: (val) => email = val ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6
                      ? 'Minimum 6 characters'
                      : null,
                  onSaved: (val) => password = val ?? '',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submit,
                  child: Text(isLogin ? 'Login' : 'Signup'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin
                      ? 'New here? Signup'
                      : 'Already registered? Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

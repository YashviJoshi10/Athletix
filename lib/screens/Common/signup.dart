import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'EmailVerificationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  String? _selectedProfession;
  String? _selectedSport;
  String? _selectedSpecialization;

  List<String> professions = ['Athlete', 'Coach', 'Organization', 'Doctor'];
  List<String> sports = [
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Swimming',
    'Gymnastics',
    'Cycling',
    'Rugby',
    'Boxing'
  ];
  List<String> doctorSpecializations = [
    'Physician',
    'Dietitian',
    'Psychologist',
    'Cardiologist'
  ];

  DateTime? _selectedDate;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'dob': _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : '',
        'profession': _selectedProfession,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      };

      // Add profession-specific fields
      if (_selectedProfession == 'Athlete' || _selectedProfession == 'Coach') {
        userData['sport'] = _selectedSport;
      } else if (_selectedProfession == 'Doctor') {
        userData['specialization'] = _selectedSpecialization;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      await userCredential.user!.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(email: _emailController.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign-up failed')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), automaticallyImplyLeading: false),
      body: Stack(
        children: [
          Opacity(
            opacity: _isLoading ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/applogo.png'),
                    ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Athletix',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 40),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobController,
                        decoration: InputDecoration(labelText: 'Date of Birth'),
                        readOnly: true,
                      ),
                    ),
                  ),

                  DropdownButtonFormField<String>(
                    value: _selectedProfession,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProfession = newValue;
                        _selectedSport = null;
                        _selectedSpecialization = null;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Profession'),
                    items: professions.map((profession) {
                      return DropdownMenuItem(
                        value: profession,
                        child: Text(profession),
                      );
                    }).toList(),
                    hint: Text('Select Profession'),
                  ),

                  // Show Sport Dropdown only if profession is Athlete or Coach
                  if (_selectedProfession == 'Athlete' || _selectedProfession == 'Coach')
                    DropdownButtonFormField<String>(
                      value: _selectedSport,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSport = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Sport'),
                      items: sports.map((sport) {
                        return DropdownMenuItem(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      hint: Text('Select Sport'),
                    ),

                  // Show Specialization Dropdown only if profession is Doctor
                  if (_selectedProfession == 'Doctor')
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialization,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSpecialization = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Specialization'),
                      items: doctorSpecializations.map((specialization) {
                        return DropdownMenuItem(
                          value: specialization,
                          child: Text(specialization),
                        );
                      }).toList(),
                      hint: Text('Select Specialization'),
                    ),

                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),

                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),

                  ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up'),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

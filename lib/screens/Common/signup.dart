import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'email_verification_page.dart';
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
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
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
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Full Name Input
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Date of Birth
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Profession Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedProfession,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProfession = newValue;
                        _selectedSport = null;
                        _selectedSpecialization = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Profession',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: professions.map((profession) {
                      return DropdownMenuItem(
                        value: profession,
                        child: Text(profession),
                      );
                    }).toList(),
                    hint: Text('Select Profession'),
                  ),
                  SizedBox(height: 12),

                  // Sport Dropdown (only if applicable)
                  if (_selectedProfession == 'Athlete' || _selectedProfession == 'Coach')
                    DropdownButtonFormField<String>(
                      value: _selectedSport,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSport = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Sport',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.sports),
                      ),
                      items: sports.map((sport) {
                        return DropdownMenuItem(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      hint: Text('Select Sport'),
                    ),
                  SizedBox(height: 12),

                  // Specialization Dropdown (only if Doctor)
                  if (_selectedProfession == 'Doctor')
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialization,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSpecialization = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: doctorSpecializations.map((specialization) {
                        return DropdownMenuItem(
                          value: specialization,
                          child: Text(specialization),
                        );
                      }).toList(),
                      hint: Text('Select Specialization'),
                    ),
                  SizedBox(height: 12),

                  // Phone Number Input
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Login Link
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

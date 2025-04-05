import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Athlete/add_doctors.dart'; // Import the AddDoctors page

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "";
  String _dob = "";
  String _userPhone = "";
  String _userEmail = "";
  String _userProfession = "";
  String _userId = ""; // Declare the userId

  // Function to fetch user details from Firestore
  Future<void> _fetchUserDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Using UID to fetch user document
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? 'N/A';
            _dob = userDoc['dob'] ?? 'N/A';
            _userPhone = userDoc['phone'] ?? 'N/A';
            _userEmail = user.email ?? 'N/A';
            _userProfession = userDoc['profession'] ?? 'N/A';
            _userId = user.uid; // Set the userId
          });
        } else {
          print("User document does not exist");
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    } else {
      print("User is not authenticated");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch the user details when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue, // AppBar color
      ),
      backgroundColor: Colors.grey[100], // Set background color for the page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _userName.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.blue),
                        title: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(_userName),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.blue),
                        title: Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(_dob),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.blue),
                        title: Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(_userPhone),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.blue),
                        title: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(_userEmail),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.work, color: Colors.blue),
                        title: Text(
                          'Profession',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(_userProfession),
                      ),
                    ],
                  ),
                ),
              ),

              // Show the "Add Doctors" button ONLY for Athletes
              if (_userProfession == "Athlete") ...[
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Pass the userId when navigating to AddDoctorsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDoctorsPage(userId: _userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Add Doctors',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

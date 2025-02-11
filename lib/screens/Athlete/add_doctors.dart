import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'show_doctors.dart'; // Import the ShowDoctorsPage

class AddDoctorsPage extends StatefulWidget {
  final String userId; // Add userId as a parameter

  AddDoctorsPage({required this.userId}); // Constructor to accept userId

  @override
  _AddDoctorsState createState() => _AddDoctorsState();
}

class _AddDoctorsState extends State<AddDoctorsPage> {
  // List of specializations for doctors
  final List<String> _specializations = ['Physician', 'Dietitian', 'Psychologist', 'Cardiologist'];
  Map<String, String> _connectedDoctors = {}; // Map to store connected doctors' names

  @override
  void initState() {
    super.initState();
    _fetchConnectedDoctors();
  }

  // Function to fetch the connected doctors for the current user
  Future<void> _fetchConnectedDoctors() async {
    try {
      // Query the connections collection for accepted connections where the user has sent the request
      final querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('userId', isEqualTo: widget.userId) // Check if the logged-in user is the sender
          .where('status', isEqualTo: 'connected')  // Only fetch connections that are connected
          .get();

      Map<String, String> connectedDoctors = {};

      // Loop through each connection document
      for (var doc in querySnapshot.docs) {
        // Get the doctorId from the connection document
        String doctorId = doc['doctorId'];

        // Fetch doctor details from the users collection using doctorId
        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)  // Using doctorId as UID
            .get();

        // Check if the doctor document exists
        if (doctorSnapshot.exists) {
          // Retrieve the name and specialization from the doctor document
          String doctorName = doctorSnapshot['name'] ?? 'Unknown Doctor';
          String specialization = doctorSnapshot['specialization'] ?? 'Unknown Specialization';

          // Store the doctor's name under the specialization
          connectedDoctors[specialization] = doctorName;
        }
      }

      // Update the UI with the connected doctors
      setState(() {
        _connectedDoctors = connectedDoctors;
      });
    } catch (e) {
      print("Error fetching connected doctors: $e");
    }
  }

  // Function to navigate to ShowDoctors page with selected specialization
  void _navigateToShowDoctors(String specialization) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowDoctorsPage(
          profession: specialization,
          userId: widget.userId,  // Pass userId here
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Doctors'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _specializations.length,
          itemBuilder: (context, index) {
            String specialization = _specializations[index];
            // Get the doctor's name if connected, otherwise show an empty string
            String doctorName = _connectedDoctors[specialization] ?? '';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  specialization,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: doctorName.isEmpty
                    ? Text('No doctor connected', style: TextStyle(color: Colors.red))
                    : Text('Connected with: $doctorName', style: TextStyle(color: Colors.green)),
                trailing: Icon(Icons.arrow_forward),
                onTap: () => _navigateToShowDoctors(specialization), // Always navigate to ShowDoctorsPage
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'show_doctors.dart'; // Ensure ShowDoctorsPage is public (without an underscore)

class AddDoctorsPage extends StatefulWidget {
  final String userId;

  // Using super(key) as per the suggestion
  const AddDoctorsPage({super.key, required this.userId});

  @override
  AddDoctorsState createState() => AddDoctorsState(); // Change _AddDoctorsState to AddDoctorsState
}

class AddDoctorsState extends State<AddDoctorsPage> {  // Changed to public class
  final List<String> _specializations = ['Physician', 'Dietitian', 'Psychologist', 'Cardiologist'];
  Map<String, String> _connectedDoctors = {};

  @override
  void initState() {
    super.initState();
    _fetchConnectedDoctors();
  }

  Future<void> _fetchConnectedDoctors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('userId', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'connected')
          .get();

      Map<String, String> connectedDoctors = {};

      for (var doc in querySnapshot.docs) {
        String doctorId = doc['doctorId'];

        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .get();

        if (doctorSnapshot.exists) {
          String doctorName = doctorSnapshot['name'] ?? 'Unknown Doctor';
          String specialization = doctorSnapshot['specialization'] ?? 'Unknown Specialization';

          connectedDoctors[specialization] = doctorName;
        }
      }

      setState(() {
        _connectedDoctors = connectedDoctors;
      });
    } catch (e) {
      debugPrint("Error fetching connected doctors: $e");
    }
  }

  void _navigateToShowDoctors(String specialization) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowDoctorsPage(
          profession: specialization,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Doctors'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _specializations.length,
          itemBuilder: (context, index) {
            String specialization = _specializations[index];
            String doctorName = _connectedDoctors[specialization] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  specialization,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: doctorName.isEmpty
                    ? const Text('No doctor connected', style: TextStyle(color: Colors.red))
                    : Text('Connected with: $doctorName', style: const TextStyle(color: Colors.green)),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => _navigateToShowDoctors(specialization),
              ),
            );
          },
        ),
      ),
    );
  }
}

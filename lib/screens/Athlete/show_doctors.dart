import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DoctorProfile.dart';

class ShowDoctorsPage extends StatefulWidget {
  final String profession;
  final String userId;  // Add userId to pass to the DoctorProfilePage

  ShowDoctorsPage({required this.profession, required this.userId});

  @override
  _ShowDoctorsPageState createState() => _ShowDoctorsPageState();
}

class _ShowDoctorsPageState extends State<ShowDoctorsPage> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;

  Future<void> _fetchDoctors() async {
    try {
      print("Fetching doctors for specialization: ${widget.profession}");
      String profession = widget.profession.trim();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('specialization', isEqualTo: profession)
          .get();

      print("Found ${querySnapshot.docs.length} doctors for specialization: ${widget.profession}");

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _doctors = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'],
              'specialization': doc['specialization'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _doctors = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching doctors: $e");
      setState(() {
        _doctors = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} Doctors'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _doctors.isEmpty
            ? Center(child: Text("No doctors found for this specialization."))
            : ListView.builder(
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  _doctors[index]['name'],
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  // Navigate to DoctorProfilePage with doctorId and userId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfilePage(
                        doctorId: _doctors[index]['id'],
                        userId: widget.userId, // Passing userId here
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

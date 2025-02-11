import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;
  final String userId;  // Add userId to the constructor

  DoctorProfilePage({required this.doctorId, required this.userId});

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  Map<String, dynamic>? _doctorDetails;
  bool _isLoading = true;
  String? _connectionStatus; // Track the connection status

  Future<void> _fetchDoctorDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _doctorDetails = docSnapshot.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Doctor not found");
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check if a connection request already exists for this user and doctor
  Future<void> _checkConnectionStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _connectionStatus = null; // No request, so show Connect button
        });
      } else {
        DocumentSnapshot existingRequest = querySnapshot.docs.first;
        String currentStatus = existingRequest['status'];

        setState(() {
          _connectionStatus = currentStatus;
        });
      }
    } catch (e) {
      print("Error checking connection status: $e");
    }
  }

  // Handle sending or updating the connection request
  Future<void> _handleConnectionRequest() async {
    try {
      if (_connectionStatus == null) {
        // No existing request, send a new one
        await FirebaseFirestore.instance.collection('connections').add({
          'doctorId': widget.doctorId,
          'userId': widget.userId,
          'status': 'pending', // status is 'pending' initially
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _connectionStatus = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection request sent to the doctor!')),
        );
      } else {
        // Handle different statuses
        DocumentSnapshot existingRequest = (await FirebaseFirestore.instance
            .collection('connections')
            .where('doctorId', isEqualTo: widget.doctorId)
            .where('userId', isEqualTo: widget.userId)
            .get())
            .docs
            .first;

        if (_connectionStatus == 'pending') {
          // If the request is pending, update to 'pending'
          await FirebaseFirestore.instance
              .collection('connections')
              .doc(existingRequest.id)
              .update({'status': 'pending'});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connection request is pending!')),
          );
        } else if (_connectionStatus == 'accepted') {
          // If the request is accepted, change status to 'connected'
          await FirebaseFirestore.instance
              .collection('connections')
              .doc(existingRequest.id)
              .update({'status': 'connected'});

          setState(() {
            _connectionStatus = 'connected';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are now connected to the doctor!')),
          );
        }
      }
    } catch (e) {
      print("Error handling connection request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to handle connection request.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
    _checkConnectionStatus(); // Check connection status when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _doctorDetails == null
            ? Center(child: Text("No doctor details available."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _doctorDetails!['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Specialization: ${_doctorDetails!['specialization']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Contact: ${_doctorDetails!['phone']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleConnectionRequest,
              child: Text(
                _connectionStatus == null
                    ? 'Connect'
                    : _connectionStatus == 'pending'
                    ? 'Pending'
                    : 'Connected',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _connectionStatus == 'connected'
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

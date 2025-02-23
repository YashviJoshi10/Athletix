import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const DoctorProfilePage({Key? key, required this.doctorId, required this.userId}) : super(key: key);

  @override
  DoctorProfilePageState createState() => DoctorProfilePageState();
}

class DoctorProfilePageState extends State<DoctorProfilePage> {
  Map<String, dynamic>? _doctorDetails;
  bool _isLoading = true;
  String? _connectionStatus;

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
        debugPrint("Doctor not found");
      }
    } catch (e) {
      debugPrint("Error fetching doctor details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _connectionStatus = null;
        });
      } else {
        DocumentSnapshot existingRequest = querySnapshot.docs.first;
        String currentStatus = existingRequest['status'];

        setState(() {
          _connectionStatus = currentStatus;
        });
      }
    } catch (e) {
      debugPrint("Error checking connection status: $e");
    }
  }

  Future<void> _handleConnectionRequest() async {
    try {
      if (_connectionStatus == null) {
        await FirebaseFirestore.instance.collection('connections').add({
          'doctorId': widget.doctorId,
          'userId': widget.userId,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _connectionStatus = 'pending';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connection request sent to the doctor!')),
          );
        }
      } else {
        DocumentSnapshot existingRequest = (await FirebaseFirestore.instance
            .collection('connections')
            .where('doctorId', isEqualTo: widget.doctorId)
            .where('userId', isEqualTo: widget.userId)
            .get())
            .docs
            .first;

        if (_connectionStatus == 'pending') {
          await FirebaseFirestore.instance
              .collection('connections')
              .doc(existingRequest.id)
              .update({'status': 'pending'});

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Connection request is pending!')),
            );
          }
        } else if (_connectionStatus == 'accepted') {
          await FirebaseFirestore.instance
              .collection('connections')
              .doc(existingRequest.id)
              .update({'status': 'connected'});

          setState(() {
            _connectionStatus = 'connected';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You are now connected to the doctor!')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error handling connection request: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to handle connection request.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
    _checkConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _doctorDetails == null
            ? const Center(child: Text("No doctor details available."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _doctorDetails!['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Specialization: ${_doctorDetails!['specialization']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Contact: ${_doctorDetails!['phone']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
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

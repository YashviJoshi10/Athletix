import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'show_injuries.dart';

class AddInjuryPage extends StatefulWidget {
  const AddInjuryPage({super.key});

  @override
  _AddInjuryPageState createState() => _AddInjuryPageState();
}

class _AddInjuryPageState extends State<AddInjuryPage> {
  List<TextEditingController> _injuryDescriptionList = [];
  TextEditingController _injuryDateController = TextEditingController();
  String? _userUid;

  @override
  void initState() {
    super.initState();
    _addInjuryField(); // Start with one injury description field

    // Get the current user UID
    _userUid = FirebaseAuth.instance.currentUser?.uid;
    if (_userUid == null) {
      // Handle the case where the user is not logged in (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is logged in")),
      );
    }
  }

  // Function to add a new injury description field
  void _addInjuryField() {
    setState(() {
      _injuryDescriptionList.add(TextEditingController());
    });
  }

  // Function to save injuries to Firestore and create notifications for connected doctors
  // Updated _saveInjuries function in AddInjuryPage

  Future<void> _saveInjuries() async {
    if (_injuryDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter injury date")),
      );
      return;
    }

    if (_userUid == null) {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    String injuryDate = _injuryDateController.text;
    Map<String, dynamic> injuryData = {
      "userId": _userUid, // Store the user's UID with the injury data
      "injuryDate": injuryDate, // Store the injury date
    };

    // Store injury descriptions
    for (int i = 0; i < _injuryDescriptionList.length; i++) {
      if (_injuryDescriptionList[i].text.isNotEmpty) {
        injuryData["injury_${i + 1}"] = _injuryDescriptionList[i].text;
      }
    }

    if (injuryData.isNotEmpty) {
      // Save injury data to the 'Injury Management' collection using injuryDate as the document name
      await FirebaseFirestore.instance
          .collection("Injury Management")
          .doc(injuryDate) // Store injuries under the date as the document name
          .set(injuryData);

      // Fetch all connected doctors (connections) for the user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('connections')
          .where('userId', isEqualTo: _userUid)
          .where('status', isEqualTo: 'connected')
          .get();

      // Fetch the athlete's name (user who submitted the injury)
      String athleteName = await _getUserName(_userUid!);

      // Iterate through each connected doctor and create notifications
      for (var doc in querySnapshot.docs) {
        String doctorId = doc['doctorId'];
        // Fetch the doctor's name from the 'users' collection
        String doctorName = await _getUserName(doctorId);

        // Create a notification message
        String notificationMessage = "$doctorName, $athleteName submitted an injury!!";

        // Notification data structure
        Map<String, dynamic> notificationData = {
          "doctorId": doctorId,
          "userId": _userUid,
          "injuryDate": injuryDate,
          "message": notificationMessage,
          "injuryDetails": injuryData,
          "status": "unread", // Status of the notification
        };

        // Save the notification in the 'InjuryNotifications' collection
        await FirebaseFirestore.instance
            .collection('InjuryNotifications')
            .doc(injuryDate + "_" + doctorId) // Ensure unique doc name per doctor
            .set(notificationData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Injuries saved successfully!")),
      );

      // Clear fields after saving
      _injuryDateController.clear();
      setState(() {
        _injuryDescriptionList.clear();
        _addInjuryField();
      });

      // After saving, navigate directly to ShowInjuryPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ShowInjuryPage(injuryDate: injuryDate),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one injury description")),
      );
    }
  }

  // Fetch the user's name from the users collection
  Future<String> _getUserName(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['name'] ?? 'Unknown User'; // Return name or default if not found
      }
      return 'Unknown User'; // Default name if user not found
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Unknown User'; // Default name in case of error
    }
  }

  @override
  void dispose() {
    _injuryDateController.dispose();
    for (var controller in _injuryDescriptionList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Injury"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Injury Date Field
            TextField(
              controller: _injuryDateController,
              decoration: const InputDecoration(
                labelText: "Injury Date",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // List of injury description input fields
            Expanded(
              child: ListView.builder(
                itemCount: _injuryDescriptionList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _injuryDescriptionList[index],
                            decoration: const InputDecoration(
                              labelText: "Injury Description",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),

                          // "+" Button to add another injury description field
                          if (index == _injuryDescriptionList.length - 1)
                            ElevatedButton(
                              onPressed: _addInjuryField,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: _saveInjuries,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text("Save Injury", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

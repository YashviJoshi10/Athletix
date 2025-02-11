import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: [
          // Injury Notifications Section (real-time updates)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('InjuryNotifications') // Injury Notifications collection
                .where('doctorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Only fetch for the current doctor
                .snapshots(), // Listen for real-time updates
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching injury notifications'));
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No injury notifications"),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Injury Notifications",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...snapshot.data!.docs.map((notification) {
                    var message = notification['message']; // Injury message

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: Text(message), // Show the message
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),

          // Connection Requests Section (real-time updates)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('connections') // Connections collection
                .where('doctorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Only fetch for the current doctor
                .snapshots(), // Listen for real-time updates
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching connection requests'));
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return const SizedBox(); // No connection requests
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Connection Requests",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...snapshot.data!.docs.map((request) {
                    var userId = request['userId']; // Sender ID
                    var requestId = request.id; // Document ID for any further action
                    var status = request['status']; // Get the status of the request

                    return FutureBuilder<String>(
                      future: _getUserName(userId), // Fetch user's name
                      builder: (context, nameSnapshot) {
                        if (nameSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (nameSnapshot.hasError) {
                          return ListTile(
                            title: const Text('Error fetching name'),
                          );
                        } else {
                          var userName = nameSnapshot.data ?? 'Unknown User';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person_add, color: Colors.blue),
                                  title: Text('Connection request from $userName'),
                                  subtitle: Text('Status: $status'),
                                ),
                                if (status == 'pending') // Only show buttons for pending requests
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Accept the request by updating the status in Firestore
                                            await FirebaseFirestore.instance
                                                .collection('connections')
                                                .doc(requestId)
                                                .update({'status': 'connected'}); // Accept the request

                                            // Show a confirmation message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Request Accepted')),
                                            );
                                          },
                                          child: const Text('Connect'),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.blue,// Corrected the use of primary
                                          ),
                                        ),
                                        const SizedBox(width: 8), // Space between buttons
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Reject the request by updating the status in Firestore
                                            await FirebaseFirestore.instance
                                                .collection('connections')
                                                .doc(requestId)
                                                .update({'status': 'rejected'}); // Reject the request

                                            // Show a confirmation message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Request Rejected')),
                                            );
                                          },
                                          child: const Text('Reject'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,// Corrected the use of primary
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

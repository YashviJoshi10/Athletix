import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_injury_page.dart';
import 'show_injuries.dart'; // Import ShowInjuryPage
import 'ai_responses.dart'; // Import AIResponsesPage

class InjuryManagementPage extends StatefulWidget {
  const InjuryManagementPage({super.key});

  @override
  _InjuryManagementPageState createState() => _InjuryManagementPageState();
}

class _InjuryManagementPageState extends State<InjuryManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch the injury data from Firestore
  Future<List<Map<String, dynamic>>> _fetchInjuries() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Injury Management').get();
      List<Map<String, dynamic>> injuryList = [];

      // Iterate through all documents
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          var injuryMap = {
            'id': doc.id,  // Document ID (e.g., injury_1, injury_2)
            'uid': data['uid'],  // User ID
            'date': data['injuryDate'] ?? 'No Date',  // Injury Date
            'descriptions': []  // Create a list for injury descriptions
          };

          // Iterate through the fields of the data map and collect only the injury descriptions
          data.forEach((key, value) {
            if (key.startsWith('injury_') && value != null) {
              injuryMap['descriptions'].add(value);  // Add the description to the list
            }
          });

          injuryList.add(injuryMap);
        }
      }

      return injuryList;
    } catch (e) {
      print('Error fetching injuries: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Injury Management"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddInjuryPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Add Injury", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Button to go to AI Responses page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIResponsesPage(),  // Navigate to AIResponsesPage
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Get Previous AI Responses", style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 20),

            FutureBuilder<List<Map<String, dynamic>>>(  // FutureBuilder to fetch and display injuries
              future: _fetchInjuries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No injuries found.'));
                }

                List<Map<String, dynamic>> injuries = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: injuries.length,
                    itemBuilder: (context, index) {
                      var injury = injuries[index];
                      // Join all descriptions in the 'descriptions' list with a newline
                      String descriptions = injury['descriptions'].join('\n');
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4.0,
                        child: InkWell(
                          onTap: () {
                            // When the injury item is tapped, navigate to ShowInjuryPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowInjuryPage(injuryDate: injury['id']),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(injury['id']),  // Injury ID (e.g., injury_1, injury_2)
                            subtitle: Text(
                              'Date: ${injury['date']}\n$descriptions', // Only descriptions here
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

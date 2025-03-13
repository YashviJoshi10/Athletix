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
        centerTitle: true,  // Center the title for a modern look
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),  // Increase padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Align children to the start
          children: [
            // Elevated button with gradient effect
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  _createRoute(const AddInjuryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  // Corrected to backgroundColor
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),  // Rounded corners for buttons
                ),
                shadowColor: Colors.greenAccent,  // Button shadow color
              ).copyWith(
                elevation: MaterialStateProperty.all(10),
              ),
              child: const Text("Add Injury", style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
            const SizedBox(height: 20),  // Add space between buttons

            // Button for AI responses with gradient
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  _createRoute(AIResponsesPage()),  // Navigate to AIResponsesPage
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              child: const Text("Get Previous AI Responses", style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
            const SizedBox(height: 20),  // Add space between buttons and the list

            // FutureBuilder to fetch and display injuries
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
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

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      itemCount: injuries.length,
                      itemBuilder: (context, index) {
                        var injury = injuries[index];
                        String descriptions = injury['descriptions'].join('\n');
                        return AnimatedCard(
                          injuryId: injury['id'],
                          date: injury['date'],
                          descriptions: descriptions,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final String injuryId;
  final String date;
  final String descriptions;

  const AnimatedCard({
    Key? key,
    required this.injuryId,
    required this.date,
    required this.descriptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowInjuryPage(injuryDate: injuryId),
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          color: Colors.white,
        ),
        child: ListTile(
          title: Text(
            injuryId,  // Injury ID (e.g., injury_1, injury_2)
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Date: $date\n$descriptions',  // Descriptions and Date
            overflow: TextOverflow.ellipsis,  // Prevent overflow
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          leading: Icon(
            Icons.health_and_safety,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'gemini_ai.dart'; // Import Gemini AI page to redirect for recommendations

class ShowInjuryPage extends StatefulWidget {
  final String injuryDate;

  const ShowInjuryPage({super.key, required this.injuryDate});

  @override
  _ShowInjuryPageState createState() => _ShowInjuryPageState();
}

class _ShowInjuryPageState extends State<ShowInjuryPage> {
  late Map<String, dynamic> injuryDetails;

  @override
  void initState() {
    super.initState();
    injuryDetails = {};
    _fetchInjuryDetails();
  }

  // Fetch injury details from Firestore based on injuryDate
  Future<void> _fetchInjuryDetails() async {
    try {
      final injurySnapshot = await FirebaseFirestore.instance
          .collection('Injury Management')
          .doc(widget.injuryDate) // Fetch injury by injuryDate
          .get();

      if (injurySnapshot.exists) {
        setState(() {
          injuryDetails = injurySnapshot.data()!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Injury details not found")),
        );
      }
    } catch (e) {
      print("Error fetching injury details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching injury details")),
      );
    }
  }

  // Show dialog asking if user wants AI recommendations
  // Show dialog asking if user wants AI recommendations
  void _showAIRecommendationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("AI Recommendations"),
          content: const Text("Would you like to see some AI recommendations for your injury?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog

                // Filter and collect only injury descriptions
                List<String> descriptions = injuryDetails.entries
                    .where((entry) =>
                entry.key.startsWith('injury_') && entry.value is String) // Only injury fields
                    .map((entry) => entry.value as String) // Get the description values
                    .toList();

                // Ensure there are valid descriptions before proceeding
                if (descriptions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No injury descriptions found")),
                  );
                  return;
                }

                // Navigate to Gemini AI page with filtered descriptions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeminiAIPage(
                      descriptions: descriptions,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Injury Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display injury details: Date and description(s)
            Text(
              "Injury Date: ${widget.injuryDate}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Injury Details:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List all injury descriptions
            Expanded(
              child: ListView.builder(
                itemCount: injuryDetails.length,
                itemBuilder: (context, index) {
                  String key = injuryDetails.keys.elementAt(index);
                  if (key != 'userId' && key != 'injuryDate') {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(injuryDetails[key] ?? "No description"),
                      ),
                    );
                  }
                  return const SizedBox(); // Skip 'userId' and 'injuryDate'
                },
              ),
            ),

            // AI Recommendations Button
            ElevatedButton(
              onPressed: _showAIRecommendationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text("AI Recommendations", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool isLoading = true; // Track loading state

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
          isLoading = false; // Set loading to false when data is fetched
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Injury details not found")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching injury details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching injury details")),
      );
    }
  }

  // Show dialog asking if user wants AI recommendations
  // Inside _showAIRecommendationDialog
  void _showAIRecommendationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Get AI Recommendations"),
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

                // Custom message to provide context for the AI
                String customMessage = "Hey, I am an athlete, and I am injured. Can you tell me some recovery tips or precautions to take?";

                // Combine the custom message with the injury descriptions
                List<String> inputForAI = [customMessage] + descriptions;

                // Navigate to Gemini AI page with the custom message and descriptions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeminiAIPage(
                      descriptions: inputForAI, // Pass both message and descriptions
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Injury Details:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Loading Indicator while fetching data
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
            else
            // List all injury descriptions
              Expanded(
                child: ListView.builder(
                  itemCount: injuryDetails.length,
                  itemBuilder: (context, index) {
                    String key = injuryDetails.keys.elementAt(index);
                    if (key != 'userId' && key != 'injuryDate') {
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            injuryDetails[key] ?? "No description",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(); // Skip 'userId' and 'injuryDate'
                  },
                ),
              ),

            // AI Recommendations Button
            const SizedBox(height: 20),
            // AI Recommendations Button
            Center(
              child: ElevatedButton(
                onPressed: _showAIRecommendationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Correct parameter
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "AI Recommendations",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

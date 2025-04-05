import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIResponsesPage extends StatefulWidget {
  @override
  _AIResponsesPageState createState() => _AIResponsesPageState();
}

class _AIResponsesPageState extends State<AIResponsesPage> {
  // Keep track of the expanded AI response
  int? _expandedAIResponseIndex;

  // Function to toggle the expansion of AI response
  void _toggleAIResponseExpansion(int index) {
    setState(() {
      // If the clicked AI response is already expanded, collapse it, else expand it
      if (_expandedAIResponseIndex == index) {
        _expandedAIResponseIndex = null;
      } else {
        _expandedAIResponseIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Responses"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AI')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No AI responses found"));
          }

          final aiResponses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: aiResponses.length,
            itemBuilder: (context, index) {
              var aiResponse = aiResponses[index];
              List<dynamic> injuryDescriptions = aiResponse['injury_descriptions'];
              String aiMessage = aiResponse['ai_response'] ?? "No AI response";

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Injury Descriptions:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Show injury descriptions without expansion
                      for (var description in injuryDescriptions)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- $description',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      SizedBox(height: 16),

                      // AI Response section
                      Text(
                        'AI Response:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Show AI response with the option to expand/collapse
                      GestureDetector(
                        onTap: () => _toggleAIResponseExpansion(index),
                        child: Text(
                          _expandedAIResponseIndex == index
                              ? aiMessage
                              : 'Click to Expand',
                          style: TextStyle(
                            fontSize: 14,
                            color: _expandedAIResponseIndex == index
                                ? Colors.black
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

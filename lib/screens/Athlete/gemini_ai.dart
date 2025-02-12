import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Required for Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiAIPage extends StatefulWidget {
  final List<String> descriptions;

  GeminiAIPage({required this.descriptions});

  @override
  _GeminiAIPageState createState() => _GeminiAIPageState();
}

class _GeminiAIPageState extends State<GeminiAIPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _loading = false;

  // Function to get the Firebase user token
  Future<String?> _getFirebaseToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    } else {
      throw Exception('No user logged in');
    }
  }

  // Function to call the backend API
  Future<void> _fetchGeminiAIResponse() async {
    setState(() {
      _loading = true;
    });

    try {
      String? token = await _getFirebaseToken();
      if (token == null) {
        throw Exception('Firebase token is null');
      }

      final response = await http.post(
        Uri.parse('https://athletix-proxy-server.vercel.app/api/gemini'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'prompt': widget.descriptions.join("\n")}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          // First, add the user's message
          widget.descriptions.forEach((desc) {
            _messages.add({'message': desc, 'sender': 'user'});
          });
          // Then, add the AI response
          _messages.add({'message': data['message'], 'sender': 'ai'});

          // Save the AI response to Firestore
          _saveAIResponse(data['message']);
        });
      } else {
        setState(() {
          _messages.add({'message': 'Error: ${response.statusCode}', 'sender': 'ai'});
        });
      }
    } catch (error) {
      setState(() {
        _messages.add({'message': 'Error: $error', 'sender': 'ai'});
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Save AI response to Firestore
  Future<void> _saveAIResponse(String aiResponse) async {
    String injuryId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
    Map<String, dynamic> aiData = {
      'injury_descriptions': widget.descriptions,
      'ai_response': aiResponse,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };

    await FirebaseFirestore.instance
        .collection('AI')
        .doc(injuryId)
        .set(aiData); // Save AI data under a unique document ID

    print('AI response saved to Firestore');
  }

  @override
  void initState() {
    super.initState();
    _fetchGeminiAIResponse(); // Fetch AI recommendations when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini AI Recommendations"),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Loading indicator while waiting for AI response
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
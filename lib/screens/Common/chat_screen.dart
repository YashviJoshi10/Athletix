import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  ChatScreen({required this.receiverId, required this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String loggedInUserId;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    loggedInUserId = _auth.currentUser?.uid ?? '';
    _scrollController = ScrollController(); // Initialize the scroll controller
  }

  @override
  void dispose() {
    _scrollController?.dispose(); // Safely dispose of the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: loggedInUserId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var messages = snapshot.data?.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['participants'].contains(widget.receiverId);
                }).toList() ?? [];

                return ListView.builder(
                  controller: _scrollController, // Use the scroll controller
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    bool isSentByMe = message['senderId'] == loggedInUserId;

                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                    _scrollToBottom();  // Trigger scroll after sending message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Send a message and store it in Firestore
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    FirebaseFirestore.instance.collection('chats').add({
      'senderId': loggedInUserId,
      'receiverId': widget.receiverId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'participants': [loggedInUserId, widget.receiverId],
    });

    _messageController.clear();
  }

  // Scroll to the bottom after the message is sent
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.animateTo(
          _scrollController!.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

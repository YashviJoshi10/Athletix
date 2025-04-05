import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> recentChats = [];
  bool isSearching = false;
  String loggedInUserId = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchAllUsers();
    _getCurrentUserId();
    _fetchRecentChats();
  }

  Future<void> _getCurrentUserId() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUserId = user.uid;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      isSearching = searchQuery.isNotEmpty;
    });
    if (searchQuery.isNotEmpty) {
      _filterSearchResults();
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        allUsers = querySnapshot.docs.map((doc) {
          var data = doc.data();
          data['userId'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> _fetchRecentChats() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: loggedInUserId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> recentUsers = [];
      querySnapshot.docs.forEach((doc) {
        var data = doc.data();
        var participants = data['participants'] as List<dynamic>;
        var otherUserId = participants.firstWhere(
              (participant) => participant != loggedInUserId,
          orElse: () => null,
        );

        if (otherUserId != null) {
          var user = allUsers.firstWhere(
                (user) => user['userId'] == otherUserId,
            orElse: () => {},
          );

          if (user.isNotEmpty && !recentUsers.any((u) => u['userId'] == user['userId'])) {
            recentUsers.add(user);
          }
        }
      });

      setState(() {
        recentChats = recentUsers;
      });
    } catch (e) {
      print("Error fetching recent chats: $e");
    }
  }

  void _filterSearchResults() {
    setState(() {
      searchResults = allUsers.where((user) {
        return user['name']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) &&
            user['userId'] != loggedInUserId;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: isSearching ? Text('Searching...') : Text('Messages', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(  // Make the body scrollable
        child: Container(
          color: isSearching ? Colors.white : Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              _buildSearchBar(),
              SizedBox(height: 20),
              // Display recent chats if any
              if (recentChats.isNotEmpty) _buildRecentChats(),
              SizedBox(height: 10),
              if (isSearching) _buildSearchResults(),
              if (!isSearching)
                Center(
                  child: Text('Search for a person by name'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search for a person...',
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildRecentChats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: recentChats.length,
          itemBuilder: (context, index) {
            var user = recentChats[index];
            String role = user['profession'] ?? 'No Role';
            String specialization = user['specialization'] ?? '';
            String subtitle = specialization.isEmpty ? role : '$role - $specialization';

            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              title: Text(user['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              onTap: () {
                if (user.containsKey('userId') && user['userId'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: user['userId'],
                        receiverName: user['name'],
                      ),
                    ),
                  );
                } else {
                  print('Error: Missing userId or name');
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(child: Text('No results found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var user = searchResults[index];
        String role = user['profession'] ?? 'No Role';
        String specialization = user['specialization'] ?? '';
        String subtitle = specialization.isEmpty ? role : '$role - $specialization';

        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          title: Text(user['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
          onTap: () {
            if (user.containsKey('userId') && user['userId'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiverId: user['userId'],
                    receiverName: user['name'],
                  ),
                ),
              );
            } else {
              print('Error: Missing userId or name');
            }
          },
        );
      },
    );
  }
}

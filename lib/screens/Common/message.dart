import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatScreen.dart';

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

  // Fetch the logged-in user's ID
  Future<void> _getCurrentUserId() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUserId = user.uid;
      });
    }
  }

  // Listen for search query changes
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

  // Fetch all users from Firestore
  Future<void> _fetchAllUsers() async {
    try {
      var querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        allUsers = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['userId'] = doc.id; // Ensure userId is correctly assigned
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // Fetch recent chats for the logged-in user
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
        var data = doc.data() as Map<String, dynamic>;
        var participants = data['participants'] as List<dynamic>;

        // Find the other user ID (not the logged-in user)
        var otherUserId = participants.firstWhere(
              (participant) => participant != loggedInUserId,
          orElse: () => null,
        );

        if (otherUserId != null) {
          // Find user data from 'allUsers' list
          var user = allUsers.firstWhere(
                (user) => user['userId'] == otherUserId,
            orElse: () => {},
          );

          // Ensure user exists and isn't already added to recentChats
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

  // Filter search results and exclude the logged-in user
  void _filterSearchResults() {
    setState(() {
      searchResults = allUsers.where((user) {
        return user['name']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) &&
            user['userId'] != loggedInUserId; // Exclude logged-in user
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? Text('Searching...') : Text('Messages'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: isSearching ? Colors.white : Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a person...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
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
    );
  }

  // Widget to display recent chats
  Widget _buildRecentChats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // Display a ListView of recent chats
        ListView.builder(
          shrinkWrap: true,  // Prevents the ListView from expanding
          itemCount: recentChats.length,
          itemBuilder: (context, index) {
            var user = recentChats[index];
            String role = user['role'] ?? 'No Role'; // Fetch role
            String specialization = user['specialization'] ?? ''; // Fetch specialization

            // Format subtitle as <Role> - <Specialization>
            String subtitle = specialization.isEmpty ? role : '$role - $specialization';

            return ListTile(
              title: Text(user['name'] ?? 'No Name'),
              subtitle: Text(subtitle),  // Display formatted subtitle
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

  // Widget to display search results
  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(child: Text('No results found.'));
    }

    return ListView.builder(
      shrinkWrap: true, // Prevents the ListView from expanding
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var user = searchResults[index];
        String role = user['profession'] ?? 'No Role'; // Fetch role
        String specialization = user['specialization'] ?? ''; // Fetch specialization

        // Format subtitle as <Role> - <Specialization>
        String subtitle = specialization.isEmpty ? role : '$role - $specialization';

        return ListTile(
          title: Text(user['name'] ?? 'No Name'),
          subtitle: Text(subtitle),  // Display formatted subtitle
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

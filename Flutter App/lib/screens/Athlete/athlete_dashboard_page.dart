import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/Athlete/injury_management.dart';
import '../Common/drawer_menu.dart';
import '../Common/message.dart';
import 'goal_setting.dart';

class AthleteDashboardPage extends StatelessWidget {
  const AthleteDashboardPage({Key? key}) : super(key: key);

  Future<String> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Fetch user info from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc['name'] ?? 'Athlete'; // Default to 'Athlete' if no name is found
    }
    return 'Athlete'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Make sure the Scaffold widget wraps the content here
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent], // Gradient color
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Athlete Dashboard',
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(), // Assuming this is your custom DrawerMenu widget
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Welcome Message with Shadow and Gradient
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FutureBuilder<String>(
                future: _getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Welcome, Athlete!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(offset: Offset(2, 2), blurRadius: 6, color: Colors.black.withOpacity(0.3))
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Text(
                      'Welcome, ${snapshot.data}!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(offset: Offset(2, 2), blurRadius: 6, color: Colors.black.withOpacity(0.3))
                        ],
                      ),
                    );
                  } else {
                    return Text(
                      'Welcome, Athlete!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(offset: Offset(2, 2), blurRadius: 6, color: Colors.black.withOpacity(0.3))
                        ],
                      ),
                    );
                  }
                },
              ),
            ),

            // Performance Tracker Card
            _buildDashboardTile(
              context,
              icon: Icons.directions_run,
              title: 'Performance Tracker',
              subtitle: 'Track your daily performance and stats.',
              onTap: () {
                // Add functionality here
              },
              color: Colors.tealAccent,
            ),

            // Injury Management Card
            _buildDashboardTile(
              context,
              icon: Icons.health_and_safety,
              title: 'Injury Management',
              subtitle: 'Log and monitor injuries for recovery.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InjuryManagementPage()),
                );
              },
              color: Colors.orangeAccent,
            ),

            // Goal Setting Card
            _buildDashboardTile(
              context,
              icon: Icons.flag,
              title: 'Goal Setting',
              subtitle: 'Set and track your fitness & career goals.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalSettingPage()),
                );
              },
              color: Colors.blueAccent,
            ),

            // Financial Management Card
            _buildDashboardTile(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Financial Management',
              subtitle: 'Manage sponsorships and expenses.',
              onTap: () {
                // Add functionality here
              },
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required Color color,
      }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Icon(
            icon,
            size: 32,
            color: color,
          ),
          title: Text(
            title,
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

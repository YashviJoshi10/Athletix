import 'package:flutter/material.dart';
import 'package:myapp/screens/Athlete/injury_management.dart';
import '../Common/drawer_menu.dart';
import '../Common/message.dart';
import 'goal_setting.dart';

class AthleteDashboardPage extends StatelessWidget {
  const AthleteDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Athlete Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu), // Hamburger icon
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the drawer on button press
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message), // Messaging icon
            onPressed: () {
              // Navigate to MessagePage when the messaging icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(), // Add the DrawerMenu to the scaffold
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Athlete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Example sections with no arrow icon
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Performance Tracker'),
              subtitle: Text('Track your daily performance and stats.'),
              onTap: () {
                // Add functionality (no navigation here)
              },
              trailing: null,  // Removes the trailing arrow
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety),
              title: Text('Injury Management'),
              subtitle: Text('Log and monitor injuries for recovery.'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InjuryManagementPage()),
                );
              },
              trailing: null,  // Removes the trailing arrow
            ),
            // New Goal Setting Feature
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Goal Setting'),
              subtitle: Text('Set and track your fitness & career goals.'),
              onTap: () {
                // Navigate to Goal Setting Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalSettingPage()),
                );
              },
              trailing: null,  // Removes the trailing arrow
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Financial Management'),
              subtitle: Text('Manage sponsorships and expenses.'),
              onTap: () {
                // Add functionality (no navigation here)
              },
              trailing: null,  // Removes the trailing arrow
            ),
          ],
        ),
      ),
    );
  }
}

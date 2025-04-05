import 'package:flutter/material.dart';
import '../Common/drawer_menu.dart'; // Import the DrawerMenu
import '../Common/message.dart'; // Import the MessagePage
import '../Common/notifications_page.dart';

class CoachDashboardPage extends StatelessWidget {
  const CoachDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu), // Hamburger icon
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to NotificationsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.message), // Messaging icon
            onPressed: () {
              // Navigate to MessagePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(), // Add the DrawerMenu
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Coach!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Example sections
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Team Management'),
              subtitle: Text('Manage your team members and schedules.'),
              onTap: () {
                // Add functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Performance Analytics'),
              subtitle: Text('Analyze player performances and insights.'),
              onTap: () {
                // Add functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Training Programs'),
              subtitle: Text('Plan and organize training sessions.'),
              onTap: () {
                // Add functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

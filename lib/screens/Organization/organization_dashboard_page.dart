import 'package:flutter/material.dart';
import '../Common/drawer_menu.dart'; // Import the DrawerMenu
import '../Common/message.dart'; // Import the MessagePage
import '../Common/notifications_page.dart';

class OrganizationDashboardPage extends StatelessWidget {
  const OrganizationDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organization Dashboard'),
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
              'Welcome, Organization!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Example sections
            ListTile(
              leading: Icon(Icons.sports),
              title: Text('Athlete Management'),
              subtitle: Text('Monitor and manage athletes under your banner.'),
              onTap: () {
                // Add functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Event Management'),
              subtitle: Text('Plan and organize sports events.'),
              onTap: () {
                // Add functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Sponsorship Deals'),
              subtitle: Text('Handle sponsorships and finances.'),
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

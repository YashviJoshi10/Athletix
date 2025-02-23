import 'package:flutter/material.dart';
import '../Common/drawer_menu.dart'; // Import the DrawerMenu
import '../Common/message.dart'; // Import the MessagePage
import '../Common/notifications_page.dart';

class PhysicianDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physician Dashboard'),
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
              'Welcome, Physician!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Example sections with no arrow icon
            ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('Patient Management'),
              subtitle: Text('Manage and monitor patient health records.'),
              onTap: () {
                // Add functionality (no navigation here)
              },
              trailing: null,  // Removes the trailing arrow
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Medical Research'),
              subtitle: Text('Stay updated with the latest research in medicine.'),
              onTap: () {
                // Add functionality (no navigation here)
              },
              trailing: null,  // Removes the trailing arrow
            ),
            // New Goal Setting Feature
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Financial Management'),
              subtitle: Text('Manage income and expenditures.'),
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

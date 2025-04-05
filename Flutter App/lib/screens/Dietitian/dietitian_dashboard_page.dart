import 'package:flutter/material.dart';
import '../Common/notifications_page.dart'; // Import the NotificationsPage
import '../Common/drawer_menu.dart'; // Import the DrawerMenu
import '../Common/message.dart';

class DietitianDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dietitian Dashboard'),
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
          // Notifications icon (left of the message icon)
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
          // Message icon (right of the notification icon)
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
              print("Messages pressed");
            },
          ),
        ],
      ),
      drawer: DrawerMenu(), // Add the DrawerMenu to the scaffold
      body: Center(
        child: Text(
          'Welcome, Dietitian!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

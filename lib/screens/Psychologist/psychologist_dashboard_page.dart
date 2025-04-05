import 'package:flutter/material.dart';
import '../Common/notifications_page.dart'; // Import the NotificationsPage
import '../Common/drawer_menu.dart'; // Import the DrawerMenu
import '../Common/message.dart';

class PsychologistDashboardPage extends StatelessWidget {
  // Add the key parameter to the constructor
  const PsychologistDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Psychologist Dashboard'),
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
            },
          ),
        ],
      ),
      drawer: DrawerMenu(), // Add the DrawerMenu to the scaffold
      body: Center(
        child: Text(
          'Welcome, Psychologist!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

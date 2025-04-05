import 'package:flutter/material.dart';
import '../Common/notifications_page.dart';
import '../Common/drawer_menu.dart';
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
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
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
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, Dietitian!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),

              // Quick Action Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildActionCard(context, Icons.person, 'Athlete Progress', () {
                    print('Athlete Progress tapped');
                  }),
                  _buildActionCard(context, Icons.restaurant, 'Meal Plans', () {
                    print('Meal Plans tapped');
                  }),
                  _buildActionCard(context, Icons.calendar_today, 'Appointments', () {
                    print('Appointments tapped');
                  }),
                  _buildActionCard(context, Icons.bar_chart, 'Nutritional Reports', () {
                    print('Nutritional Reports tapped');
                  }),
                ],
              ),

              SizedBox(height: 20),

              // Upcoming Appointments
              Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildAppointmentCard('Athlete A', '10:00 AM, April 7', 'Nutrition Consultation'),
              _buildAppointmentCard('Athlete B', '2:00 PM, April 8', 'Meal Plan Review'),

              SizedBox(height: 20),

              // Recent Notifications
              Text(
                'Recent Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildNotificationTile('New athlete signed up!', 'Check their profile to get started.'),
              _buildNotificationTile('Appointment Rescheduled', 'Athlete A’s session is now at 3 PM.'),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Action Card Builder
  Widget _buildActionCard(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // Upcoming Appointment Card
  Widget _buildAppointmentCard(String athleteName, String time, String purpose) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
        title: Text(athleteName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$time • $purpose'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          print('Appointment with $athleteName');
        },
      ),
    );
  }

  // Notification Tile
  Widget _buildNotificationTile(String title, String message) {
    return ListTile(
      leading: Icon(Icons.notifications_active, color: Colors.orange),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        print('Notification tapped: $title');
      },
    );
  }
}

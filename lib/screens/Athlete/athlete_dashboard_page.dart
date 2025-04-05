import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/Athlete/injury_management.dart';
import '../Common/drawer_menu.dart';
import '../Common/message.dart';
import 'goal_setting.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Common/profile.dart';

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
            // Calendar Widget
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  // Add functionality for clicking on a date
                  print('Selected day: $selectedDay');
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blueAccent),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blueAccent),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 12, color: Colors.black),
                  weekendStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Fitness Stats Overview
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blueGrey[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitness Stats Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatsCard('Distance', '5.2 km'),
                        _buildStatsCard('Calories Burned', '420 kcal'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatsCard('Workouts', '18 sessions'),
                        _buildStatsCard('Active Minutes', '120 mins'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Workout Log Card
            _buildDashboardTile(
              context,
              icon: Icons.fitness_center,
              title: 'Workout Log',
              subtitle: 'View and log your workout sessions.',
              onTap: () {
                // Add functionality for logging workouts
              },
              color: Colors.greenAccent,
            ),

            // Recent Activities Card
            _buildDashboardTile(
              context,
              icon: Icons.history,
              title: 'Recent Activities',
              subtitle: 'View your recent training sessions and events.',
              onTap: () {
                // Add functionality for recent activities
              },
              color: Colors.tealAccent,
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

            // Upcoming Events Card
            _buildDashboardTile(
              context,
              icon: Icons.event,
              title: 'Upcoming Events',
              subtitle: 'Check your upcoming events and competitions.',
              onTap: () {
                // Add functionality for upcoming events
              },
              color: Colors.purpleAccent,
            ),

            // Profile Card
            _buildDashboardTile(
              context,
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'View and update your profile.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
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

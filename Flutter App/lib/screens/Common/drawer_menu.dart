import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/Athlete/goal_setting.dart';
import 'package:myapp/screens/Athlete/injury_management.dart';
import 'login.dart'; // Assuming the login page is in this file
import 'profile.dart';
import '../Athlete/athlete_dashboard_page.dart'; // Import athlete-specific screen
import '../Coach/coach_dashboard_page.dart'; // Import coach-specific screen
import '../Organization/organization_dashboard_page.dart'; // Import organization-specific screen

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String userProfession = ''; // User profession: athlete, coach, organization, or other

  // Function to fetch user profession from Firestore or custom claims
  Future<void> _fetchUserProfession() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Fetch 'profession' field from Firestore
          if (userData.containsKey('profession')) {
            setState(() {
              userProfession = userData['profession'] ?? 'athlete'; // Default to 'athlete' if no profession is found
            });
          } else {
            // Handle the case where 'profession' is missing (default to 'athlete')
            setState(() {
              userProfession = 'athlete'; // Default profession
            });
          }
        } else {
          setState(() {
            userProfession = 'athlete'; // Default profession when document doesn't exist
          });
        }
      } catch (e) {
        print('Error fetching user profession: $e');
        setState(() {
          userProfession = 'athlete'; // Default profession on error
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfession(); // Fetch user profession when the drawer is loaded
  }

  // Sign out function
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the Row content
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(), // Adds space between the title and the close button
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer when the close icon is clicked
                    },
                  ),
                ],
              ),
            ),
            // Conditional content based on user profession
            if (userProfession == 'Athlete') ...[
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AthleteDashboardPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.analytics),
                title: Text('Performance Tracking'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Performance Tracking
                },
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('Injury Management'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InjuryManagementPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text('Goal Setting'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoalSettingPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Financial Planning'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Financial Planning
                },
              ),
            ] else if (userProfession == 'Coach') ...[
              // Coach-specific menu options
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CoachDashboardPage()), // Replace with actual coach dashboard page
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Manage Athletes'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Athlete Management
                },
              ),
            ] else if (userProfession == 'Organization') ...[
              // Organization-specific menu options
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrganizationDashboardPage()), // Replace with actual organization dashboard page
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Manage Coaches and Athletes'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Coach and Athlete Management
                },
              ),
            ] else ...[
              // For any other role, show the default options
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}

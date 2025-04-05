import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/Athlete/goal_setting.dart';
import 'package:myapp/screens/Athlete/injury_management.dart';
import 'login.dart';
import 'profile.dart';
import '../Athlete/athlete_dashboard_page.dart';
import '../Coach/coach_dashboard_page.dart';
import '../Organization/organization_dashboard_page.dart'; // New screen

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String userProfession = '';

  Future<void> _fetchUserProfession() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userProfession = userData['profession'] ?? 'athlete';
          });
        } else {
          setState(() {
            userProfession = 'athlete';
          });
        }
      } catch (e) {
        print('Error fetching user profession: $e');
        setState(() {
          userProfession = 'athlete';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfession();
  }

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            if (userProfession == 'Athlete') ...[
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('Injury Management'),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                },
              ),
            ] else if (userProfession == 'Coach') ...[
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CoachDashboardPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Manage Athletes'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ] else if (userProfession == 'Organization') ...[
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrganizationDashboardPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Manage Coaches and Athletes'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ] else if (userProfession == 'Dietitian') ...[
              // Dietitian-specific options
              ListTile(
                leading: Icon(Icons.emoji_food_beverage,
                    color: Colors.green), // Icon for Nutrition
                title: Text('Nutrition Plan Management'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.assessment, color: Colors.green),
                title: Text('Athlete Progress Reports'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart, color: Colors.green),
                title: Text('Diet Analytics'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
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

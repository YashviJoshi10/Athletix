// organization_dashboard.dart
import 'package:flutter/material.dart';

class OrganizationDashboardScreen extends StatelessWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Dashboard')),
      body: const Center(
        child: Text(
          'Welcome, Organization!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

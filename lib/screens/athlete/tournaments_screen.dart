import 'package:flutter/material.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tournaments',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

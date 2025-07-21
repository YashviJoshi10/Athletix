import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late Future<List<Tournament>> _tournaments;

  @override
  void initState() {
    super.initState();
    _tournaments = _fetchTournaments();
  }

  Future<List<Tournament>> _fetchTournaments() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // get user document
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userSport = userDoc['sport'] ?? '';

    // fetch tournaments of this sport
    final snapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('sport', isEqualTo: userSport)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Tournament.fromDocument(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: FutureBuilder<List<Tournament>>(
        future: _tournaments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tournaments = snapshot.data ?? [];

          if (tournaments.isEmpty) {
            return const Center(child: Text('No tournaments found.'));
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(tournaments.first.lat, tournaments.first.lng),
              zoom: 10,
            ),
            myLocationEnabled: true,            // ✅ shows your blue dot
            myLocationButtonEnabled: true,     // ✅ shows button to center on your location
            markers: tournaments
                .map((tournament) => Marker(
              markerId: MarkerId(tournament.id),
              position: LatLng(tournament.lat, tournament.lng),
              onTap: () {
                _showTournamentDialog(context, tournament);
              },
            ))
                .toSet(),
          );
        },
      ),
    );
  }

  void _showTournamentDialog(BuildContext context, Tournament t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${t.level}'),
            Text('Sport: ${t.sport}'),
            Text('Date: ${t.dateString}'),
            Text('Time: ${t.time}'),
            const SizedBox(height: 8),
            Text('Address: ${t.address}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}

class Tournament {
  final String id;
  final String name;
  final String level;
  final String sport;
  final String dateString;
  final String time;
  final String address;
  final double lat;
  final double lng;

  Tournament({
    required this.id,
    required this.name,
    required this.level,
    required this.sport,
    required this.dateString,
    required this.time,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory Tournament.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final Timestamp? dateTs = data['date'];
    final String dateStr = dateTs != null
        ? dateTs.toDate().toLocal().toString().split(' ')[0]
        : '';

    final loc = data['location'] ?? {};

    return Tournament(
      id: doc.id,
      name: data['name'] ?? '',
      level: data['level'] ?? '',
      sport: data['sport'] ?? '',
      dateString: dateStr,
      time: data['time'] ?? '',
      address: loc['address'] ?? '',
      lat: (loc['lat'] ?? 0).toDouble(),
      lng: (loc['lng'] ?? 0).toDouble(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InjuryTrackerScreen extends StatefulWidget {
  const InjuryTrackerScreen({super.key});

  @override
  State<InjuryTrackerScreen> createState() => _InjuryTrackerScreenState();
}

class _InjuryTrackerScreenState extends State<InjuryTrackerScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _injuryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _injuryDate;
  bool _isLoading = false;

  bool get _isFormValid =>
      _injuryController.text.trim().isNotEmpty && _injuryDate != null;

  void _clearForm() {
    _injuryController.clear();
    _notesController.clear();
    setState(() {
      _injuryDate = null;
    });
  }

  Future<void> _addInjury() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter injury & date")),
      );
      return;
    }
    setState(() => _isLoading = true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('injuries').add({
      'uid': uid,
      'description': _injuryController.text.trim(),
      'notes': _notesController.text.trim(),
      'date': _injuryDate!.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);

    _clearForm();

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteInjury(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Injury"),
        content:
        const Text("Are you sure you want to delete this injury entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('injuries').doc(docId).delete();
    }
  }

  void _showAddInjurySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setModalState(() {
                    _injuryDate = picked;
                  });
                  setState(() {});
                }
              }

              final isFormValid =
                  _injuryController.text.trim().isNotEmpty && _injuryDate != null;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Injury",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _injuryController,
                      decoration: const InputDecoration(
                        labelText: "Injury Description *",
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                        border: OutlineInputBorder(),
                        hintText: 'Describe your injury',
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Injury Date *",
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            hintText: _injuryDate == null
                                ? "Pick Date"
                                : DateFormat('yyyy-MM-dd').format(_injuryDate!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: "Notes (optional)",
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                        hintText: 'Additional details',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _clearForm();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.grey, width: 1.3),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isFormValid
                                ? () async {
                              await _addInjury();
                            }
                                : null,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isFormValid
                                    ? Color(0xFF1565C0)
                                    : Colors.grey,
                                width: 1.6,
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: isFormValid
                                    ? Color(0xFF1565C0)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInjuryCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final description = data['description'] ?? '';
    final notes = data['notes'] ?? '';
    String dateStr = '';
    try {
      final date = DateTime.parse(data['date'] ?? '');
      dateStr = DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      dateStr = data['date'] ?? '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Date: $dateStr"),
            if (notes.isNotEmpty) Text("Notes: $notes"),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _deleteInjury(doc.id),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: "Delete Injury",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          "Injury Tracker",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('injuries')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
                  "No injuries logged yet.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) =>
                _buildInjuryCard(context, docs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInjurySheet(context),
        icon: const Icon(
          Icons.add,
          color: Color(0xFF1565C0),
        ),
        label: const Text(
          "Add Injury",
          style: TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1565C0), width: 1.8),
        ),
      ),
    );
  }
}

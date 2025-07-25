import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_entry_model.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addFinancialEntry(FinancialEntry entry) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .add(entry.toMap());
  }

  Stream<List<FinancialEntry>> getFinancialEntries() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateFinancialEntry(FinancialEntry entry) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toMap());
  }

  Future<void> deleteFinancialEntry(String entryId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .doc(entryId)
        .delete();
  }
}
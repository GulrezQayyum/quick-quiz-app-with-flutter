// lib/data/datasources/profile_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      // Create default profile on first load
      final defaultProfile = {
        'id': user.uid,
        'name': user.displayName ?? '',
        'bio': '',
        'avatarUrl': '',
        'avatarSeed': '',
        'location': '',
        'favoriteCategories': [],
        'totalXP': 0,
        'quizzesPlayed': 0,
      };
      await _firestore.collection('users').doc(user.uid).set(defaultProfile);
      return defaultProfile;
    }

    return doc.data()!..['id'] = user.uid;
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  // ── Award XP atomically ──────────────────────────────────────
  Future<void> awardXP(int xp) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(doc);
      final currentXP   = (snap.data()?['totalXP']      ?? 0) as int;
      final quizzes     = (snap.data()?['quizzesPlayed'] ?? 0) as int;
      tx.update(doc, {
        'totalXP':       currentXP + xp,
        'quizzesPlayed': quizzes + 1,
      });
    });
  }
}
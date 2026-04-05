import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchCurrentUserData({
    bool includeRawDoc = false,
  }) async {
    final email = _auth.currentUser?.email?.trim();
    if (email == null || email.isEmpty) return null;

    try {
      QuerySnapshot<Map<String, dynamic>> userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        final lower = email.toLowerCase();
        if (lower != email) {
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: lower)
              .limit(1)
              .get();
        }
      }

      if (userQuery.docs.isEmpty) return null;
      final data = userQuery.docs.first.data();
      final normalized = <String, dynamic>{
        'name': data['Name'] ?? '',
        'surname': data['Surname'] ?? '',
        'email': data['email'] ?? '',
        'image_url': data['image_url'] ?? '',
        'student_id': data['student_id'] ?? '',
        'username': data['username'] ?? '',
      };
      if (includeRawDoc) {
        normalized['_firestore'] = Map<String, dynamic>.from(data);
      }
      return normalized;
    } catch (_) {
      return null;
    }
  }

  Future<String?> fetchProfileImageUrl(String username) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username).get();
      if (!userDoc.exists || userDoc.data() == null) return null;
      return userDoc['image_url'] as String?;
    } catch (_) {
      return null;
    }
  }
}

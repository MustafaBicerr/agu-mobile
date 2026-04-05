import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUserAccountService {
  FirebaseUserAccountService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'E-posta adresi boş olamaz.',
      );
    }
    await _auth.sendPasswordResetEmail(email: trimmed);
  }

  Future<void> deleteAccountAfterReauth({
    required String password,
    required String firestoreDocId,
    String? profileImageUrl,
    List<dynamic>? formerImageUrls,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Oturum bulunamadı.',
      );
    }

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);

    await _deleteProfileImagesBestEffort(profileImageUrl, formerImageUrls);

    await _firestore.collection('users').doc(firestoreDocId).delete();
    await user.delete();
  }

  Future<void> _deleteProfileImagesBestEffort(
    String? profileImageUrl,
    List<dynamic>? formerImageUrls,
  ) async {
    final urls = <String>{};
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      urls.add(profileImageUrl);
    }
    if (formerImageUrls != null) {
      for (final u in formerImageUrls) {
        if (u is String && u.isNotEmpty) urls.add(u);
      }
    }
    for (final url in urls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (_) {}
    }
  }
}

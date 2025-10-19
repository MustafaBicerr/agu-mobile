
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_page/featuers/auth/domain/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Remember me --------------------------------------------------
  @override
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  @override
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  @override
  Future<bool> canAutoLogin() async {
    final remember = await getRememberMe();
    return remember && _auth.currentUser != null;
  }

  // SignIn -------------------------------------------------------
  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // SignUp -------------------------------------------------------
  @override
  Future<({UserCredential cred, String documentId})> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String usernameBase,
    required String studentId,
    File? pickedImage,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // user count
    final usersCol = _firestore.collection('users');
    final countSnap = await usersCol.get();
    final count = countSnap.size + 1;

    // naming
    final formattedUsername = usernameBase.replaceAll(' ', '_');
    final documentId = '${formattedUsername}_$count';
    final fileName = '$documentId.jpg';

    String? imageUrl;
    if (pickedImage != null) {
      final ref = _storage.ref().child('user_images').child(fileName);
      await ref.putFile(pickedImage);
      imageUrl = await ref.getDownloadURL();
    }

    await usersCol.doc(documentId).set({
      'Name': name,
      'Surname': surname,
      'username': '${usernameBase}_$count',
      'email': email,
      'former_image_urls': [],
      'image_url': imageUrl ?? '',
      'student_id': studentId,
    });

    return (cred: cred, documentId: documentId);
  }
}

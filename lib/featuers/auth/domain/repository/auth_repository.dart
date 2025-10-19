
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> setRememberMe(bool value);
  Future<bool> getRememberMe();
  Future<bool> canAutoLogin();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<({UserCredential cred, String documentId})> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String usernameBase,
    required String studentId,
    File? pickedImage,
  });
}

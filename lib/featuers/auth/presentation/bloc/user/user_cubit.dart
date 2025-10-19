import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_page/featuers/auth/presentation/bloc/user/user_state.dart';
import 'package:image_picker/image_picker.dart';

class UserCubit extends Cubit<UserState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  UserCubit()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance,
        _picker = ImagePicker(),
        super(UserInitial());

  // --------------------------------------------------------------
  // Helper: fetch user data by current user's email
  // --------------------------------------------------------------
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final String? email = _auth.currentUser?.email;
    if (email == null) return null;

    try {
      final QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final Map<String, dynamic> data =
            userQuery.docs.first.data() as Map<String, dynamic>;

        return {
          'name': data['Name'] ?? '',
          'surname': data['Surname'] ?? '',
          'email': data['email'] ?? '',
          'image_url': data['image_url'] ?? '',
          'student_id': data['student_id'] ?? '',
          'username': data['username'] ?? '',
        };
      }
    } catch (e) {
      print("Firestore user fetch error: $e");
    }
    return null;
  }

  // --------------------------------------------------------------
  // Public: Load all user data + profile image url
  // --------------------------------------------------------------
  Future<void> loadAllUserData() async {
    if (_auth.currentUser == null) {
      emit(const UserError("Kullanici oturumu acik degil."));
      return;
    }

    emit(UserLoading());

    try {
      final Map<String, dynamic>? userData = await _fetchUserData();
      if (userData == null) {
        emit(const UserError("Kullanici verisi bulunamadi."));
        return;
      }

      String? imageUrl;
      final String? username = userData['username'];
      if (username != null && username.isNotEmpty) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(username).get();
        if (userDoc.exists && userDoc.data() != null) {
          imageUrl = (userDoc.data() as Map<String, dynamic>)['image_url'];
          print("image_url from Firestore: $imageUrl");
        }
      }

      emit(UserLoaded(userData: userData, profileImageUrl: imageUrl));
    } catch (e) {
      print("General load error: $e");
      emit(const UserError("Kullanici verileri yuklenirken bir hata olustu."));
    }
  }

  // --------------------------------------------------------------
  // Public: Update profile image url in current state (optional)
  // --------------------------------------------------------------
  void updateProfileImage(String newUrl) {
    final current = state;
    if (current is UserLoaded) {
      emit(current.copyWith(profileImageUrl: newUrl));
    }
  }

  // ---------------------------------------
  // Public: Update student id in Firestore 
  // ---------------------------------------
  Future<void> updateStudentId(String newStudentId) async {
    final currentState = state;
    if (currentState is UserLoaded &&
        currentState.userData?['username'] != null) {
      try {
        final username = currentState.userData!['username'];

        await _firestore.collection('users').doc(username).update({
          'student_id': newStudentId,
        });

        final updatedUserData =
            Map<String, dynamic>.from(currentState.userData!);
        updatedUserData['student_id'] = newStudentId;

        emit(currentState.copyWith(userData: updatedUserData));
      } catch (e) {
        emit(UserError("Ogrenci ID guncellenirken hata olustu: $e"));
      }
    }
  }

  // ==============================================================
  // IMAGE PICK & UPLOAD (Gallery / Camera)
  // ==============================================================

  // UI: BottomSheet -> onTap() => context.read<UserCubit>().pickImageFromGallery();
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _uploadImageToFirebase(image);
      }
    } catch (e) {
      emit(UserError("Galeriye erisim saglanamadi: $e"));
    }
  }

  // UI: BottomSheet -> onTap() => context.read<UserCubit>().pickImageFromCamera();
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _uploadImageToFirebase(image);
      }
    } catch (e) {
      emit(UserError("Kamera acilamadi: $e"));
    }
  }

  // Core uploader: creates incremental filename, updates Firestore fields
  Future<void> _uploadImageToFirebase(XFile image) async {
    final current = state;
    if (current is! UserLoaded) {
      emit(const UserError("Kullanici bilgisi yuklu degil."));
      return;
    }

    final username = current.userData?['username']?.toString();
    if (username == null || username.isEmpty) {
      emit(const UserError("Kullanici bulunamadi (username yok)."));
      return;
    }

    // show loading
    emit(UserLoading());

    try {
      final docRef = _firestore.collection('users').doc(username);
      final userDoc = await docRef.get();

      if (!userDoc.exists) {
        emit(const UserError("User document not found."));
        return;
      }

      // read or init former_image_urls
      List<dynamic> formerImageUrls = [];
      final data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('former_image_urls') && data['former_image_urls'] != null) {
        formerImageUrls = List<dynamic>.from(data['former_image_urls']);
      } else {
        await docRef.update({'former_image_urls': []});
      }

      final counter = formerImageUrls.length;
      final fileName = '${username}_${counter + 1}.jpg';
      final filePath = 'user_images/$fileName';

      final file = File(image.path);
      final TaskSnapshot uploaded = await _storage.ref(filePath).putFile(file);
      final String downloadUrl = await uploaded.ref.getDownloadURL();

      // Firestore update: new main image_url + append to former_image_urls
      await docRef.update({
        'image_url': downloadUrl,
        'former_image_urls': FieldValue.arrayUnion([downloadUrl]),
      });

      // Update state (userData + profileImageUrl)
      final updatedUser =
          Map<String, dynamic>.from(current.userData ?? <String, dynamic>{});
      updatedUser['image_url'] = downloadUrl;

      emit(UserLoaded(
        userData: updatedUser,
        profileImageUrl: downloadUrl,
      ));
    } catch (e) {
      emit(UserError("Foto yukleme hatasi: $e"));
    }
  }

  
  bool validateStudentId(String value) {
  return RegExp(r'^\d{10}$').hasMatch(value);
}
}

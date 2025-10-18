import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_page/notifications.dart';

class UserService {
  Map<String, dynamic>? userData;
  String? imageUrl;
  bool isLoading = true;

  Future<Map<String, dynamic>?> getUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final String? email = auth.currentUser?.email;

    String term;
    final m = DateTime.now().month;
    if (m == 9 || m == 10 || m == 11 || m == 12 || m == 1) {
      term = "GÜZ";
    } else if (m == 2 || m == 3 || m == 4 || m == 5) {
      term = "BAHAR";
    } else {
      term = "YAZ";
    }

    if (email == null) {
      return null; // Kullanıcı giriş yapmamış
    }

    try {
      // Kullanıcıyı e-posta ile Firestore'da bul
      final QuerySnapshot userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final Map<String, dynamic> userData =
            userQuery.docs.first.data() as Map<String, dynamic>;

        return {
          'name': userData['Name'] ?? '',
          'surname': userData['Surname'] ?? '',
          'email': userData['email'] ?? '',
          'image_url': userData['image_url'] ?? '',
          'student_id': userData['student_id'] ?? '',
          'username': userData['username'] ?? '',
          // 'lessonsList': userData[DateTime.now().year.toString()][term] ?? '',
        };
      }
    } catch (e) {
      print("Firestore'dan kullanıcı bilgileri alınırken hata oluştu: $e");
    }

    return null; // Kullanıcı bulunamazsa veya hata olursa
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await getUserData();

    if (data != null) {
      printColored("Firebase'den gelen kullanıcı verisi: $data",
          "32"); // Gelen veriyi kontrol et

      userData = data;
    } else {
      printColored("Kullanıcı verisi bulunamadı veya null döndü!", "32");
    }
  }

  Future<void> loadProfileImage() async {
    try {
      Map<String, dynamic>? userData =
          await getUserData(); // Kullanıcı bilgilerini al

      if (userData != null && userData['username'] != null) {
        String username = userData['username']; // Kullanıcı adını al

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(username) // username ile belgeyi çek
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          String? fetchedImageUrl =
              userDoc['image_url']; // Profil fotoğrafını al
          print(
              "Firestore'dan gelen image_url: $fetchedImageUrl"); // Kontrol için

          imageUrl = fetchedImageUrl;
        }
      } else {
        print("Kullanıcı adı bulunamadı.");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    } finally {
      isLoading = false;
    }
  }


}




 
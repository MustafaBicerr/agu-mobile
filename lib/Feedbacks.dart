import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;
  File? _selectedFile;
  String? _fileName;

  final feedbacksCollection =
      FirebaseFirestore.instance.collection('feedbacks');

  Future<String?> getUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['username']; // Kullanıcı adı döndür
      } else {
        print("Kullanıcı bulunamadı.");
        return null;
      }
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }

  // Kullanıcı dosya seçtiğinde çağrılan fonksiyon
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  // Dosyayı Firebase Storage'a yükleme fonksiyonu
  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;

    try {
      String filePath =
          "feedback_uploads/${DateTime.now().millisecondsSinceEpoch}_${_fileName}";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(_selectedFile!);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Dosya yükleme hatası: $e");
      return null;
    }
  }

  void _submitFeedback() async {
    if (_feedbackController.text.isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen geri bildiriminizi ve puanınızı girin!"),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? fileUrl = await _uploadFile(); // Dosya yüklenirse URL al
      String? username = await getUsername(); // Kullanıcı adını al

      if (username == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı adı alınamadı.")),
        );
        return;
      }

      DocumentReference feedbackDoc = feedbacksCollection.doc(username);

      // Önceki geri bildirimleri kontrol et
      DocumentSnapshot docSnapshot = await feedbackDoc.get();
      if (docSnapshot.exists) {
        // Eğer belge zaten varsa, eski verileri koruyarak yeni verileri ekleyelim
        await feedbackDoc.update({
          'feedbacks': FieldValue.arrayUnion([
            {
              'rating': _rating,
              'feedback': _feedbackController.text,
              'fileUrl': fileUrl,
              'timestamp':
                  DateTime.now(), // Firestore yerine yerel DateTime kullan
            }
          ]),
          'last_updated': FieldValue
              .serverTimestamp(), // Firestore timestamp'i ana belgeye ekle
        });
      } else {
        // Eğer belge yoksa, yeni bir belge oluştur
        await feedbackDoc.set({
          'feedbacks': [
            {
              'rating': _rating,
              'feedback': _feedbackController.text,
              'fileUrl': fileUrl,
              'timestamp':
                  DateTime.now(), // Firestore yerine DateTime.now() kullan
            }
          ],
          'last_updated': FieldValue
              .serverTimestamp(), // Ana belge içinde güncelleme tarihi
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geri bildiriminiz başarıyla gönderildi!"),
        ),
      );

      // Formu temizle
      _feedbackController.clear();
      setState(() {
        _rating = 0.0;
        _selectedFile = null;
        _fileName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geri Bildirim"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Geri bildiriminizi buraya yazın...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Dosya seçme butonu ve seçilen dosyanın gösterimi
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Dosya Ekle",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 7, 43, 127),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _fileName ?? "Dosya seçilmedi",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Gönder butonu veya yükleme göstergesi
                      Center(
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _submitFeedback,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 7, 43, 127),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Gönder",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

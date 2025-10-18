import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_page/main.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSettingsPageWidget extends StatefulWidget {
  const ProfileSettingsPageWidget({super.key});

  @override
  _ProfileSettingsPageWidgetState createState() =>
      _ProfileSettingsPageWidgetState();
}

class _ProfileSettingsPageWidgetState extends State<ProfileSettingsPageWidget> {
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();

  TextEditingController studentIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isEditingStudentID = false;
  bool isValidStudentID = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }
  UserService userService = UserService();
  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await userService.getUserData();

    if (data != null) {
      setState(() {
        userData = data;
        studentIdController.text = data['student_id'] ?? "";
        emailController.text = data['email'] ?? "";
      });
    }
  }

  void validateStudentId(String value) {
    setState(() {
      isValidStudentID = RegExp(r'^\d{10}$').hasMatch(value);
    });
  }

  void validateEmail(String value) {
    bool isValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value);

    if (!isValid) {
      print("⚠️ Geçersiz e-posta adresi! Lütfen doğru bir e-posta girin.");
    } else {
      print("✅ Geçerli e-posta adresi.");
    }
  }

  Future<void> updateStudentId() async {
    if (userData == null || userData!['username'] == null) return;

    try {
      String username = userData!['username'];
      String newStudentId = studentIdController.text;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .update({
        'student_id': newStudentId,
      });

      setState(() {
        userData!['student_id'] = newStudentId;
        isEditingStudentID = false;
        isValidStudentID = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Öğrenci ID numaranız başarıyla değiştirildi.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Bir sorun oluştu!")));
    }
  }

  void showConfirmationDialogForStudentID() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Onay"),
          content:
              const Text("Öğrenci ID’nizin değiştirilmesini istiyor musunuz?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  studentIdController.text =
                      userData!['student_id']; // Eski haline döndür
                  isEditingStudentID = false;
                  isValidStudentID = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Hayır"),
            ),
            TextButton(
              onPressed: () async {
                await updateStudentId();
                Navigator.of(context).pop();
              },
              child: const Text("Evet"),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheetForImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamerayı Aç'),
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Galeriden seçilen resim: ${image.path}");
      await _uploadImageToFirebase(image);
    }
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("Kameradan çekilen resim: ${image.path}");
      await _uploadImageToFirebase(image);
    }
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    try {
      String username = userData!['username'];

      // Kullanıcıya ait eski fotoğraf URL'lerini Firestore'dan çekiyoruz
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();

      // Kullanıcı verilerinin doğru çekildiğinden emin olalım
      if (userDoc.exists) {
        // 'former_image_urls' alanı var mı kontrol et
        List<dynamic> formerImageUrls = [];

        // Eğer 'former_image_urls' yoksa, yeni bir liste oluştur
        if (userDoc['former_image_urls'] != null) {
          formerImageUrls = List.from(userDoc['former_image_urls']);
        } else {
          // Eğer 'former_image_urls' yoksa, boş bir liste ekle
          await FirebaseFirestore.instance
              .collection('users')
              .doc(username)
              .update({'former_image_urls': []}); // Yeni alanı ekle
          print("former_image_urls alanı yoktu, boş bir liste oluşturuldu.");
        }

        // `former_image_urls`'u kontrol et
        printColored('Former Image URLs: $formerImageUrls', '35');

        // counter'ı formerImageUrls listesinde kaç tane fotoğraf varsa ona göre ayarlıyoruz
        int counter = formerImageUrls.length;

        // Yeni fotoğrafın dosya adını oluştur
        String fileName = '$username' +
            '_${counter + 1}.jpg'; // counter + 1, her yeni fotoğrafta arttırılacak

        // Fotoğrafı Firebase Storage'a yükle
        File file = File(image.path);
        String filePath = 'user_images/$fileName';

        // Firebase Storage'a yükleme
        TaskSnapshot uploadTask =
            await FirebaseStorage.instance.ref(filePath).putFile(file);

        // Yükleme tamamlandığında resmin URL'sini al
        String downloadUrl = await uploadTask.ref.getDownloadURL();

        // Eski fotoğraf URL'sini former_image_urls listesine ekle
        formerImageUrls.add(downloadUrl);

        // Resim URL'sini Firestore'daki kullanıcı belgesine ekle
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({
          'image_url': downloadUrl, // Yeni fotoğrafın URL'sini güncelle
          'former_image_urls': FieldValue.arrayUnion(
              [downloadUrl]), // Listeye eski fotoğraf ekle
        });

        // Resmin başarıyla yüklendiğini bildiren bir mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Profil fotoğrafınız başarıyla yüklendi.")));

        setState(() {
          userData!['image_url'] = downloadUrl;
        });
      } else {
        print("User document not found!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bir hata oluştu, fotoğraf yüklenemedi.")));
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Ayarları"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        // Profil Fotoğrafı
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: (userData!['image_url'] != null &&
                                  userData!['image_url'] != "")
                              ? NetworkImage(userData!['image_url'])
                              : null,
                          child: (userData!['image_url'] == null ||
                                  userData!['image_url'] == "")
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.white),
                            onPressed: () => _showBottomSheetForImage(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // İsim ve Soyisim
                    Text(
                      '${userData!['name']} ${userData!['surname']}',
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20, color: Colors.black),
                    Text(userData!['email']),
                    const SizedBox(height: 20),

                    // Okul Numarası (Editable)
                    TextFormField(
                      controller: studentIdController,
                      readOnly: !isEditingStudentID,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Okul Numarası",
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  isEditingStudentID = true;
                                });
                              },
                            ),
                            if (isEditingStudentID)
                              IconButton(
                                icon: Icon(Icons.check,
                                    color: isValidStudentID
                                        ? Colors.blue
                                        : Colors.grey),
                                onPressed: isValidStudentID
                                    ? showConfirmationDialogForStudentID
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        validateStudentId(value);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

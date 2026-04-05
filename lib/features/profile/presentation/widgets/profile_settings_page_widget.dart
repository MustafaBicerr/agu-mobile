import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agu_mobile/features/app/presentation/pages/app_bootstrap.dart';
import 'package:agu_mobile/features/profile/data/user_data_source.dart';
import 'package:agu_mobile/shared/services/firebase_user_account_service.dart';
import 'package:agu_mobile/shared/services/profile_refresh_notifier.dart';
import 'package:agu_mobile/shared/services/current_user_profile_store.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:agu_mobile/shared/widgets/password_reset_flow.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agu_mobile/shared/utils/image_pick_permissions.dart';

class ProfileSettingsPageWidget extends StatefulWidget {
  const ProfileSettingsPageWidget({super.key});

  @override
  _ProfileSettingsPageWidgetState createState() =>
      _ProfileSettingsPageWidgetState();
}

class _ProfileSettingsPageWidgetState extends State<ProfileSettingsPageWidget> {
  final UserDataSource _userDataSource = UserDataSource();
  final FirebaseUserAccountService _accountService = FirebaseUserAccountService();
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

  Future<void> loadUserData() async {
    final cached = CurrentUserProfileStore.instance.profileForUi;
    if (cached != null && mounted) {
      setState(() {
        userData = Map<String, dynamic>.from(cached);
        studentIdController.text = cached['student_id'] ?? '';
        emailController.text = cached['email'] ?? '';
      });
    }

    final data =
        await _userDataSource.fetchCurrentUserData(includeRawDoc: true);

    if (!mounted) return;
    if (data != null) {
      CurrentUserProfileStore.instance.replaceProfile(data);
      final ui = Map<String, dynamic>.from(data)..remove('_firestore');
      setState(() {
        userData = ui;
        studentIdController.text = ui['student_id'] ?? '';
        emailController.text = ui['email'] ?? '';
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
      ProfileRefreshNotifier.notify();

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
    if (!await ensureGalleryPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Galeri erişimi için izin gerekir.')),
        );
      }
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Galeriden seçilen resim: ${image.path}");
      await _uploadImageToFirebase(image);
    }
  }

  Future<void> _openCamera() async {
    if (!await ensureCameraPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera için izin gerekir.')),
        );
      }
      return;
    }
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
        ProfileRefreshNotifier.notify();
      } else {
        print("User document not found!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bir hata oluştu, fotoğraf yüklenemedi.")));
      print("Error uploading image: $e");
    }
  }

  Future<void> _showDeleteAccountFlow() async {
    final username = userData?['username'] as String?;
    if (username == null || username.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı sil'),
        content: const Text(
          'Hesabınız ve profil verileriniz kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Devam', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final passwordController = TextEditingController();
    bool obscure = true;
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Şifre doğrulama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Güvenlik için hesabınızı silmeden önce şifrenizi girin.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setLocal(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final p = passwordController.text;
                if (p.isEmpty) return;
                Navigator.pop(ctx, p);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty || !mounted) return;

    DocumentSnapshot<Map<String, dynamic>>? userSnap;
    try {
      userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();
    } catch (_) {}

    final data = userSnap?.data();
    final imageUrl = data?['image_url'] as String?;
    final former = data?['former_image_urls'] as List<dynamic>?;

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _accountService.deleteAccountAfterReauth(
        password: password,
        firestoreDocId: username,
        profileImageUrl: imageUrl,
        formerImageUrls: former,
      );
      if (!mounted) return;
      Navigator.of(context).pop();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);

      CurrentUserProfileStore.instance.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesabınız silindi.')),
      );

      AppBootstrap.restartAtAuth(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (!mounted) return;
      String msg = e.message ?? 'İşlem başarısız.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Şifre hatalı. Lütfen tekrar deneyin.';
      } else if (e.code == 'requires-recent-login') {
        msg =
            'Güvenlik nedeniyle oturumunuzu yenilemeniz gerekiyor. Çıkış yapıp tekrar giriş yaptıktan sonra tekrar deneyin.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 28),
                    TextButton(
                      onPressed: () => showPasswordResetFlow(context),
                      child: const Text('Şifremi unuttum'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _showDeleteAccountFlow,
                      child: const Text('Hesabımı sil'),
                    ),
                  ],
                ),
                ),
              ),
      ),
    );
  }
}

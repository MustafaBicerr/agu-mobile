import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_page/services/notification_service.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onPickImage,
  });

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();

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
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  Future<void> _openCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    try {
      String username = userData!['username'];

      // Firebase Storage'da fotoğraf için dosya adını kullanıcı adıyla aynı yapalım
      String fileName = '$username.jpg'; // Kullanıcı adıyla aynı olacak

      // Fotoğrafı Firebase Storage'a yükle
      File file = File(image.path);
      String filePath = 'user_images/$fileName';

      // Firebase Storage'a yükleme
      TaskSnapshot uploadTask =
          await FirebaseStorage.instance.ref(filePath).putFile(file);

      // Yükleme tamamlandığında resmin URL'sini al
      String downloadUrl = await uploadTask.ref.getDownloadURL();

      // Resim URL'sini Firestore'daki kullanıcı belgesine ekle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .update({
        'image_url': downloadUrl, // Yeni fotoğrafın URL'sini güncelle
      });

      // Resmin başarıyla yüklendiğini bildiren bir mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profil fotoğrafınız başarıyla yüklendi.")));

      setState(() {
        userData!['image_url'] = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bir hata oluştu, fotoğraf yüklenemedi.")));
      print("Error uploading image: $e");
    }
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          child: const Icon(
            Icons.person_rounded,
            size: 60,
            color: Colors.grey,
          ),
        ),
        TextButton.icon(
          onPressed: () => _showBottomSheetForImage(context),
          icon: const Icon(
            Icons.add_a_photo_outlined,
            color: Colors.white,
          ),
          label: const Text(
            'Add an image',
            style: TextStyle(
                //color: Theme.of(context).colorScheme.primary,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}

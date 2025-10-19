import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/auth/presentation/bloc/user/user_cubit.dart';


class ProfileSettingsPageWidget extends StatefulWidget {
  const ProfileSettingsPageWidget({super.key});

  @override
  _ProfileSettingsPageWidgetState createState() =>
      _ProfileSettingsPageWidgetState();
}

class _ProfileSettingsPageWidgetState extends State<ProfileSettingsPageWidget> {
  Map<String, dynamic>? userData;


  TextEditingController studentIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isEditingStudentID = false;
  bool isValidStudentID = false;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadAllUserData();
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
                  context.read<UserCubit>().pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamerayı Aç'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<UserCubit>().pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
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
                // Eski haline dön
                if (userData != null) {
                  setState(() {
                    studentIdController.text = userData!['student_id'] ?? '';
                    isEditingStudentID = false;
                    isValidStudentID = false;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Hayır"),
            ),
            TextButton(
              onPressed: () async {
                final newId = studentIdController.text.trim();
                await context.read<UserCubit>().updateStudentId(newId);
                setState(() {
                  isEditingStudentID = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Evet"),
            ),
          ],
        );
      },
    );
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
                        final isValid =
                            context.read<UserCubit>().validateStudentId(value);
                        setState(() {
                          isValidStudentID = isValid;
                        });
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agu_mobile/shared/widgets/user_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agu_mobile/shared/widgets/password_reset_flow.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  final Future<void> Function() onSignedIn;

  const AuthScreen({
    super.key,
    required this.onSignedIn,
  });

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _enteredName = '';
  var _enteredSurname = '';
  var _enteredStudentID = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    if (!_isLogin) {
      final accepted = await _showRegistrationConsentDialog();
      if (!accepted) {
        return;
      }
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Kullanıcı sayısını belirleme
        final usersCollection = FirebaseFirestore.instance.collection('users');
        final userCountSnapshot = await usersCollection.get();
        final userCount = userCountSnapshot.size + 1;

        // Yeni kullanıcı dosya adını oluşturma
        String formattedUsername = _enteredUsername.replaceAll(' ', '_');
        String documentId =
            '${formattedUsername}_$userCount'; // Firestore doc ID
        String fileName = '$documentId.jpg'; // Fotoğraf dosya adı

        String? imageUrl;
        if (_selectedImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(fileName);

          await storageRef.putFile(_selectedImage!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Kullanıcı belgesini oluştururken doc ID'yi belirliyoruz
        await usersCollection.doc(documentId).set({
          'Name': _enteredName,
          'Surname': _enteredSurname,
          'username': _enteredUsername + '_$userCount',
          'email': _enteredEmail,
          'former_image_urls': [],
          'image_url': imageUrl ?? '',
          'student_id': _enteredStudentID
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);

      await widget.onSignedIn();
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<bool> _showRegistrationConsentDialog() async {
    bool accepted = false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Row(
              children: [
                Text('📘'),
                SizedBox(width: 8),
                Text('Bilgilendirme'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AGU Mobile, Abdullah Gul Universitesi'nin resmi uygulamasi degildir.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Bu uygulama, AGU ogrencileri tarafindan gelistirilen bagimsiz bir ogrenci projesidir.",
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Kayit olarak uygulamanin resmi bir platform olmadigini ve verilerinizin yalnizca uygulama islevselligi icin kullanilacagini kabul etmis olursunuz.",
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: accepted,
                        onChanged: (value) {
                          setDialogState(() {
                            accepted = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Okudum ve kabul ediyorum",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Vazgec",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: accepted
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text(
                  "Kabul Et ve Kayit Ol",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  void _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[AGU_BOOT] AuthScreen.initState — login/register UI mounted');
    _loadRememberMe();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //backgroundColor: Theme.of(context).colorScheme.primary,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 65,
              ),
              Container(
                margin: const EdgeInsets.only(
                    // top: 30,
                    // bottom: 20,
                    // left: 20,
                    // right: 20,
                    ),
                //width: 700,
                width: MediaQuery.of(context).size.width * 0.6, // Ekranın %80'i
                child: Image.asset(
                  'assets/images/agu_kilit_ekrani.jpg',
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 254, 254, 254), //rgba(254,254,254,255)
                  Color.fromARGB(255, 204, 28, 28),
                  //Colors.white,
                ], stops: [
                  0.01,
                  0.8,
                  //1
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10), // Card'ın üstüne 180 piksel boşluk
                  child: Card(
                    elevation: 0,
                    color: const Color.fromARGB(0, 255, 255,
                        255), // Card'ın arka plan rengini şeffaf yap
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: const Text(
                                    'Dikkat: Bu uygulama üniversite tarafından yayınlanan resmi bir uygulama değildir. '
                                    'Kayıt sırasında Zimbra, Canvas veya SIS şifrelerinizi kullanmamanız önerilir.',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              if (!_isLogin)
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    setState(() {
                                      _selectedImage = pickedImage;
                                    });
                                  },
                                ),
                              if (!_isLogin)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: const InputDecoration(
                                          labelText: 'İsim',
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                        enableSuggestions: false,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value.trim().length < 3) {
                                            return 'Lütfen geçerli bir isim girin';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _enteredName = value!;
                                          _enteredUsername = value;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // İki alan arasında boşluk bırakır
                                    Expanded(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: const InputDecoration(
                                          labelText: 'Soyisim',
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                        enableSuggestions: false,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value.trim().length < 3) {
                                            return 'Lütfen geçerli bir soyisim girin';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _enteredSurname = value!;
                                          _enteredUsername =
                                              '$_enteredUsername.$value';
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              if (!_isLogin)
                                TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    labelText: 'Öğrenci Numarası',
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length != 10 ||
                                        value.contains(
                                            'qwertyuıopğüasdfghjklşizxcvbnmöç,.<>|"!#+%&/()?_-}][{}]')) {
                                      return 'Lütfen geçerli bir numara girin';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredStudentID = value!;
                                  },
                                ),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Adresi',
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Lütfen geçerli bir Email hesabı girin.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                              TextFormField(
                                controller:
                                    _passwordController, // Şifreyi kontrol eden controller
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText:
                                    !_isPasswordVisible, // Şifreyi gizleyip/göstermek için
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Şifre en az 6 karakterden oluşmalıdır!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredPassword = value!;
                                },
                              ),
                              if (!_isLogin)
                                TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Şifrenizi onaylayın',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText:
                                      !_isConfirmPasswordVisible, // Şifreyi gizleyip/göstermek için
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifrenizi tekrar girin!';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Girdiğiniz şifreler eşleşmiyor, lütfen tekrar deneyin.';
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(height: 12),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                Row(
                                  children: [
                                    const SizedBox(width: 35),
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (newValue) async {
                                        setState(() {
                                          _rememberMe = newValue!;
                                        });
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setBool('remember_me',
                                            _rememberMe); // Değeri hemen kaydet
                                      },
                                    ),
                                    const Text(
                                      'Beni Hatırla',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(width: 45),
                                    ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        _isLogin ? 'Giriş yap' : 'Kayıt ol',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              if (!_isAuthenticating && _isLogin)
                                TextButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    showPasswordResetFlow(
                                      context,
                                      registeredOrSuggestedEmail:
                                          _emailController.text.trim(),
                                    );
                                  },
                                  child: const Text(
                                    'Şifremi unuttum',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (!_isAuthenticating)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(
                                    _isLogin
                                        ? 'Yeni hesap oluştur'
                                        : 'Zaten bir hesabım var',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

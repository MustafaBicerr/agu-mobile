
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/core/notification/notification_service.dart';
import 'package:home_page/featuers/auth/domain/usecases/user_image_picker.dart';
import 'package:home_page/featuers/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:home_page/featuers/auth/presentation/bloc/auth/auth_state.dart';
import 'package:home_page/main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  // local form fields (UI kontrolü)
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _enteredName = '';
  var _enteredSurname = '';
  var _enteredStudentID = '';
  File? _selectedImage;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _passwordController = TextEditingController();

  Future<void> _goHome() async {
    // Navigation after success
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MyApp(notificationService: NotificationService()),
      ),
    );
  }

  void _submit(AuthState state, AuthCubit cubit) async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();

    if (state.isLogin) {
      await cubit.signIn(
        email: _enteredEmail,
        password: _enteredPassword,
        onSuccess: _goHome,
      );
    } else {
      await cubit.signUp(
        email: _enteredEmail,
        password: _enteredPassword,
        name: _enteredName,
        surname: _enteredSurname,
        usernameBase: _enteredUsername, // name + surname’den build ediyordun
        studentId: _enteredStudentID,
        pickedImage: _selectedImage,
        onSuccess: _goHome,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // remember me + auto login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().loadRememberAndAutoLogin(onAutoLogin: _goHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<AuthCubit>();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 65),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Image.asset('assets/images/agu_kilit_ekrani.jpg'),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 254, 254, 254),
                          Color.fromARGB(255, 204, 28, 28),
                        ],
                        stops: [0.01, 0.8],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Card(
                        elevation: 0,
                        color: const Color.fromARGB(0, 255, 255, 255),
                        margin: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _form,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!state.isLogin)
                                    UserImagePicker(
                                      onPickImage: (pickedImage) {
                                        setState(() {
                                          _selectedImage = pickedImage;
                                        });
                                      },
                                    ),
                                  if (!state.isLogin)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            style: const TextStyle(color: Colors.black),
                                            decoration: const InputDecoration(
                                              labelText: 'İsim',
                                              labelStyle: TextStyle(color: Colors.black),
                                            ),
                                            enableSuggestions: false,
                                            validator: (value) {
                                              if (value == null || value.isEmpty || value.trim().length < 3) {
                                                return 'Lütfen geçerli bir isim girin';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              _enteredName = value!;
                                              _enteredUsername = value!;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            style: const TextStyle(color: Colors.black),
                                            decoration: const InputDecoration(
                                              labelText: 'Soyisim',
                                              labelStyle: TextStyle(color: Colors.black),
                                            ),
                                            enableSuggestions: false,
                                            validator: (value) {
                                              if (value == null || value.isEmpty || value.trim().length < 3) {
                                                return 'Lütfen geçerli bir soyisim girin';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              _enteredSurname = value!;
                                              _enteredUsername = '$_enteredUsername.${value!}';
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (!state.isLogin)
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
                                            value.contains('qwertyuıopğüasdfghjklşizxcvbnmöç,.<>|"!#+%&/()?_-}][{}]')) {
                                          return 'Lütfen geçerli bir numara girin';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _enteredStudentID = value!;
                                      },
                                    ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Email Adresi',
                                      labelStyle: TextStyle(color: Colors.black),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                        return 'Lütfen geçerli bir Email hesabı girin.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredEmail = value!;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      labelText: 'Şifre',
                                      labelStyle: const TextStyle(color: Colors.black),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: !_isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.trim().length < 6) {
                                        return 'Şifre en az 6 karakterden oluşmalıdır!';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enteredPassword = value!;
                                    },
                                  ),
                                  if (!state.isLogin)
                                    TextFormField(
                                      style: const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText: 'Şifrenizi onaylayın',
                                        labelStyle: const TextStyle(color: Colors.black),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !_isConfirmPasswordVisible,
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

                                  if (state.isLoading)
                                    const CircularProgressIndicator(),

                                  if (!state.isLoading)
                                    Row(
                                      children: [
                                        const SizedBox(width: 35),
                                        Checkbox(
                                          value: state.rememberMe,
                                          onChanged: (v) {
                                            if (v != null) {
                                              context.read<AuthCubit>().setRememberMe(v);
                                            }
                                          },
                                        ),
                                        const Text('Beni Hatırla', style: TextStyle(color: Colors.black)),
                                        const SizedBox(width: 45),
                                        ElevatedButton(
                                          onPressed: () => _submit(state, cubit),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                          child: Text(
                                            state.isLogin ? 'Giriş yap' : 'Kayıt ol',
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),

                                  if (!state.isLoading)
                                    TextButton(
                                      onPressed: () => cubit.toggleMode(),
                                      child: Text(
                                        state.isLogin ? 'Yeni hesap oluştur' : 'Zaten bir hesabım var',
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
              );
            },
          ),
        ),
      ),
    );
  }
}

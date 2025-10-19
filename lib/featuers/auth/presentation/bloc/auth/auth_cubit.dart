
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:home_page/featuers/auth/domain/repository/auth_repository.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthState.initial());

  Future<void> loadRememberAndAutoLogin({
    required Future<void> Function() onAutoLogin,
  }) async {
    final canAuto = await _repo.canAutoLogin();
    final remember = await _repo.getRememberMe();
    emit(state.copyWith(rememberMe: remember));

    if (canAuto) {
      await onAutoLogin();
    }
  }

  void toggleMode() {
    emit(state.copyWith(isLogin: !state.isLogin, errorMessage: null));
  }

  Future<void> setRememberMe(bool value) async {
    await _repo.setRememberMe(value);
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> signIn({
    required String email,
    required String password,
    required Future<void> Function() onSuccess,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repo.signIn(email: email, password: password);
      await onSuccess();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String usernameBase,
    required String studentId,
    File? pickedImage,
    required Future<void> Function() onSuccess,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repo.signUp(
        email: email,
        password: password,
        name: name,
        surname: surname,
        usernameBase: usernameBase,
        studentId: studentId,
        pickedImage: pickedImage,
      );
      await onSuccess();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}

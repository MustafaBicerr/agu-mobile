
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLogin;          
  final bool isLoading;
  final bool rememberMe;
  final String? errorMessage;

  const AuthState({
    required this.isLogin,
    required this.isLoading,
    required this.rememberMe,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState(isLogin: true, isLoading: false, rememberMe: false);

  AuthState copyWith({
    bool? isLogin,
    bool? isLoading,
    bool? rememberMe,
    String? errorMessage,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLogin, isLoading, rememberMe, errorMessage];
}

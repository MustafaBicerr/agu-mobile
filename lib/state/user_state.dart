import 'package:equatable/equatable.dart';


abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  @override
  List<Object> get props => [DateTime.now()]; // Tekrar yükleme için kullanışlı
}

class UserLoaded extends UserState {
  final Map<String, dynamic>? userData;
  final String? profileImageUrl;

  const UserLoaded({
    this.userData,
    this.profileImageUrl,
  });

  // State'in ne zaman değiştiğini anlamak için Equatable kullanılır
  @override
  List<Object?> get props => [userData, profileImageUrl];
  
  // Mevcut state'i güncelleyerek yeni bir state oluşturmayı sağlar
  UserLoaded copyWith({
    Map<String, dynamic>? userData,
    String? profileImageUrl,
  }) {
    return UserLoaded(
      userData: userData ?? this.userData,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
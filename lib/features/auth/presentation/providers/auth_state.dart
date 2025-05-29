part of 'auth_notifier.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthMessage extends AuthState {
  final String message;
  AuthMessage(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

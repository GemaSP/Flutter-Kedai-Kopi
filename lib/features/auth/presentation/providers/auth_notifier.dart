import 'package:coffe_shop/core/utils/firebase_auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffe_shop/features/auth/domain/usecases/login_with_email.dart';
import 'package:coffe_shop/features/auth/domain/usecases/register_with_email.dart';
import 'package:coffe_shop/features/auth/domain/usecases/reset_password.dart';
import 'package:coffe_shop/features/auth/domain/usecases/logout.dart';
import 'package:coffe_shop/features/auth/domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithEmail loginWithEmail;
  final RegisterWithEmail registerWithEmail;
  final ResetPassword resetPassword;
  final Logout logout;

  AuthNotifier({
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.resetPassword,
    required this.logout,

    }) : super(AuthInitial());
  

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await loginWithEmail(email, password);
      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      final errorMessage = FirebaseAuthExceptionMapper.map(e.code);
      state = AuthError(errorMessage);
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = AuthLoading();
    try {
      final user = await registerWithEmail(email, password, name);
      state = AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      final errorMessage = FirebaseAuthExceptionMapper.map(e.code);
      state = AuthError(errorMessage);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = AuthLoading();
    try {
      await resetPassword(email);
      state = AuthMessage('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      final errorMessage = FirebaseAuthExceptionMapper.map(e.code);
      state = AuthError(errorMessage);
    }
  }

  Future<void> signOut() async {
    await logout(); 
    state = AuthLoading();
    try {
      state = AuthInitial();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}
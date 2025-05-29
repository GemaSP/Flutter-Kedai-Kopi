import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';
import 'usecase_provider.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final loginWithEmail = ref.watch(loginWithEmailProvider);
    final registerWithEmail = ref.watch(registerWithEmailProvider);
    final resetPassword = ref.watch(resetPasswordProvider);
    final logout = ref.watch(logoutProvider);
    return AuthNotifier(
      loginWithEmail: loginWithEmail,
      registerWithEmail: registerWithEmail,
      resetPassword: resetPassword,
      logout: logout,
    );
  },
);
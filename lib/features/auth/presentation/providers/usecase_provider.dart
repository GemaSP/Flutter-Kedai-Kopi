import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffe_shop/features/auth/domain/usecases/login_with_email.dart';
import 'package:coffe_shop/features/auth/domain/usecases/register_with_email.dart';
import 'package:coffe_shop/features/auth/domain/usecases/reset_password.dart';
import 'package:coffe_shop/features/auth/domain/usecases/logout.dart';
import 'auth_repository_provider.dart';

final loginWithEmailProvider = Provider<LoginWithEmail>(
  (ref) => LoginWithEmail(ref.watch(authRepositoryProvider)),
);

final registerWithEmailProvider = Provider<RegisterWithEmail>(
  (ref) => RegisterWithEmail(ref.watch(authRepositoryProvider)),
);

final resetPasswordProvider = Provider<ResetPassword>(
  (ref) => ResetPassword(ref.watch(authRepositoryProvider)),
);

final logoutProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

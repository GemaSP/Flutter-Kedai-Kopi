import 'package:coffe_shop/core/utils/device_utils.dart';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_notifier.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) async {
      if (next is AuthSuccess) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await simpanAktivitasLogin(user);
        }

        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }

      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: CoffeeThemeColors.background,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: CoffeeThemeColors.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.shade200.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('☕', style: TextStyle(fontSize: 64)),
                SizedBox(height: 12),
                Text(
                  'Login to Coffee Shop',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CoffeeThemeColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24),
                LoginForm(authNotifier: authNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

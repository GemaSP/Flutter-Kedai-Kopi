import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/auth/presentation/pages/login_page.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_notifier.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffe_shop/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AuthSuccess) {
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
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CoffeeThemeColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24),
                RegisterForm(authNotifier: authNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

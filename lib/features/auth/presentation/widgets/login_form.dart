import 'package:coffe_shop/core/utils/validators.dart';
import 'package:coffe_shop/core/widgets/buttons/primary_button.dart';
import 'package:coffe_shop/core/widgets/input/my_input_field.dart';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/auth/presentation/pages/login_page.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/auth_notifier.dart'; // pastikan path ini sesuai

class LoginForm extends StatefulWidget {
  final AuthNotifier authNotifier;

  const LoginForm({super.key, required this.authNotifier});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyInputField(
            controller: emailController,
            prefixIcon: Icon(Icons.email),
            labelText: 'Email',
            validator: Validators.validateEmail,
            hinText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            hoverColor: Color(0xFF6F4E37),
          ),
          SizedBox(height: 16),
          MyInputField(
            labelText: 'Password',
            controller: passwordController,
            obscureText: _isPasswordHidden,
            prefixIcon: Icon(Icons.password),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
              icon: Icon(
                _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            validator: Validators.validatePassword,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text(
                'Lupa password?',
                style: TextStyle(
                  color: CoffeeThemeColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Consumer(
            builder: (_, ref, __) {
              final authState = ref.watch(authNotifierProvider);
              return PrimaryButton(
                title: 'Login',
                isLoading: authState is AuthLoading,
                onTap:
                    authState is AuthLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            widget.authNotifier.login(
                              emailController.text,
                              passwordController.text,
                            );
                          }
                        },
              );
            },
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tidak punya akun? "),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: CoffeeThemeColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

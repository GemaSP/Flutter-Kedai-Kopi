import 'package:coffe_shop/core/utils/validators.dart';
import 'package:coffe_shop/core/widgets/buttons/primary_button.dart';
import 'package:coffe_shop/core/widgets/input/my_input_field.dart';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_notifier.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class RegisterForm extends StatefulWidget {
  final AuthNotifier authNotifier;
  const RegisterForm({super.key, required this.authNotifier});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController namaController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    namaController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyInputField(
            labelText: 'Nama',
            controller: namaController,
            prefixIcon: Icon(Icons.person),
            validator:
                (value) =>
                    Validators.validateRequired(value, fieldname: 'Nama'),
          ),
          Gap(16),
          MyInputField(
            labelText: 'Email',
            controller: emailController,
            prefixIcon: Icon(Icons.email),
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          Gap(16),
          MyInputField(
            controller: passwordController,
            labelText: 'Password',
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
          Gap(16),
          Consumer(
            builder: (_, ref, __) {
              final authState = ref.watch(authNotifierProvider);
              return PrimaryButton(
                title: 'Daftar',
                isLoading: authState is AuthLoading,
                onTap:
                    authState is AuthLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            widget.authNotifier.register(
                              emailController.text,
                              passwordController.text,
                              namaController.text,
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
              Text("Sudah punya akun? "),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Login',
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

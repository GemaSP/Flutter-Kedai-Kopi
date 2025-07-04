import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:flutter/material.dart';

class MyInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? hinText;
  final TextInputType keyboardType;
  final Color hoverColor;

  const MyInputField({
    super.key,
    this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.hinText,
    this.keyboardType = TextInputType.text,
    this.hoverColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelStyle: TextStyle(
          // warna label saat fokus
          color: CoffeeThemeColors.primary,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hinText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: CoffeeThemeColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CoffeeThemeColors.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      cursorColor: CoffeeThemeColors.primary,
    );
  }
}

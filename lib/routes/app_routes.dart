import 'package:coffe_shop/features/main/presentation/pages/main_page.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:coffe_shop/features/product/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:coffe_shop/features/auth/presentation/pages/login_page.dart';
import 'package:coffe_shop/features/auth/presentation/pages/register_page.dart';
import 'package:coffe_shop/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:coffe_shop/features/home/presentation/pages/home_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forgot-password': (context) => const ForgotPasswordPage(),
  '/home': (context) => const HomePage(),
  '/main': (context) => const MainPage(), // Ganti dengan MainPage jika sudah ada
};

/// Dynamic route (dengan argumen)
Route<dynamic>? generateRoute(RouteSettings settings) {
  if (settings.name == '/product_detail') {
    final product = settings.arguments as Product;
    return MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product),
    );
  }

  // Optional: fallback route
  return MaterialPageRoute(
    builder: (_) => const Scaffold(
      body: Center(child: Text('404 - Page not found')),
    ),
  );
}
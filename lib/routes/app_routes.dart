import 'package:coffe_shop/features/account/presentation/pages/aktivitasperangkat_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/editprofil_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/gantipassword_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/hapusakun_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/pesanansaya_page.dart';
import 'package:coffe_shop/features/checkout/presentation/pages/pesanan_berhasil.dart';
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
  '/main': (context) => const MainPage(),
  '/pesanan-saya': (context) => const PesananSayaPage(),
  // Tambah lainnya jika pakai halaman sukses
  '/pesanan-berhasil': (context) => const PesananBerhasilPage(),
  '/edit-profile': (context) => const EditProfilePage(),
  '/change-password': (context) => const ChangePasswordPage(),
  '/delete-account': (context) => const DeleteAccountPage(),
  '/device-activity': (context) => const DeviceActivityPage(),
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
    builder:
        (_) =>
            const Scaffold(body: Center(child: Text('404 - Page not found'))),
  );
}

import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/account/presentation/pages/account_page.dart';
import 'package:coffe_shop/features/cart/presentation/pages/cart_page.dart';
import 'package:coffe_shop/features/chat/presentation/pages/chat_page.dart';
import 'package:coffe_shop/features/favorite/presentation/pages/favorite_page.dart';
import 'package:coffe_shop/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Widget> _pages = [
    HomePage(),
    CartPage(), // Pastikan CartPage sudah diimport
    ChatPage(),
    AccountPage(), // Pastikan AccountPage sudah diimport
  ];

  void _onItemTapped(int index) {
    final user = FirebaseAuth.instance.currentUser;

    // Cek jika index adalah Akun (misalnya index ke-4)
    if (index == 3 && user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shoulPop = await _showBackDialog() ?? false;
        if (context.mounted && shoulPop) {
          SystemNavigator.pop();
        }
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomAppBar(
          color: CoffeeThemeColors.primary,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: SizedBox(
            height: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.shopping_bag, 'Keranjang', 1),
                _buildNavItem(Icons.chat, 'Chat', 2),
                _buildNavItem(Icons.person, 'Akun', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.yellow : Colors.white),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.yellow : Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showBackDialog() {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Don't exit
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit
                child: const Text('Yes'),
              ),
            ],
          ),
    );
  }
}

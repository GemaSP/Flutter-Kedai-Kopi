// lib/features/home/presentation/widgets/banner_widget.dart
import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/bg.png'), // Ganti dengan path gambar yang sesuai
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

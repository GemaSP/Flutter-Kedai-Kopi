import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: const [
                    Icon(Icons.coffee, size: 64, color: Colors.brown),
                    SizedBox(height: 10),
                    Text(
                      'CoffeeShop App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Versi 1.0.0', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi ini dibuat untuk memudahkan pelanggan dalam memesan kopi favorit mereka dari mana saja dan kapan saja. Dengan fitur pemesanan online, notifikasi real-time, serta pelacakan pesanan, pengalaman ngopi jadi makin seru!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Developer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dibuat dengan ❤️ oleh Tim CoffeeDev',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ganti dengan fungsi email atau WA kalau perlu
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text('Hubungi Kami'),
                            content: const Text(
                              'Email: gesap02@gmail.com\nWhatsApp: +62 858-1100-0360',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Tutup',
                                  style: TextStyle(
                                    color: CoffeeThemeColors.primary,
                                  ),
                                ),
                              ),
                            ],
                            backgroundColor: CoffeeThemeColors.background,
                          ),
                    );
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Hubungi Kami'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: CoffeeThemeColors.primary,
                    foregroundColor: CoffeeThemeColors.background,
                    iconColor: CoffeeThemeColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

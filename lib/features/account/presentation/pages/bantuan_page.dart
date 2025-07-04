import 'package:flutter/material.dart';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanHubungiKamiPage extends StatelessWidget {
  const BantuanHubungiKamiPage({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'gesap02@gmail.com',
      query:
          'subject=Bantuan%20Customer&body=Halo%20tim%20CoffeeShop,%0ASaya%20butuh%20bantuan...',
    );
    await launchUrl(emailLaunchUri);
  }

  void _launchWhatsApp() async {
    const phone = '+6285811000360';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phone?text=Halo%20tim%20CoffeeShop,%20saya%20butuh%20bantuan.',
    );
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Bagaimana cara memesan kopi?',
        'answer':
            'Pilih produk yang diinginkan, masukkan ke keranjang, dan lanjutkan ke pembayaran.',
      },
      {
        'question': 'Bagaimana jika pesanan saya terlambat?',
        'answer':
            'Silakan hubungi kami melalui email atau WhatsApp untuk kami bantu cek statusnya.',
      },
      {
        'question': 'Bagaimana cara membatalkan pesanan?',
        'answer':
            'Pembatalan dapat dilakukan sebelum pesanan dikonfirmasi oleh barista.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan / Hubungi Kami'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Pertanyaan Umum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...faqs.map(
              (faq) => ExpansionTile(
                title: Text(faq['question']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(faq['answer']!),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 40),
            const Text(
              'Butuh bantuan langsung?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.mail),
              label: const Text('Kirim Email'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: CoffeeThemeColors.primary,
                foregroundColor: CoffeeThemeColors.background,
                iconColor: CoffeeThemeColors.background
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat),
              label: const Text('Chat via WhatsApp'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: CoffeeThemeColors.primary,
                foregroundColor: CoffeeThemeColors.background,
                iconColor: CoffeeThemeColors.background
              ),
            ),
          ],
        ),
      ),
    );
  }
}

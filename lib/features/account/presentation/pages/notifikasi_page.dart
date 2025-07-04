import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  // Contoh data dummy notifikasi
  List<Map<String, String>> get dummyNotifications => [
        {
          'title': 'Pesanan Berhasil',
          'message': 'Pesanan kamu dengan ID #123456 berhasil diproses.',
          'time': '1 jam lalu'
        },
        {
          'title': 'Promo Spesial!',
          'message': 'Nikmati diskon 20% untuk semua minuman hari ini!',
          'time': '3 jam lalu'
        },
        {
          'title': 'Alamat Tersimpan',
          'message': 'Alamat baru kamu telah berhasil ditambahkan.',
          'time': 'Kemarin'
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: dummyNotifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dummyNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = dummyNotifications[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.orange),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['message']!),
                        const SizedBox(height: 6),
                        Text(
                          item['time']!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

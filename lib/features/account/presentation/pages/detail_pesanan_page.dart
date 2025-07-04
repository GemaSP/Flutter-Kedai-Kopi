import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPesananPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const DetailPesananPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final items = Map<String, dynamic>.from(orderData['items'] ?? {});
    final status = orderData['status'] ?? 'Menunggu';
    final alamat = orderData['alamat'] ?? '-';
    final metode = orderData['metodePembayaran'] ?? '-';
    final total = orderData['total'] ?? 0;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      orderData['createdAt'] is int
          ? orderData['createdAt']
          : int.tryParse(orderData['createdAt'].toString()) ?? 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Pesanan ID: #$orderId',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              "Alamat Pengiriman",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(alamat),
            const SizedBox(height: 12),

            Text(
              "Metode Pembayaran",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(metode),
            const SizedBox(height: 12),

            Text(
              "Tanggal Pesan",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(DateFormat('dd MMM yyyy, HH:mm').format(createdAt)),
            const Divider(height: 32),

            const Text(
              "Daftar Produk",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...items.entries.map((e) {
              final item = Map<String, dynamic>.from(e.value);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item['nama'] ?? '-'),
                subtitle: Text("Size: ${item['size']}, Qty: ${item['qty']}"),
                trailing: Text(
                  "Rp ${NumberFormat('#,###', 'id_ID').format(item['subtotal'] ?? 0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),

            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16)),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

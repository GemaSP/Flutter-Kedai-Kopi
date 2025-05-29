import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PesananSayaPage extends StatelessWidget {
  const PesananSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'ORD001',
        'status': 'Menunggu',
        'total': 75000,
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'ORD002',
        'status': 'Diproses',
        'total': 120000,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 'ORD003',
        'status': 'Selesai',
        'total': 99000,
        'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final formattedDate = DateFormat(
            'dd MMM yyyy, HH:mm',
          ).format(order['timestamp']);
          final statusColor = getStatusColor(order['status']);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pesanan #${order['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(order['status']),
                    backgroundColor: statusColor.withOpacity(0.15),
                    labelStyle: TextStyle(color: statusColor),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Total: Rp ${order['total'].toString()}'),
                  Text('Tanggal: $formattedDate'),
                ],
              ),
              onTap: () {
                // TODO: Navigasi ke detail pesanan
              },
            ),
          );
        },
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Dikirim':
        return Colors.purple;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

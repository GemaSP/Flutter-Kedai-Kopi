import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coffe_shop/features/account/presentation/pages/detail_pesanan_page.dart';

class PesananSayaPage extends StatefulWidget {
  const PesananSayaPage({super.key});

  @override
  State<PesananSayaPage> createState() => _PesananSayaPageState();
}

class _PesananSayaPageState extends State<PesananSayaPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu.'));
    }

    final ordersRef = FirebaseDatabase.instance.ref('orders/${user.uid}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ordersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          final rawData = snapshot.data!.snapshot.value;
          if (rawData == null || rawData is! Map) {
            return const Center(child: Text('Belum ada pesanan.'));
          }

          final data = Map<String, dynamic>.from(
            rawData.map(
              (key, value) => MapEntry(
                key.toString(),
                Map<String, dynamic>.from(value as Map),
              ),
            ),
          );

          final List<Map<String, dynamic>> orders =
              data.entries.map((entry) {
                final value = Map<String, dynamic>.from(entry.value);
                return {
                  'id': entry.key,
                  'status': value['status'] ?? 'Menunggu',
                  'total': value['total'] ?? 0,
                  'timestamp': DateTime.fromMillisecondsSinceEpoch(
                    value['createdAt'] is int
                        ? value['createdAt']
                        : int.tryParse(value['createdAt'].toString()) ?? 0,
                  ),
                };
              }).toList();

          // Urutkan pesanan dari terbaru ke terlama
          orders.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return ListView.builder(
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
                      Text(
                        'Total: Rp ${NumberFormat('#,###', 'id_ID').format(order['total'])}',
                      ),
                      Text('Tanggal: $formattedDate'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DetailPesananPage(
                              orderId: order['id'],
                              orderData: data[order['id']],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
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

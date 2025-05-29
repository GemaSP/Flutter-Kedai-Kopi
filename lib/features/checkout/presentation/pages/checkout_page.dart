import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Map<String, bool> selected;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.selected,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _alamat = '';
  String? _metodePembayaran;

  final List<String> _metodePembayaranList = [
    'Transfer Bank',
    'E-Wallet (OVO, Dana, GoPay)',
    'COD (Bayar di Tempat)',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        widget.cartItems.where((item) {
          return widget.selected[item.id] ==
              true; // Menyaring item yang dipilih
        }).toList();

    int total = 0;
    for (var item in selectedItems) {
      final product = item.product; // Akses produk langsung
      final size = item.size; // Akses size langsung
      final qty = item.quantity; // Akses quantity langsung
      final harga = product.harga_produk[size] ?? 0;
      total += harga * qty;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Konfirmasi Pesanan'),
              onPressed: () {
                if (_alamat.isEmpty || _metodePembayaran == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lengkapi alamat dan metode pembayaran.'),
                    ),
                  );
                  return;
                }

                // Simulasi berhasil
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Pesanan Berhasil!'),
                        content: Text(
                          'Alamat: $_alamat\nMetode: $_metodePembayaran\nTotal: Rp${NumberFormat('#,###', 'id_ID').format(total)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
      body:
          selectedItems.isEmpty
              ? const Center(child: Text('Tidak ada item yang dipilih.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====== Alamat Pengiriman ======
                    const Text(
                      'Alamat Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      onChanged: (val) => _alamat = val,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan alamat lengkap...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // ====== Metode Pembayaran ======
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _metodePembayaran,
                      items:
                          _metodePembayaranList.map((metode) {
                            return DropdownMenuItem<String>(
                              value: metode,
                              child: Text(metode),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() {
                            _metodePembayaran = val;
                          }),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pilih metode pembayaran',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ====== Daftar Produk ======
                    const Text(
                      'Produk yang Dibeli',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          final product = item.product;
                          final size = item.size;
                          final qty = item.quantity;
                          final harga = product.harga_produk[size] ?? 0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.path_gambar,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(product.nama_produk),
                            subtitle: Text("Size: $size, Qty: $qty"),
                            trailing: Text(
                              "Rp${NumberFormat('#,###', 'id_ID').format(harga * qty)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(height: 24),

                    // ====== Total Harga ======
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 16)),
                        Text(
                          'Rp${NumberFormat('#,###', 'id_ID').format(total)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }
}

import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/checkout/presentation/pages/pesanan_berhasil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffe_shop/features/cart/presentation/providers/cart_providers.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final Map<String, bool> selected;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.selected,
  });

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String _alamat = '';
  String? _metodePembayaran;
  final _alamatController = TextEditingController();

  final List<String> _metodePembayaranList = [
    'Transfer Bank',
    'E-Wallet (OVO, Dana, GoPay)',
    'COD (Bayar di Tempat)',
  ];

  @override
  void initState() {
    super.initState();
    _loadAlamatUtama();
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadAlamatUtama() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final ref = FirebaseDatabase.instance.ref('users/$userId/alamat');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final alamatData = Map<String, dynamic>.from(snapshot.value as Map);
        final alamatUtama = alamatData.values.firstWhere(
          (e) => e['isMain'] == true,
          orElse: () => null,
        );
        if (alamatUtama != null) {
          setState(() {
            _alamat = alamatUtama['address'] ?? '';
            _alamatController.text = _alamat;
          });
        }
      }
    } catch (e) {
      print("Gagal memuat alamat: $e");
    }
  }

  Future<void> _simpanPesanan(List<CartItem> selectedItems, int total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final DatabaseReference ref = FirebaseDatabase.instance.ref(
      'orders/${user.uid}/$orderId',
    );

    Map<String, dynamic> itemsData = {};
    for (var item in selectedItems) {
      final product = item.product;
      final size = item.size;
      final qty = item.quantity;
      final harga = product.harga_produk[size] ?? 0;

      itemsData[product.nama_produk] = {
        'nama': product.nama_produk,
        'qty': qty,
        'size': size,
        'hargaSatuan': harga,
        'subtotal': harga * qty,
      };
    }

    final orderData = {
      'alamat': _alamat,
      'metodePembayaran': _metodePembayaran,
      'total': total,
      'status': 'menunggu',
      'createdAt': ServerValue.timestamp,
      'items': itemsData,
    };

    await ref.set(orderData);
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        widget.cartItems
            .where((item) => widget.selected[item.id] == true)
            .toList();

    int total = 0;
    for (var item in selectedItems) {
      final product = item.product;
      final size = item.size;
      final qty = item.quantity;
      final harga = product.harga_produk[size] ?? 0;
      total += harga * qty;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Konfirmasi Pesanan'),

              onPressed: () async {
                _alamat = _alamatController.text.trim();

                if (_alamat.isEmpty || _metodePembayaran == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lengkapi alamat dan metode pembayaran.'),
                    ),
                  );
                  return;
                }

                final selectedItems =
                    widget.cartItems
                        .where((item) => widget.selected[item.id] == true)
                        .toList();

                int total = 0;
                for (var item in selectedItems) {
                  final harga = item.product.harga_produk[item.size] ?? 0;
                  total += harga * item.quantity;
                }

                await _simpanPesanan(selectedItems, total);

                // Hapus item yang di-checkout
                final cartNotifier = ref.read(cartNotifierProvider.notifier);
                await cartNotifier.removeCheckedOutItems(widget.selected);

                // Navigasi ke halaman "Pesanan Saya"
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PesananBerhasilPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: CoffeeThemeColors.primary,
                elevation: 0,
                foregroundColor: CoffeeThemeColors.background,
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
                    const Text(
                      'Alamat Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _alamatController,
                      onChanged: (val) => _alamat = val,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan alamat lengkap...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

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

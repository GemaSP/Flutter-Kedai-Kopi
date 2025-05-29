import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/cart/presentation/providers/cart_providers.dart';
import 'package:coffe_shop/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    if (cartState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cartState.userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Silahkan login untuk melihat keranjang.")),
      );
    }

    if (cartState.items.isEmpty) {
      return const Scaffold(body: Center(child: Text("Keranjang kosong")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang"),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
        leading: IconButton(
          icon: Icon(
            cartState.selected.values.every((v) => v)
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color:
                cartState.selected.values.every((v) => v)
                    ? CoffeeThemeColors.secondary
                    : CoffeeThemeColors.background,
          ),
          tooltip: "Pilih Semua",
          onPressed: () {
            final allSelected = cartState.selected.values.every((v) => v);
            cartNotifier.selectAll(!allSelected);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Hapus Terpilih",
            onPressed: () {
              cartNotifier.removeSelectedItems();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                final product = item.product;
                final harga = product.harga_produk[item.size] ?? 0;

                return Card(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? CoffeeDarkThemeColors
                              .primary // gunakan warna dark theme
                          : Colors.white, // default untuk light theme
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Checkbox
                        Checkbox(
                          value: cartState.selected[item.id] ?? false,
                          onChanged: (value) {
                            cartNotifier.toggleSelection(
                              item.id,
                              value ?? false,
                            );
                          },
                        ),

                        // Gambar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.path_gambar,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Informasi produk
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama produk + delete icon
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.nama_produk,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => cartNotifier.removeItem(item.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),

                              // Dropdown Size
                              DropdownButton<String>(
                                value: item.size,
                                items:
                                    ['small', 'medium', 'large'].map((size) {
                                      return DropdownMenuItem<String>(
                                        value: size,
                                        child: Text(
                                          "Size: ${size[0].toUpperCase()}",
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (newSize) {
                                  if (newSize != null) {
                                    cartNotifier.changeSize(item.id, newSize);
                                  }
                                },
                                isDense: true,
                                underline: const SizedBox(),
                              ),

                              // Harga dan jumlah
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Rp${NumberFormat('#,###', 'id_ID').format(harga)}",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed:
                                        () => cartNotifier.changeQuantity(
                                          item.id,
                                          item.quantity - 1,
                                        ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed:
                                        () => cartNotifier.changeQuantity(
                                          item.id,
                                          item.quantity + 1,
                                        ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total dan tombol checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // default untuk light theme,
              border: Border(
                top: BorderSide(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors
                              .white // gunakan warna dark theme
                          : CoffeeDarkThemeColors.primary,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Total: Rp${cartNotifier.total.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors
                                .white // gunakan warna dark theme
                            : CoffeeDarkThemeColors
                                .primary, // default untuk light theme
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoffeeDarkThemeColors.primary,
                    foregroundColor: CoffeeDarkThemeColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed:
                      cartNotifier.total > 0
                          ? () {
                            final selectedItems =
                                cartState.items.where((item) {
                                  return cartState.selected[item.id] == true;
                                }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CheckoutPage(
                                      cartItems: selectedItems,
                                      selected: cartState.selected,
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

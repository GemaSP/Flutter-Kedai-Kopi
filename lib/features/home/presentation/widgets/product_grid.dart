// lib/features/home/presentation/widgets/product_grid.dart
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final bool isEmpty;
  final void Function(Product) onProductTap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.isEmpty,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (isEmpty) {
      return const Expanded(
        child: Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 24,
          mainAxisExtent: 254,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              onProductTap(product);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? CoffeeDarkThemeColors
                            .primary // gunakan warna dark theme
                        : Colors.white, // default untuk light theme
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(product),
                  const Gap(8),
                  Text(
                    product.nama_produk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    product.kategori_id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(product.harga_produk['small']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      _buildAddToCartButton(context, product),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.path_gambar.isEmpty) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: 150,
        child: const Icon(Icons.image, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        product.path_gambar,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, Product product) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan login terlebih dahulu')),
            );
            return;
          }

          final cartRef = FirebaseDatabase.instance.ref(
            'cart/${user.uid}/${product.id}',
          );
          final snapshot = await cartRef.get();

          if (snapshot.exists) {
            final currentData = Map<String, dynamic>.from(
              snapshot.value as Map,
            );
            final currentQty = currentData['quantity'] ?? 1;
            await cartRef.update({'quantity': currentQty + 1});
          } else {
            await cartRef.set({'quantity': 1});
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.nama_produk} ditambahkan ke keranjang'),
            ),
          );
        },
        icon: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

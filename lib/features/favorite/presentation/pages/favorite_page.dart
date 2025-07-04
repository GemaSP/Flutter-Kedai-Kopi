import 'dart:async';

import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String userId = '';
  final _db = FirebaseDatabase.instance;
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _favSubscription;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _loadFavoriteProducts(userId: user.uid);
    } else {
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        if (user != null) {
          userId = user.uid;
          _loadFavoriteProducts(userId: user.uid);
        }
      });
    }
  }

  Future<void> _loadFavoriteProducts({required String userId}) async {
    _favSubscription?.cancel(); // stop previous listener

    _favSubscription = _db.ref('favorites/$userId').onValue.listen((
      event,
    ) async {
      final favSnapshot = event.snapshot;

      if (favSnapshot.exists) {
        final favMap = favSnapshot.value;

        if (favMap is Map) {
          final productIds =
              favMap.entries
                  .where((entry) => entry.value == true)
                  .map((entry) => entry.key)
                  .toList();

          List<Product> tempList = [];

          for (var id in productIds) {
            final productSnap = await _db.ref('produk/$id').get();
            if (productSnap.exists) {
              final data = Map<String, dynamic>.from(productSnap.value as Map);
              tempList.add(Product.fromMap({...data, 'id': id}));
            }
          }

          setState(() {
            _favoriteProducts = tempList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _favoriteProducts = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _favoriteProducts = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _favSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorit Saya"),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body:
          userId.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Kamu belum login,\nsilahkan login terlebih dahulu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                          ); // ganti route sesuai app kamu
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text("Login"),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                          ); // ganti route sesuai app kamu
                        },
                        child: const Text("Daftar"),
                      ),
                    ],
                  ),
                ),
              )
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteProducts.isEmpty
              ? const Center(child: Text("Belum ada produk favorit"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = _favoriteProducts[index];
                  return Dismissible(
                    key: Key(product.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await _db.ref('favorites/$userId/${product.id}').remove();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.nama_produk} dihapus dari favorit',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.path_gambar,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(product.nama_produk),
                        subtitle: Text(
                          product.deskripsi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product_detail',
                            arguments: product,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

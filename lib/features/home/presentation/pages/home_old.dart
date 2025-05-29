import 'dart:async';

import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class _HomePageState extends State<HomePage> {
  final _db = FirebaseDatabase.instance;

  String searchQuery = '';
  String _currentAddress = 'Loading location...';
  String _jalan = '';
  String _kecamatan = '';
  String _kota = 'Unknown District';
  String? displayName;

  List<Category> menuList = [];
  List<Product> selectedProducts = [];

  int selectedIndex = 0;
  bool isLoading = false;
  bool isLoadingLocation = true;

  StreamSubscription<DatabaseEvent>? _productSubscription;
  StreamSubscription<DatabaseEvent>? _categorySubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToCategories();

    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      displayName = user?.displayName ?? 'User';
    });
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        isLoadingLocation = false;
        _currentAddress =
            '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}';
        _jalan = placemarks.first.street ?? '';
        _kecamatan =
            '${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}';
        _kota = placemarks.first.subAdministrativeArea ?? 'Unknown District';
      });
    } else {
      setState(() {
        _currentAddress = 'Permission denied. Please enable location services.';
      });
    }
  }

  void _listenToCategories() {
    final ref = _db.ref('kategori');

    _categorySubscription = ref.onValue.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final categories =
            snapshot.children.map((e) {
              final data = e.value as Map<dynamic, dynamic>;
              return Category(
                id: e.key!,
                name: data['nama_kategori'] as String,
              );
            }).toList();

        setState(() {
          menuList = categories;

          if (selectedIndex >= categories.length) {
            selectedIndex = 0;
          }

          _listenToProducts(categories[selectedIndex].id);
        });
      }
    });
  }

  void _listenToProducts(String categoryId) {
    _productSubscription?.cancel();
    final ref = _db.ref('produk');

    setState(() => isLoading = true);

    _productSubscription = ref.onValue.listen((event) {
      final snapshot = event.snapshot;
      List<Product> products = [];

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final productId = child.key;
          final data = child.value as Map<dynamic, dynamic>;

          if (data['kategori_id'].toString().trim() == categoryId.trim()) {
            try {
            } catch (_) {}
          }
        }
      }

      setState(() {
        selectedProducts = products;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        selectedProducts.where((product) {
          return product.nama_produk.toLowerCase().contains(searchQuery);
        }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          children: [
            _buildLocationInfo(),
            const Gap(20),
            _buildSearchField(),
            const Gap(16),
            _buildBanner(),
            const Gap(16),
            _buildCategoryMenu(),
            const Gap(16),
            _buildProductGrid(filteredProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location:', style: TextStyle(fontSize: 13)),
            isLoadingLocation
                ? const Text(
                  'Memuat Location...',
                  style: TextStyle(fontSize: 16),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_jalan, style: const TextStyle(fontSize: 16)),
                    Text(_kecamatan, style: const TextStyle(fontSize: 16)),
                  ],
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(menuList.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              _listenToProducts(menuList[index].id);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                menuList[index].name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> filteredProducts) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (selectedProducts.isEmpty) {
      return const Expanded(child: Center(child: Text('Belum ada produk.')));
    }

    if (filteredProducts.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        shrinkWrap: true,
        itemCount: filteredProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 24,
          mainAxisExtent: 254,
        ),
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/product_detail', arguments: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),
            const Gap(8),
            Text(
              product.nama_produk,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                _buildAddToCartButton(product),
              ],
            ),
          ],
        ),
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

  Widget _buildAddToCartButton(Product product) {
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

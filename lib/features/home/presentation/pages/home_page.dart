import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffe_shop/features/home/presentation/providers/home_provider.dart';
import 'package:coffe_shop/features/home/presentation/widgets/banner_widget.dart';
import 'package:coffe_shop/features/home/presentation/widgets/category_menu.dart';
import 'package:coffe_shop/features/home/presentation/widgets/location_info.dart';
import 'package:coffe_shop/features/home/presentation/widgets/product_grid.dart';
import 'package:coffe_shop/features/home/presentation/widgets/search_field.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedCategoryIndex = 0;

  void fetchInitialProducts() {
    final categories = ref.read(homeControllerProvider).categories;
    if (categories.isNotEmpty) {
      final categoryId = categories[0].id; // Mengambil kategori pertama
      ref
          .read(homeControllerProvider.notifier)
          .fetchProductsByCategory(categoryId);
    }
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Izin notifikasi diberikan");
    } else if (status.isDenied) {
      print("Izin notifikasi ditolak");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (ref.read(homeControllerProvider).categories.isEmpty) {
        ref.read(homeControllerProvider.notifier).fetchCategories();
      }
      if (ref.read(homeControllerProvider).selectedProducts.isEmpty) {
        fetchInitialProducts();
      }
      ref.watch(homeControllerProvider.notifier).fetchLocation();
      requestNotificationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
      toolbarHeight: 0,
      backgroundColor: CoffeeThemeColors.primary,
    ),
      body:
          state.isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationInfo(
                      location: state.jalan,
                      location2: state.kecamatan,
                      isLoading: state.isLoadingLocation,
                    ),
                    const SizedBox(height: 16),
                    SearchField(
                      onSearchChanged: (query) {
                        ref
                            .read(homeControllerProvider.notifier)
                            .setSearchQuery(query);
                      },
                    ),
                    const SizedBox(height: 16),
                    const BannerWidget(),
                    const SizedBox(height: 16),
                    CategoryMenu(
                      categories: state.categories,
                      selectedIndex:
                          _selectedCategoryIndex, // kamu bisa simpan index di state juga kalau mau
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex =
                              index; // Update selectedIndex saat kategori dipilih
                        });

                        final categoryId = state.categories[index].id;
                        ref
                            .read(homeControllerProvider.notifier)
                            .fetchProductsByCategory(categoryId);
                      },
                    ),
                    const SizedBox(height: 16),
                    ProductGrid(
                      products:
                          state.selectedProducts
                              .where(
                                (product) => product.nama_produk
                                    .toLowerCase()
                                    .contains(state.searchQuery.toLowerCase()),
                              )
                              .toList(),
                      isLoading: state.isLoadingProducts,
                      isEmpty: state.selectedProducts.isEmpty,
                      onProductTap: (Product product) {
                        Navigator.pushNamed(
                          context,
                          '/product_detail',
                          arguments: product,
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}

import 'package:coffe_shop/features/home/data/providers.dart';
import 'package:coffe_shop/features/home/domain/usecases/get_categories.dart';
import 'package:coffe_shop/features/home/domain/usecases/get_current_location.dart';
import 'package:coffe_shop/features/home/domain/usecases/get_products_by_category.dart';
import 'package:coffe_shop/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk GetCategories UseCase
final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.read(categoryRepositoryProvider));
});

// Provider untuk GetProductsByCategory UseCase
final getProductsByCategoryProvider = Provider<GetProductsByCategory>((ref) {
  return GetProductsByCategory(ref.read(productRepositoryProvider));
});

final getCurrentLocationProvider = Provider<GetCurrentLocation>((ref) {
  return GetCurrentLocation();
});

// 1. Provider untuk HomeController (StateNotifier)
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    final getCategories = ref.read(getCategoriesProvider);
    final getProductsByCategory = ref.read(getProductsByCategoryProvider);
    final getCurrentLocation = ref.read(getCurrentLocationProvider);

    return HomeController(
      getCategories: getCategories,
      getProductsByCategory: getProductsByCategory,
      getCurrentLocation: getCurrentLocation,
    );
  },
);

// 2. Provider untuk loading state (boolean untuk menunjukkan loading)
final isLoadingProvider = StateProvider<bool>((ref) => false);

// 3. Provider untuk error message state
final errorMessageProvider = StateProvider<String>((ref) => '');

// 4. Provider untuk tab index (misalnya untuk navigasi tab di halaman utama)
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

// 5. Provider untuk kategori produk (dapat digunakan di UI untuk menampilkan daftar kategori)
final categoriesProvider = StateProvider<List<String>>((ref) => []);

// 6. Provider untuk produk berdasarkan kategori (dapat digunakan untuk menampilkan produk dari kategori yang dipilih)
final productsByCategoryProvider = StateProvider<List<String>>((ref) => []);

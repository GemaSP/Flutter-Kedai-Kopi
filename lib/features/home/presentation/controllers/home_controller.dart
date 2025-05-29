import 'package:coffe_shop/features/home/domain/usecases/get_current_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:coffe_shop/features/home/domain/entities/category.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:coffe_shop/features/home/domain/usecases/get_categories.dart';
import 'package:coffe_shop/features/home/domain/usecases/get_products_by_category.dart';

class HomeController extends StateNotifier<HomeState> {
  final GetCategories getCategories;
  final GetProductsByCategory getProductsByCategory;
  final GetCurrentLocation getCurrentLocation;

  HomeController({
    required this.getCategories,
    required this.getProductsByCategory,
    required this.getCurrentLocation,
  }) : super(HomeState.initial());

  void fetchCategories() {
    state = state.copyWith(isLoadingCategories: true);
    getCategories().listen((categories) {
      state = state.copyWith(
        categories: categories,
        isLoadingCategories: false,
      );

      // Setelah kategori berhasil diambil, langsung ambil produk untuk kategori pertama
      if (categories.isNotEmpty) {
        final categoryId = categories[0].id; // Ambil kategori pertama
        fetchProductsByCategory(categoryId);
      }
    });
  }

  void fetchProductsByCategory(String categoryId) {
    state = state.copyWith(isLoadingProducts: true);
    getProductsByCategory(categoryId).listen((products) {
      state = state.copyWith(
        selectedProducts: products,
        isLoadingProducts: false,
      );
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void fetchLocation() async {
    state = state.copyWith(isLoadingLocation: true, locationError: null);

    final permission = await Permission.location.request();

    if (!permission.isGranted) {
      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'Izin lokasi ditolak. Aktifkan layanan lokasi.',
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final p = placemarks.first;

      state = state.copyWith(
        isLoadingLocation: false,
        jalan: p.street ?? '',
        kecamatan: '${p.locality}, ${p.subAdministrativeArea}',
        kota: p.subAdministrativeArea ?? 'Unknown District',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'Gagal mengambil lokasi: $e',
      );
    }
  }
}

class HomeState {
  final bool isLoadingCategories;
  final bool isLoadingProducts;
  final List<Category> categories;
  final List<Product> selectedProducts;
  final String searchQuery;
  final String jalan;
  final String kecamatan;
  final String kota;
  final bool isLoadingLocation;
  final String? locationError;

  HomeState({
    required this.isLoadingCategories,
    required this.isLoadingProducts,
    required this.categories,
    required this.selectedProducts,
    required this.searchQuery,
    required this.jalan,
    required this.kecamatan,
    required this.kota,
    required this.isLoadingLocation,
    required this.locationError,
  });

  factory HomeState.initial() {
    return HomeState(
      isLoadingCategories: false,
      isLoadingProducts: false,
      categories: [],
      selectedProducts: [],
      searchQuery: '',
      jalan: '',
      kecamatan: '',
      kota: '',
      isLoadingLocation: true,
      locationError: null,
    );
  }

  HomeState copyWith({
    bool? isLoadingCategories,
    bool? isLoadingProducts,
    List<Category>? categories,
    List<Product>? selectedProducts,
    String? searchQuery,
    String? jalan,
    String? kecamatan,
    String? kota,
    bool? isLoadingLocation,
    String? locationError,
  }) {
    return HomeState(
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      categories: categories ?? this.categories,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      jalan: jalan ?? this.jalan,
      kecamatan: kecamatan ?? this.kecamatan,
      kota: kota ?? this.kota,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: locationError ?? this.locationError,
    );
  }
}

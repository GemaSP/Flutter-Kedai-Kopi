// lib/features/home/data/providers.dart
import 'package:coffe_shop/features/home/data/datasources/category_remote_data_source.dart';
import 'package:coffe_shop/features/home/data/datasources/product_remote_data_source.dart';
import 'package:coffe_shop/features/home/data/repositories/category_repository_impl.dart';
import 'package:coffe_shop/features/home/data/repositories/location_repository_impl.dart';
import 'package:coffe_shop/features/home/data/repositories/product_repository_impl.dart';
import 'package:coffe_shop/features/home/domain/repositories/category_repository.dart';
import 'package:coffe_shop/features/home/domain/repositories/location_repository.dart';
import 'package:coffe_shop/features/home/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    CategoryRemoteDataSourceImpl(),
  ); // Sesuaikan dengan implementasi repository
});

// Provider untuk ProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ProductRemoteDataSourceImpl());
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

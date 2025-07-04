import 'package:coffe_shop/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:coffe_shop/features/cart/domain/usecases/get_cart_items.dart';
import 'package:coffe_shop/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:coffe_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:coffe_shop/features/cart/domain/usecases/update_cart_size.dart';
import 'package:coffe_shop/features/cart/presentation/notifiers/cart_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cart_repository_impl.dart';

final cartRemoteDatasourceProvider = Provider<CartRemoteDatasource>((ref) {
  // Buat instance dari CartRemoteDatasource sesuai dengan implementasinya
  return CartRemoteDatasource(); // Sesuaikan dengan implementasi sebenarnya
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final remoteDatasource = ref.watch(cartRemoteDatasourceProvider);
  return CartRepositoryImpl(
    remoteDatasource,
  ); // Menggunakan CartRemoteDatasource
});

final getCartItemsProvider = Provider((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return GetCartItems(repo);
});

final removeCartItemProvider = Provider((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return RemoveCartItem(repo);
});

final updateQuantityProvider = Provider((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return UpdateCartQuantity(repo);
});

final updateSizeProvider = Provider((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return UpdateCartSize(repo);
});

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((
  ref,
) {
  return CartNotifier(
    getCartItems: ref.watch(getCartItemsProvider),
    removeCartItem: ref.watch(removeCartItemProvider),
    updateQuantity: ref.watch(updateQuantityProvider),
    updateSize: ref.watch(updateSizeProvider),
  );
});

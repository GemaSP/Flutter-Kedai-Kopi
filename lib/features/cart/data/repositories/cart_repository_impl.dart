import 'package:coffe_shop/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDatasource remoteDatasource;

  CartRepositoryImpl(this.remoteDatasource);

  @override
  Stream<List<CartItem>> getCartItems() {
    return remoteDatasource.fetchCartItems();
  }

  @override
  Future<void> removeFromCart(String productId) {
    return remoteDatasource.removeItem(productId);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) {
    return remoteDatasource.updateQuantity(productId, quantity);
  }

  @override
  Future<void> updateSize(String productId, String size) {
    return remoteDatasource.updateSize(productId, size);
  }
}

import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> getCartItems();
  Future<void> removeFromCart(String productId);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> updateSize(String productId, String size);
}

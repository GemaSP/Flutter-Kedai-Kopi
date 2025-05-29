import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.size,
  });

  factory CartItemModel.fromMap({
    required String id,
    required Map<String, dynamic> cartData,
    required Product product,
  }) {
    return CartItemModel(
      id: id,
      product: product,
      quantity: cartData['quantity'] ?? 1,
      size: cartData['size'] ?? 'small',
    );
  }
}

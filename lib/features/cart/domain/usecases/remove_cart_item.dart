import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repository;

  RemoveCartItem(this.repository);

  Future<void> call(String productId) {
    return repository.removeFromCart(productId);
  }
}

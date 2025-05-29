import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantity {
  final CartRepository repository;

  UpdateCartQuantity(this.repository);

  Future<void> call(String productId, int quantity) {
    return repository.updateQuantity(productId, quantity);
  }
}

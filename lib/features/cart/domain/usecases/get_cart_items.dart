import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';

class GetCartItems {
  final CartRepository repository;

  GetCartItems(this.repository);

  Stream<List<CartItem>> call() {
    return repository.getCartItems();
  }
}

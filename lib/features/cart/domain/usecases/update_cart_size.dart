import 'package:coffe_shop/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartSize {
  final CartRepository repository;

  UpdateCartSize(this.repository);

  Future<void> call(String productId, String size) {
    return repository.updateSize(productId, size);
  }
}

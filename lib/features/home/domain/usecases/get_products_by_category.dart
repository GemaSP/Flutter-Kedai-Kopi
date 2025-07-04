import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategory {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  Stream<List<Product>> call(String categoryId) {
    return repository.getProductsByCategory(categoryId);
  }
}

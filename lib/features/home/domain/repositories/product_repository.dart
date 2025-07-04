import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> getProductsByCategory(String categoryId);
}

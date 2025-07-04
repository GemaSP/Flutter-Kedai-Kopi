import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> getCategories();
}

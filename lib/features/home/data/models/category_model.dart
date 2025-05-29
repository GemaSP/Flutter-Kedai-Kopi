import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['nama_kategori'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_kategori': name,
    };
  }
}

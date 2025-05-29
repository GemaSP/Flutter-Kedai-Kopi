import 'package:firebase_database/firebase_database.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Stream<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('kategori');

  @override
  Stream<List<CategoryModel>> getCategories() {
    return _ref.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        return snapshot.children.map((child) {
          final data = Map<String, dynamic>.from(child.value as Map);
          return CategoryModel.fromMap(data, child.key!);
        }).toList();
      } else {
        return [];
      }
    });
  }
}

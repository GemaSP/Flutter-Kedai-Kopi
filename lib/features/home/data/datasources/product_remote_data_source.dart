import 'package:firebase_database/firebase_database.dart';

import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Stream<List<ProductModel>> getProductsByCategory(String categoryId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('produk');

  @override
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    return _ref.onValue.map((event) {
      final snapshot = event.snapshot;
      List<ProductModel> products = [];

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);
          if ((data['kategori_id'] ?? '').toString().trim() ==
              categoryId.trim()) {
            products.add(ProductModel.fromMap({...data, 'id': child.key}));
          }
        }
      }

      return products;
    });
  }
}

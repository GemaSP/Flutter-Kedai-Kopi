import 'package:coffe_shop/features/cart/data/models/cart_item_model.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CartRemoteDatasource {
  final _db = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  DatabaseReference get _cartRef => _db.ref('cart/$userId');

  Stream<List<CartItemModel>> fetchCartItems() {
    return _cartRef.onValue.asyncMap((event) async {
      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final cartMap = Map<String, dynamic>.from(snapshot.value as Map);
      List<CartItemModel> items = [];

      for (var entry in cartMap.entries) {
        final productId = entry.key;
        final cartData = Map<String, dynamic>.from(entry.value);

        final productSnap = await _db.ref('produk/$productId').get();
        if (productSnap.exists) {
          final productData = Map<String, dynamic>.from(
            productSnap.value as Map,
          );
          final product = Product.fromMap({...productData, 'id': productId});

          items.add(
            CartItemModel.fromMap(
              id: productId,
              cartData: cartData,
              product: product,
            ),
          );
        }
      }

      return items;
    });
  }

  Future<void> removeItem(String productId) async {
    await _cartRef.child(productId).remove();
  }

  Future<void> updateQuantity(String productId, int newQty) async {
    if (newQty <= 0) {
      await removeItem(productId);
    } else {
      await _cartRef.child(productId).update({'quantity': newQty});
    }
  }

  Future<void> updateSize(String productId, String newSize) async {
    await _cartRef.child(productId).update({'size': newSize});
  }
}

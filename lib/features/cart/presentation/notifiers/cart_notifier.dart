import 'dart:async';
import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/cart/domain/usecases/get_cart_items.dart';
import 'package:coffe_shop/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:coffe_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:coffe_shop/features/cart/domain/usecases/update_cart_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  final List<CartItem> items;
  final Map<String, bool> selected;
  final bool isLoading;
  final String userId;

  CartState({
    required this.items,
    required this.selected,
    required this.isLoading,
    this.userId = '',
  });

  CartState copyWith({
    List<CartItem>? items,
    Map<String, bool>? selected,
    bool? isLoading,
    String? userId,
  }) {
    return CartState(
      items: items ?? this.items,
      selected: selected ?? this.selected,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final GetCartItems getCartItems;
  final RemoveCartItem removeCartItem;
  final UpdateCartQuantity updateQuantity;
  final UpdateCartSize updateSize;
  StreamSubscription<List<CartItem>>? _cartSubscription;
  StreamSubscription<User?>? _authSubscription;

  CartNotifier({
    required this.getCartItems,
    required this.removeCartItem,
    required this.updateQuantity,
    required this.updateSize,
  }) : super(CartState(items: [], selected: {}, isLoading: true)) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      loadCart();
    });
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await _cartSubscription?.cancel();
      state = CartState(items: [], selected: {}, isLoading: false, userId: '');
      return;
    }

    final userId = user.uid;
    state = state.copyWith(userId: userId);

    await _cartSubscription?.cancel();

    _cartSubscription = getCartItems().listen((items) {
      final newSelected = {
        for (var item in items) item.id: state.selected[item.id] ?? false,
      };

      state = state.copyWith(
        items: items,
        selected: newSelected,
        isLoading: false,
      );
    });
  }

  void toggleSelection(String productId, bool value) {
    state = state.copyWith(selected: {...state.selected, productId: value});
  }

  Future<void> removeItem(String productId) async {
    await removeCartItem(productId);
  }

  Future<void> changeQuantity(String productId, int qty) async {
    final updatedItems =
        state.items.map((item) {
          if (item.id == productId) {
            return item.copyWith(quantity: qty);
          }
          return item;
        }).toList();

    state = state.copyWith(items: updatedItems);

    await updateQuantity(productId, qty);
  }

  Future<void> changeSize(String productId, String size) async {
    final updatedItems =
        state.items.map((item) {
          if (item.id == productId) {
            return item.copyWith(size: size);
          }
          return item;
        }).toList();

    state = state.copyWith(items: updatedItems);

    await updateSize(productId, size);
  }

  Future<void> _removeItemFromFirebase(String productId) async {
    await removeCartItem(productId);
  }

  double get total {
    double total = 0;
    for (var item in state.items) {
      if (state.selected[item.id] == true) {
        final harga = item.product.harga_produk[item.size] ?? 0;
        total += harga * item.quantity;
      }
    }
    return total;
  }

  Future<void> removeCheckedOutItems(Map<String, bool> selected) async {
    final userId = state.userId;
    if (userId.isEmpty) return;

    final ref = FirebaseDatabase.instance.ref('cart/$userId');
    for (var entry in selected.entries) {
      if (entry.value) {
        await ref.child(entry.key).remove(); // hapus dari Firebase
      }
    }

    // Perbarui state lokal
    final updatedItems =
        state.items.where((item) => !(selected[item.id] ?? false)).toList();
    final updatedSelected = {...state.selected}
      ..removeWhere((key, _) => selected[key] == true);

    state = state.copyWith(items: updatedItems, selected: updatedSelected);
  }

  List<CartItem> get selectedItems =>
      state.items.where((item) => state.selected[item.id] == true).toList();

  void selectAll(bool select) {
    final updatedSelected = <String, bool>{};
    for (var item in state.items) {
      updatedSelected[item.id] = select;
    }

    state = state.copyWith(selected: updatedSelected);
  }

  void removeSelectedItems() {
    final selectedIds =
        state.selected.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    for (var id in selectedIds) {
      _removeItemFromFirebase(id);
    }

    state = state.copyWith(
      items: state.items.where((item) => !state.selected[item.id]!).toList(),
      selected: {},
    );
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}

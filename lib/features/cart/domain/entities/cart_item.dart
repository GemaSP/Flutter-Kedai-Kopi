import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final String size;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
  });

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? size,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, size];
}

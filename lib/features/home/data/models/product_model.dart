import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.nama_produk,
    required super.deskripsi,
    required super.kategori_id,
    required super.harga_produk,
    required super.path_gambar,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      nama_produk: map['nama_produk'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      kategori_id: map['kategori_id'] ?? '',
      harga_produk: Map<String, int>.from(map['harga_produk'] ?? {}),
      path_gambar: map['path_gambar'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_produk': nama_produk,
      'deskripsi' : deskripsi,
      'kategori_id': kategori_id,
      'harga_produk': harga_produk,
      'path_gambar': path_gambar,
    };
  }
}

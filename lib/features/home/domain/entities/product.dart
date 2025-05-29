class Product {
  final String id;
  final String nama_produk;
  final String deskripsi;
  final String kategori_id;
  final Map<String, int> harga_produk;
  final String path_gambar;

  Product({
    required this.id,
    required this.nama_produk,
    required this.deskripsi,
    required this.kategori_id,
    required this.harga_produk,
    required this.path_gambar,
  });

  // Menambahkan konstruktor dari Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      nama_produk: map['nama_produk'] as String,
      deskripsi: map['deskripsi'] as String,
      harga_produk: Map<String, int>.from(map['harga_produk'] as Map),
      path_gambar: map['path_gambar'] as String,
      kategori_id: '',
    );
  }

  // Untuk konversi ke Map jika diperlukan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_produk': nama_produk,
      'deskripsi' : deskripsi,
      'harga_produk': harga_produk,
      'path_gambar': path_gambar,
    };
  }
}

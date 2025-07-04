import 'package:coffe_shop/core/widgets/buttons/primary_button.dart';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/cart/domain/entities/cart_item.dart';
import 'package:coffe_shop/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:coffe_shop/features/home/domain/entities/product.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorited = false;
  String sizeSelected = 'small';
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  late DatabaseReference _favoriteRef;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Mengecek apakah produk ini sudah favorit atau belum
  void _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _favoriteRef = _db.ref('favorites/${user.uid}/${widget.product.id}');
      _favoriteRef.once().then((snapshot) {
        if (snapshot.snapshot.exists) {
          setState(() {
            isFavorited = snapshot.snapshot.value == true;
          });
        }
      });
    }
  }

  // Fungsi untuk men-toggle status favorit
  void _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isFavorited = !isFavorited;
      });
      await _favoriteRef.set(isFavorited);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHeader(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Gap(24),
          buildImage(),
          Gap(24),
          buildMainInfo(),
          Gap(24),
          buildDescription(),
          Gap(24),
          buildSize(),
          Gap(24),
        ],
      ),
      bottomNavigationBar: SafeArea(child: buildPrice()),
    );
  }

  buildHeader() {
    return AppBar(
      backgroundColor: CoffeeThemeColors.primary,
      foregroundColor: CoffeeThemeColors.background,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Detail',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : CoffeeThemeColors.background,
          ),
          onPressed: _toggleFavorite, // Toggle the favorite status
        ),
      ],
    );
  }

  Widget buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        widget.product.path_gambar,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.nama_produk,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kategori: Kopi",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Rating: 4.5",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children:
                  ['assets/bike.png', 'assets/bean.png', 'assets/milk.png'].map(
                    (e) {
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: Image.asset(e, width: 24, height: 24),
                      );
                    },
                  ).toList(),
            ),
          ],
        ),
        Gap(16),
        Divider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade300,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const Gap(8),
        ReadMoreText(
          widget.product.deskripsi,
          trimLines: 3,
          trimMode: TrimMode.Line,
          trimCollapsedText: 'baca selengkapnya',
          trimExpandedText: 'lebih sedikit',
          colorClickableText: Colors.blue,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildSize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xff242424),
          ),
        ),
        const Gap(16),
        Row(
          children:
              ['small', '', 'medium', '', 'large'].map((e) {
                if (e == '') return const Gap(16);

                bool isSelected = sizeSelected == e;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      sizeSelected = e;
                      setState(() {});
                    },
                    child: Container(
                      height: 41,
                      decoration: BoxDecoration(
                        color: Color(isSelected ? 0xffF9F2ED : 0xffFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(isSelected ? 0xffC67C4E : 0xffE3E3E3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Color(isSelected ? 0xffC67C4E : 0xff242424),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget buildPrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: CoffeeThemeColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Informasi harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: CoffeeThemeColors.background,
                  ),
                ),
                const Gap(4),
                Text(
                  widget.product.harga_produk[sizeSelected] != null
                      ? NumberFormat.currency(
                        decimalDigits: 0,
                        locale: 'id_ID',
                        symbol: 'Rp ',
                      ).format(widget.product.harga_produk[sizeSelected])
                      : 'Rp 0',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: CoffeeThemeColors.background,
                  ),
                ),
              ],
            ),
          ),

          // Tombol keranjang
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              color: const Color(0xffC67C4E),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final userId = user.uid;
                  final productId = widget.product.id;

                  final cartRef = FirebaseDatabase.instance.ref(
                    'cart/$userId/$productId',
                  );

                  final snapshot = await cartRef.get();

                  if (snapshot.exists) {
                    // Kalau udah ada, tambahin quantity-nya
                    final currentData = Map<String, dynamic>.from(
                      snapshot.value as Map,
                    );
                    final currentQty = currentData['quantity'] ?? 1;

                    await cartRef.update({'quantity': currentQty + 1});
                  } else {
                    // Kalau belum ada, tambahin baru dengan quantity 1
                    await cartRef.set({'quantity': 1});
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.nama_produk} ditambahkan ke keranjang',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                    ),
                  );
                }
              },
            ),
          ),

          // Tombol Buy Now
          SizedBox(
            width: 160,
            child: PrimaryButton(
              title: 'Buy Now',
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                    ),
                  );
                  return;
                }

                // Buat CartItem dummy
                final cartItem = CartItem(
                  id:
                      "${widget.product.id}_${DateTime.now().millisecondsSinceEpoch}",
                  product: widget.product,
                  size: sizeSelected,
                  quantity: 1,
                );

                // Navigasi ke halaman Checkout dengan 1 item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CheckoutPage(
                          cartItems: [cartItem],
                          selected: {cartItem.id: true},
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/account/presentation/pages/alamatpengiriman_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/bahasatema_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/bantuan_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/notifikasi_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/pembayaran_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/pesanansaya_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/tentang_page.dart';
import 'package:coffe_shop/features/account/presentation/pages/userprofile_page.dart';
import 'package:coffe_shop/features/account/widgets/profile_dialog.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_notifier.dart';
import 'package:coffe_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffe_shop/features/favorite/presentation/pages/favorite_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  String name = 'Guest';
  String email = 'No email';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      name = user?.displayName ?? 'Guest';
      email = user?.email ?? 'No email';
      photoUrl = user?.photoURL ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showFullImage(context),
              child: CircleAvatar(
                radius: 70,
                child: ClipOval(
                  child:
                      photoUrl.isNotEmpty
                          ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 140,
                            height: 140,
                          )
                          : Image.asset(
                            'assets/default-avatar-profile.jpg',
                            fit: BoxFit.cover,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(email, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 10),

            /// List menu yang scrollable
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Profil Pengguna'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Alamat Pengiriman'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlamatPengirimanPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorit Saya'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoritePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt),
                    title: const Text('Pesanan Saya'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PesananSayaPage(),
                        ),
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.payment),
                  //   title: const Text('Pembayaran'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => PembayaranPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.notifications),
                  //   title: const Text('Notifikasi'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => NotifikasiPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(Icons.language),
                  //   title: const Text('Bahasa & Tema'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => BahasaTemaPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Tentang Aplikasi'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TentangAplikasiPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Bantuan/Hubungi Kami'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BantuanHubungiKamiPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Keluar'),
                    onTap: () => _showLogoutDialog(context, authNotifier),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Anda yakin akan logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  authNotifier.logout();
                  Navigator.popAndPushNamed(context, '/main');
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ProfileDialog(onEdit: () => _showEditOptions(context)),
    );
  }

  void _showEditOptions(BuildContext context) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      backgroundColor: CoffeeThemeColors.primary,
      context: context,
      builder:
          (context) => SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: CoffeeThemeColors.background,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const Text(
                        'Foto Profil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CoffeeThemeColors.background,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteProfilePicture,
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: CoffeeThemeColors.background,
                    ),
                    title: const Text(
                      'Ambil Foto dari Kamera',
                      style: TextStyle(color: CoffeeThemeColors.background),
                    ),
                    onTap: () async {
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        await _uploadAndUpdateProfile(pickedFile.path);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: CoffeeThemeColors.background,
                    ),
                    title: const Text(
                      'Pilih dari Galeri',
                      style: TextStyle(color: CoffeeThemeColors.background),
                    ),
                    onTap: () async {
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        await _uploadAndUpdateProfile(pickedFile.path);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _uploadAndUpdateProfile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        debugPrint('File tidak ditemukan: $imagePath');
        return;
      }

      final fileName =
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.Supabase.instance.client.storage
          .from('coffe-shop')
          .upload(fileName, file);

      final imageUrl = supabase.Supabase.instance.client.storage
          .from('coffe-shop')
          .getPublicUrl(fileName);

      final user = FirebaseAuth.instance.currentUser;
      final photo = FirebaseDatabase.instance.ref(
        'users/${user!.uid}/photoURL/',
      );
      if (user != null) {
        await user.updateProfile(
          displayName: user.displayName,
          photoURL: imageUrl,
        );
        await photo.set(imageUrl);

        setState(() {
          photoUrl = imageUrl;
        });
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
    }
  }

  Future<void> _deleteProfilePicture() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: user.displayName, photoURL: null);
        setState(() {
          photoUrl = '';
        });
      }
    } catch (e) {
      debugPrint('Delete Error: $e');
    }
  }
}

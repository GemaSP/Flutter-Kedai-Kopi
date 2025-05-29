import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profil'),
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Verifikasi Email'),
            subtitle: Text(
              user?.emailVerified == true
                  ? 'Terverifikasi'
                  : 'Belum diverifikasi',
            ),
            onTap: () {
              if (user != null && !user.emailVerified) {
                user.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email verifikasi telah dikirim'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ganti Password'),
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Hapus Akun'),
            onTap: () {
              Navigator.pushNamed(context, '/delete-account');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Login Terakhir'),
            subtitle: Text(user?.metadata.lastSignInTime?.toString() ?? '-'),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Aktivitas Perangkat'),
            onTap: () {
              // Diisi jika ada sistem pelacakan perangkat
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privasi & Keamanan'),
            onTap: () {
              Navigator.pushNamed(context, '/privacy-security');
            },
          ),
        ],
      ),
    );
  }
}

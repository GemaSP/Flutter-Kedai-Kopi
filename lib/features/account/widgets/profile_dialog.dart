import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileDialog({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: EdgeInsets.zero, // biar tidak ada margin
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // no corner radius
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Container(
              color: CoffeeThemeColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: CoffeeThemeColors.background),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Foto Profil',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      onEdit();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Share logic here
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  final photoUrl = snapshot.data?.photoURL ?? '';

                  return Center(
                    child: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          )
                        : Image.asset(
                            'assets/default-avatar-profile.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

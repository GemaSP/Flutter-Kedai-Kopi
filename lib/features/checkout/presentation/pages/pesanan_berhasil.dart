import 'package:flutter/material.dart';

class PesananBerhasilPage extends StatelessWidget {
  const PesananBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/pesanan-saya');
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text("Pesanan berhasil dibuat!", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

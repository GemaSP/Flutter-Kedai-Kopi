import 'package:flutter/material.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String? selectedMethod;

  final List<String> metodePembayaran = [
    'Transfer Bank',
    'E-Wallet (OVO, Dana, Gopay)',
    'Kartu Kredit/Debit',
    'COD (Bayar di Tempat)',
  ];

  void _simpanMetode() {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran terlebih dahulu.')),
      );
      return;
    }

    // Simpan ke Firebase atau state management sesuai kebutuhan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Metode "$selectedMethod" berhasil disimpan.')),
    );

    // Navigator.pop(context); // Jika ingin kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...metodePembayaran.map((metode) => RadioListTile<String>(
                  title: Text(metode),
                  value: metode,
                  groupValue: selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value;
                    });
                  },
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _simpanMetode,
              icon: const Icon(Icons.check),
              label: const Text('Simpan Metode'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            )
          ],
        ),
      ),
    );
  }
}

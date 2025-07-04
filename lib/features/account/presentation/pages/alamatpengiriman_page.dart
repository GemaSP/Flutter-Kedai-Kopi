import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class AlamatPengirimanPage extends StatefulWidget {
  const AlamatPengirimanPage({super.key});

  @override
  State<AlamatPengirimanPage> createState() => _AlamatPengirimanPageState();
}

class _AlamatPengirimanPageState extends State<AlamatPengirimanPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference addressRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      addressRef = FirebaseDatabase.instance.ref('users/${user!.uid}/alamat');
    }
  }

  Future<String> _getCurrentAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen.');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    } else {
      throw Exception('Gagal mendapatkan alamat.');
    }
  }

  void _addOrEditAddress({String? id, Map<String, dynamic>? current}) {
    final nameController = TextEditingController(text: current?['name'] ?? '');
    final addressController = TextEditingController(
      text: current?['address'] ?? '',
    );
    bool isMain = current?['isMain'] ?? false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(id == null ? 'Tambah Alamat' : 'Edit Alamat'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Tempat',
                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap',
                        ),
                        maxLines: 3,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            final currentAddress = await _getCurrentAddress();
                            setState(
                              () => addressController.text = currentAddress,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        icon: const Icon(Icons.my_location, color: CoffeeThemeColors.primary),
                        label: const Text(
                          'Gunakan Lokasi Saat Ini',
                          style: TextStyle(color: CoffeeThemeColors.primary),
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text('Jadikan Alamat Utama',
                            style: TextStyle(color: CoffeeThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        value: isMain,
                        onChanged: (value) {
                          setState(() {
                            isMain = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: CoffeeThemeColors.primary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CoffeeThemeColors.primary,
                        foregroundColor: CoffeeThemeColors.background,
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final address = addressController.text.trim();

                        if (name.isEmpty || address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nama tempat dan alamat wajib diisi!',
                              ),
                            ),
                          );
                          return;
                        }

                        final addressData = {
                          'name': name,
                          'address': address,
                          'isMain': isMain,
                        };

                        if (isMain) {
                          final snapshot = await addressRef.get();
                          for (final child in snapshot.children) {
                            await addressRef.child(child.key!).update({
                              'isMain': false,
                            });
                          }
                        }

                        if (id == null) {
                          final newId = const Uuid().v4();
                          await addressRef.child(newId).set(addressData);
                        } else {
                          await addressRef.child(id).update(addressData);
                        }

                        Navigator.pop(context);
                      },

                      child: const Text('Simpan'),
                    ),
                  ],
                  backgroundColor: CoffeeThemeColors.background,
                ),
          ),
    );
  }

  void _deleteAddress(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Alamat'),
            content: const Text('Yakin ingin menghapus alamat ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  addressRef.child(id).remove();
                  Navigator.pop(context);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Harap login terlebih dahulu.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Pengiriman'),
        centerTitle: true,
        backgroundColor: CoffeeThemeColors.primary,
        elevation: 0,
        foregroundColor: CoffeeThemeColors.background,
      ),
      body: StreamBuilder(
        stream: addressRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            final items =
                data.entries
                    .map(
                      (e) => {
                        'id': e.key,
                        'name': e.value['name'],
                        'address': e.value['address'],
                        'isMain': e.value['isMain'] ?? false,
                      },
                    )
                    .toList();

            return ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: item['isMain'] ? Colors.green[50] : null,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['address']),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _addOrEditAddress(id: item['id'], current: item);
                        } else if (value == 'delete') {
                          _deleteAddress(item['id']);
                        }
                      },
                      itemBuilder:
                          (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasData) {
            return const Center(child: Text('Belum ada alamat'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditAddress(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
        backgroundColor: CoffeeThemeColors.primary,
        foregroundColor: CoffeeThemeColors.background,
      ),
    );
  }
}

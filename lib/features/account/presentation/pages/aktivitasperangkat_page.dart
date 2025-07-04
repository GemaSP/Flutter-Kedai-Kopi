import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeviceActivityPage extends StatefulWidget {
  const DeviceActivityPage({super.key});

  @override
  State<DeviceActivityPage> createState() => _DeviceActivityPageState();
}

class _DeviceActivityPageState extends State<DeviceActivityPage> {
  List<Map<String, dynamic>> aktivitas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('aktivitas/${user.uid}');
    final snapshot = await ref.get();

    final data = snapshot.value;
    if (data is Map) {
      final list = data.entries.map((entry) {
        final val = Map<String, dynamic>.from(entry.value);
        return {
          'device': val['device'],
          'time': DateTime.fromMillisecondsSinceEpoch(
            val['time'] is int ? val['time'] : int.tryParse(val['time'].toString()) ?? 0,
          ),
        };
      }).toList();

      list.sort((a, b) => b['time'].compareTo(a['time']));

      setState(() {
        aktivitas = list;
        _isLoading = false;
      });
    } else {
      setState(() {
        aktivitas = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aktivitas Perangkat")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : aktivitas.isEmpty
              ? const Center(child: Text("Belum ada aktivitas."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: aktivitas.length,
                  itemBuilder: (context, index) {
                    final item = aktivitas[index];
                    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(item['time']);

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.devices),
                        title: Text(item['device']),
                        subtitle: Text('Login: $formatted'),
                      ),
                    );
                  },
                ),
    );
  }
}

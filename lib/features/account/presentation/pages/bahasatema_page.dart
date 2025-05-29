import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme_provider.dart';

class BahasaTemaPage extends ConsumerStatefulWidget {
  const BahasaTemaPage({super.key});

  @override
  ConsumerState<BahasaTemaPage> createState() => _BahasaTemaPageState();
}

class _BahasaTemaPageState extends ConsumerState<BahasaTemaPage> {
  late String _selectedLanguage;
  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();
    // Mengambil nilai awal locale dan tema dari provider
    final locale = ref.read(localeProvider);
    final theme = ref.read(themeModeProvider);
    _selectedLanguage = locale.languageCode;
    _isDarkTheme = theme == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);  // Menggunakan watch agar terupdate saat ada perubahan
    final theme = ref.watch(themeModeProvider);  // Menggunakan watch agar terupdate saat ada perubahan

    return Scaffold(
      appBar: AppBar(title: const Text('Bahasa & Tema')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Bahasa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pilih Bahasa',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Mode Gelap'),
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                },
                secondary: Icon(
                  _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // Simpan perubahan ke provider
                  ref.read(localeProvider.notifier).state = Locale(_selectedLanguage);
                  ref.read(themeModeProvider.notifier).state =
                      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
        
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengaturan disimpan')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengaturan'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/home/presentation/widgets/search_field.dart
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchField({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// lib/features/home/presentation/widgets/location_info.dart
import 'package:flutter/material.dart';

class LocationInfo extends StatelessWidget {
  final String location;
  final String location2;
  final bool isLoading;

  const LocationInfo({
    super.key,
    required this.location,
    required this.location2,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location:', style: TextStyle(fontSize: 13)),
            isLoading
                ? const Text(
                    'Memuat Location...',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(location, style: const TextStyle(fontSize: 16)),
                Text(location2, style: const TextStyle(fontSize: 16),)
          ],
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Mengirim notifikasi FCM v1 ke semua pengguna (kecuali pengirim)
Future<void> sendFCMv1Notification({
  required String title,
  required String body,
}) async {
  // Muat service account dari file JSON di assets
  final serviceAccountJson = await rootBundle.loadString(
    'assets/fcm_service_account.json',
  );
  final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Buat client otentikasi untuk mengakses FCM API
  final client = await clientViaServiceAccount(credentials, scopes);
  const projectId =
      'coffeshop-2876d'; // Ganti dengan Firebase Project ID milikmu

  try {
    // Ambil semua token dari database
    final snapshot = await FirebaseDatabase.instance.ref('tokens').get();
    if (!snapshot.exists) {
      debugPrint('Tidak ada token ditemukan.');
      return;
    }

    final tokensMap = Map<String, dynamic>.from(snapshot.value as Map);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final targetTokens =
        tokensMap.entries
            .where((entry) => entry.key != currentUserId && entry.value != null)
            .map((entry) => entry.value.toString())
            .toList();

    // Kirim notifikasi ke setiap token
    for (final token in targetTokens) {
      final response = await client.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
          },
        }),
      );

      debugPrint('FCM to $token: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    debugPrint('FCM error: $e');
  } finally {
    client.close();
  }
}

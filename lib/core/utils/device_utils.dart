import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

Future<void> simpanAktivitasLogin(User user) async {
  final deviceInfo = DeviceInfoPlugin();
  String device = 'Unknown';

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    device = 'Android - ${android.name}(${android.model})';
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    device = 'iOS ${ios.name} ${ios.systemVersion}';
  }

  final ref = FirebaseDatabase.instance.ref('aktivitas/${user.uid}');
  await ref.push().set({
    'device': device,
    'time': ServerValue.timestamp,
  });
}

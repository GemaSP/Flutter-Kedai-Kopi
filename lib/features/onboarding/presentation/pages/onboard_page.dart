import 'package:coffe_shop/core/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Izin notifikasi diberikan");
    } else if (status.isDenied) {
      print("Izin notifikasi ditolak");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset('assets/bg.png',
            width: double.infinity,
            fit: BoxFit.cover,),),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xff050505),
                    Color(0xff050505),
                    Color(0xff050505),
                    Color(0xff050505),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(100.h),
                  Text(
                    'Jatuh Cinta Dengan Kopi di Kanca Kopi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Gap(20.h),
                  Text(
                    'Selamat datang di Coffe Shop, nikmati pengalaman ngopi yang menyenangkan dan memuaskan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffA2A2A2),
                    ),
                  ),
                  Gap(30.h),
                  PrimaryButton(
                    title: 'Mulai',
                    onTap: () => 
                      Navigator.pushNamedAndRemoveUntil(context, '/main', ( route) => false),
                    ),
                  Gap(130.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
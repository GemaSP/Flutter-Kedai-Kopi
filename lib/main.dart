import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:coffe_shop/features/onboarding/presentation/pages/onboard_page.dart';
import 'package:coffe_shop/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: CoffeeThemeColors.primary,
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Supabase.initialize(
    url: 'https://tbvtcvlfieflakrpchhz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRidnRjdmxmaWVmbGFrcnBjaGh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3NjA2MjcsImV4cCI6MjA1OTMzNjYyN30.tvLILfurZ4yvk5wMARUpij7_7iW3zflo-QSX6C6QcNU',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FirebaseMessaging.instance.subscribeToTopic("all_users");
  await setupFirebaseMessaging();

  runApp(
    ScreenUtilInit(
      designSize: Size(393, 895),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ProviderScope(child: MyApp()),
    ),
  );
}

/// Setup Firebase Messaging and Local Notifications
Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Get FCM Token
  final token = await messaging.getToken();
  if (token != null) {
    await saveTokenToDatabase(token);
    debugPrint("FCM Token: $token");
  }

  // Init local notification
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  const initSettings = InitializationSettings(android: initSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Handle foreground notification
  FirebaseMessaging.onMessage.listen((message) {
    if (message.notification != null) {
      _showLocalNotification(
        flutterLocalNotificationsPlugin,
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
      );
    }
  });

  // Handle notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.notification != null) {
      _showLocalNotification(
        flutterLocalNotificationsPlugin,
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
      );
    }
  });
}

/// Save FCM token to Realtime Database
Future<void> saveTokenToDatabase(String token) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final ref = FirebaseDatabase.instance.ref('tokens/${user.uid}');
    await ref.set(token);
    debugPrint("Token saved to database.");
  } else {
    debugPrint("User not authenticated.");
  }
}

/// Show local notification using FlutterLocalNotificationsPlugin
Future<void> _showLocalNotification(
  FlutterLocalNotificationsPlugin plugin,
  String title,
  String body,
) async {
  const androidDetails = AndroidNotificationDetails(
    'chat_channel',
    'Chat Notifications',
    channelDescription: 'Notifikasi pesan masuk',
    importance: Importance.max,
    priority: Priority.high,
  );

  const platformDetails = NotificationDetails(android: androidDetails);

  await plugin.show(0, title, body, platformDetails);
}

/// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Coffee Shop',
      theme: ThemeData(
        primaryColor: CoffeeThemeColors.primary,
        scaffoldBackgroundColor: CoffeeThemeColors.background,
        fontFamily: 'Poppins',
      ),
      // darkTheme: ThemeData.dark().copyWith(
      //   primaryColor: CoffeeDarkThemeColors.primary,
      //   scaffoldBackgroundColor: CoffeeDarkThemeColors.background,
      //   textTheme: ThemeData.dark().textTheme.apply(
      //     bodyColor: CoffeeDarkThemeColors.textPrimary,
      //     displayColor: CoffeeDarkThemeColors.textPrimary,
      //   ),
      //   colorScheme: ColorScheme.dark(
      //     primary: CoffeeDarkThemeColors.primary,
      //     secondary: CoffeeDarkThemeColors.secondary,
      //     surface: CoffeeDarkThemeColors.background,
      //   ),
      // ),
      themeMode: themeMode, // ← ikut dari provider
      locale: locale, // ← ikut dari provider
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: OnboardPage(),
      routes: appRoutes,
      onGenerateRoute: generateRoute,
    );
  }
}

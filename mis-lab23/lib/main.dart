import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'screens/profile.dart';
import 'screens/register.dart';

import 'services/favorites_service.dart';
import 'state/favorites_notifier.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local notifications init (needed to show popup in foreground)
  await NotificationService.instance.init();

  // FCM permissions
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // iOS foreground presentation (safe on Android too)
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Token (for testing / proof)
  final String? token = await messaging.getToken();
  debugPrint('FCM Token: $token');

  // Foreground messages -> show as local notification + print
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final String title = message.notification?.title ?? 'Notification';
    final String body = message.notification?.body ?? '';

    debugPrint('Foreground notification received!');
    debugPrint('Title: $title');
    debugPrint('Body: $body');

    await NotificationService.instance.showNow(title: title, body: body);
  });

  // When user taps notification and app opens
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Notification clicked!');
  });

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),

        // FavoritesNotifier exists only when user is logged in
        ChangeNotifierProxyProvider<User?, FavoritesNotifier?>(
          create: (_) => null,
          update: (_, user, prev) {
            if (user == null) return null; // logged out
            if (prev != null) return prev; // keep existing
            return FavoritesNotifier(FavoritesService()); // create once
          },
        ),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const RegisterPage(),
        "/home": (context) => const CategoriesScreen(),
        "/profile": (context) => ProfilePage(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:due_tocoffee/theme/app_theme.dart';
import 'package:due_tocoffee/routes/route.dart';
import 'package:due_tocoffee/routes/route_constants.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:due_tocoffee/screen/search/view/order_status.dart';
import 'package:due_tocoffee/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission();
  await setupFlutterNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Template by The Flutter Way',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      routes: {
        '/entry': (context) => EntryPoint(),
        '/orderPayments': (context) => const UserTransactionsPage(),
      },
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          // 🔥 Check FCM intent when app starts
          return FutureBuilder<RemoteMessage?>(
            future: FirebaseMessaging.instance.getInitialMessage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final message = snapshot.data;
              final int initialTab = (message != null && message.data['action'] == 'open_order_status') ? 2 : 0;
              return EntryPoint(initialTab: initialTab);
            },
          );
        }

        return const SignInPage();
      },
    );
  }
}

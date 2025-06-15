import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:due_tocoffee/theme/app_theme.dart';
import 'package:due_tocoffee/routes/route.dart';
import 'package:due_tocoffee/routes/route_constants.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:due_tocoffee/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await setupFlutterNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOnboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!isOnboardingDone) {
      return const OnboardingScreen();
    } else {
      return const AuthChecker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Due To Coffee',
          theme: AppTheme.lightTheme(context),
          themeMode: ThemeMode.light,
          onGenerateRoute: AppRouter.generateRoute,
          routes: {
            '/entry': (context) => EntryPoint(),
            '/orderPayments': (context) => const UserTransactionsPage(),
          },
          home: snapshot.data,
        );
      },
    );
  }
}

// OnboardingScreen - stays almost same, but after onboarding mark as done
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthChecker()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B3F00),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset("assets/images/onboardingLogo.png", fit: BoxFit.contain),
              ),
              const SizedBox(height: 30),
              const Text(
                "Due To Coffee",
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "2026",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Your AuthChecker is 100% kept as is:
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
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

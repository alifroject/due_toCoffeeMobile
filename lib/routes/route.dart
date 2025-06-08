import 'package:flutter/material.dart';
import 'screen_export.dart';
import 'package:due_tocoffee/routes/route_constants.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingScreenRoute:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page Not Found')),
          ),
        );
    }
  }
}

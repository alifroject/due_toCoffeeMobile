import 'package:flutter/material.dart';
import '../view/components/onboarding_content.dart';
import 'package:due_tocoffee/routes/screen_export.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // Navigate to EntryPoint after fade-in completes
    Future.delayed(const Duration(seconds: 20), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EntryPoint()),
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
      backgroundColor: const Color(0xFF7B3F00), // brown close to red
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(
                  "assets/images/onboardingLogo.png", // make sure you put your logo here
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              // Elegant Text
              const Text(
                "Due To Coffee",
                style: TextStyle(
                  fontFamily: 'Helvetica', // Modern and clean
                  fontSize: 36,
                  fontWeight:
                      FontWeight.w700, // Semi-bold for better readability
                  color: Colors.white, // Correct syntax for color
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      // Proper class name with capital 'S'
                      blurRadius: 4.0,
                      color: Colors.black26, // Correct syntax for color
                      offset: Offset(
                          1.0, 1.0), // Proper class name with capital 'O'
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "2026",
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 20,
                  fontWeight: FontWeight.w300, // Light weight for contrast
                  color: Colors.white70, // Correct syntax for color
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

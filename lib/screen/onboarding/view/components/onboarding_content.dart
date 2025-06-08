import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final String title, description, image;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 90), // Add spacing
        Image.asset(
          image,
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height:
              MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          fit: BoxFit.cover, // Ensures the image fills the space
        ),
        SizedBox(height: 20),
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(description, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

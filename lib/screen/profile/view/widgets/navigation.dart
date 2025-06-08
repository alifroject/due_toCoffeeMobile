import 'package:flutter/material.dart';

class NavigationDots extends StatelessWidget {
  const NavigationDots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 33),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationDot(color: Color(0xFF253028)),
          NavigationDot(color: Color(0xFF253028)),
          NavigationDot(color: Color(0xFF5DD47F), isActive: true),
        ],
      ),
    );
  }
}

class NavigationDot extends StatelessWidget {
  final Color color;
  final bool isActive;

  const NavigationDot({
    Key? key,
    required this.color,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 49,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Color(0x9E1E963C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
    );
  }
}
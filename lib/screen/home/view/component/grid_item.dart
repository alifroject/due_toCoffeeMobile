import 'package:flutter/material.dart';

class SixButtons extends StatelessWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;

  const SixButtons({
    Key? key,
    required this.isSmallScreen,
    required this.isMediumScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton("Button 1", Icons.home, () => print("Button 1 tapped")),
            _buildButton("Button 2", Icons.star, () => print("Button 2 tapped")),
            _buildButton("Button 3", Icons.favorite, () => print("Button 3 tapped")),
          ],
        ),
        SizedBox(height: isSmallScreen ? 15 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton("Button 4", Icons.settings, () => print("Button 4 tapped")),
            _buildButton("Button 5", Icons.person, () => print("Button 5 tapped")),
            _buildButton("Button 6", Icons.shopping_cart, () => print("Button 6 tapped")),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 71),
            height: isSmallScreen ? 55 : (isMediumScreen ? 65 : 78),
            decoration: BoxDecoration(
              color: Color(0xFFA9E0DB),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0x9E1F8D3B),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

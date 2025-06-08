import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final IconData? icon;
  final Gradient? gradient;

  const ActionButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    this.icon,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      height: 38,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(2, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Color(0xFF1E1E1E),
              size: 24,
            ),
            SizedBox(width: 10),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Imprima',
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
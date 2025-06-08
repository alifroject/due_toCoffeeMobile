import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;

  const ScanButton({
    Key? key,
    required this.isSmallScreen,
    required this.isMediumScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA9E0DB),
            Color(0xCCA9E0DB),
          ],
        ),
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(32.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 30 : 40,
              vertical: isSmallScreen ? 12 : 15,
            ),
            child: Text(
              'Scan Trash',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'InriaSans',
                fontSize: isSmallScreen
                    ? 24
                    : (isMediumScreen ? 30 : 36),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
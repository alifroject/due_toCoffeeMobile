import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 141,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD9D9D9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(3, 4),
                ),
              ],
            ),
          ),
          Container(
            width: 113,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFA09F9F),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(3, 4),
                ),
              ],
            ),
          ),
          Icon(
            Icons.person,
            size: 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '10:20',
            style: TextStyle(
              fontFamily: 'Inria Sans',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              CustomPaint(
                size: Size(32, 28),
                painter: WifiIconPainter(),
              ),
              SizedBox(width: 10),
              CustomPaint(
                size: Size(29, 27),
                painter: BatteryIconPainter(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WifiIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.8,
        size.height * 0.52,
      );

    canvas.drawPath(path, paint);

    // Draw middle arc
    final middlePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.67)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.65,
        size.height * 0.67,
      );

    canvas.drawPath(middlePath, paint);

    // Draw dot
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.83),
      size.width * 0.05,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BatteryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width * 0.1, size.height * 0.75)
      ..close();

    canvas.drawPath(path, paint);

    // Battery tip
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
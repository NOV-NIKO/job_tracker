import 'package:flutter/material.dart';
import 'package:job_tracker/theme/app_theme.dart';

class GeometricBackground extends StatelessWidget {
  final Widget child;

  const GeometricBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景渐变
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
        ),
        // 几何网格
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: GeometricGridPainter(),
          ),
        ),
        // 内容
        child,
      ],
    );
  }
}

class GeometricGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.05)
      ..strokeWidth = 0.5;

    // 绘制水平线
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 绘制垂直线
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制对角线
    for (double i = -size.width; i < size.width; i += 80) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.width, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.width * 2; i += 80) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

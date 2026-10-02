import 'package:flutter/material.dart';

import '../../core/app_identity.dart';
import '../../core/app_theme.dart';

class MagaBrandMark extends StatelessWidget {
  const MagaBrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 58.0;
    return Semantics(
      label: AppIdentity.brandMarkLabel,
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MagaBrandMarkPainter(
          primary: MashiColors.primary,
          accent: MashiColors.warm,
        ),
      ),
    );
  }
}

class _MagaBrandMarkPainter extends CustomPainter {
  const _MagaBrandMarkPainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.42;
    final ringPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.075;
    canvas.drawCircle(center, radius, ringPaint);

    final path = Path()
      ..moveTo(center.dx, center.dy - radius * 0.72)
      ..lineTo(center.dx + radius * 0.33, center.dy + radius * 0.22)
      ..lineTo(center.dx, center.dy + radius * 0.08)
      ..lineTo(center.dx - radius * 0.33, center.dy + radius * 0.22)
      ..close();
    canvas.drawPath(path, Paint()..color = primary);
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 0.48),
      size.shortestSide * 0.07,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _MagaBrandMarkPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.accent != accent;
  }
}

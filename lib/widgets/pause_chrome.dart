import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ShelfCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? tint;

  const ShelfCard({
    super.key,
    required this.child,
    this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A2A68).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: tint ?? Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: const EdgeInsets.all(12), child: child)
            : InkWell(
                onTap: onTap,
                child: Padding(padding: const EdgeInsets.all(12), child: child),
              ),
      ),
    );
  }
}

class PauseButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;

  const PauseButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.add, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        style: FilledButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ProductArt extends StatelessWidget {
  final int tone;
  final double size;

  const ProductArt({super.key, required this.tone, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: CustomPaint(painter: _ProductPainter(tone % 4)),
    );
  }
}

class _ProductPainter extends CustomPainter {
  final int tone;

  _ProductPainter(this.tone);

  @override
  void paint(Canvas canvas, Size size) {
    switch (tone) {
      case 0:
        _pack(canvas, size);
        break;
      case 1:
        _phones(canvas, size);
        break;
      case 2:
        _lamp(canvas, size);
        break;
      default:
        _shoe(canvas, size);
    }
  }

  void _pack(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.22, size.width * 0.44,
          size.height * 0.52),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFF7F1E8));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.40, size.height * 0.30, size.width * 0.20,
            size.height * 0.16),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFE7D3B4),
    );
    final strap = Paint()
      ..color = const Color(0xFFC4A27A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.18, size.width * 0.22,
          size.height * 0.36),
      1.2,
      2.2,
      false,
      strap,
    );
  }

  void _phones(Canvas canvas, Size size) {
    final band = Paint()
      ..color = const Color(0xFFD9D0EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.18, size.width * 0.56,
          size.height * 0.50),
      3.4,
      2.6,
      false,
      band,
    );
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.58),
        size.width * 0.10, Paint()..color = const Color(0xFFE7E0F4));
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.58),
        size.width * 0.10, Paint()..color = const Color(0xFFE7E0F4));
  }

  void _lamp(Canvas canvas, Size size) {
    final shade = Path()
      ..moveTo(size.width * 0.28, size.height * 0.42)
      ..lineTo(size.width * 0.38, size.height * 0.22)
      ..lineTo(size.width * 0.70, size.height * 0.22)
      ..lineTo(size.width * 0.80, size.height * 0.42)
      ..close();
    canvas.drawPath(shade, Paint()..color = const Color(0xFFFFF6DE));
    canvas.drawLine(
      Offset(size.width * 0.54, size.height * 0.42),
      Offset(size.width * 0.54, size.height * 0.68),
      Paint()
        ..color = const Color(0xFFD9C48A)
        ..strokeWidth = 3,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width * 0.54, size.height * 0.74),
          width: size.width * 0.28,
          height: size.height * 0.08),
      Paint()..color = const Color(0xFFE7D7A4),
    );
  }

  void _shoe(Canvas canvas, Size size) {
    final shoe = Path()
      ..moveTo(size.width * 0.22, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.32,
          size.width * 0.48, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.28,
          size.width * 0.82, size.height * 0.52)
      ..lineTo(size.width * 0.84, size.height * 0.66)
      ..lineTo(size.width * 0.20, size.height * 0.66)
      ..close();
    canvas.drawPath(shoe, Paint()..color = const Color(0xFFE7E0F6));
  }

  @override
  bool shouldRepaint(covariant _ProductPainter oldDelegate) =>
      oldDelegate.tone != tone;
}

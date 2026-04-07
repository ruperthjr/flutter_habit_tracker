import 'dart:math' as math;
import 'package:flutter/material.dart';

class NatureScene extends StatefulWidget {
  const NatureScene({super.key});
  @override
  State<NatureScene> createState() => _NatureSceneState();
}

class _NatureSceneState extends State<NatureScene> with TickerProviderStateMixin {
  late final AnimationController _birdCtrl;
  late final AnimationController _cloudCtrl;
  late final Animation<double>   _birdAnim;
  late final Animation<double>   _cloudAnim;

  @override
  void initState() {
    super.initState();
    _birdCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _cloudCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _birdAnim  = CurvedAnimation(parent: _birdCtrl,  curve: Curves.linear);
    _cloudAnim = CurvedAnimation(parent: _cloudCtrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _birdCtrl.dispose();
    _cloudCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_birdAnim, _cloudAnim]),
      builder: (_, __) => CustomPaint(
        painter: _NaturePainter(
          birdT:  _birdAnim.value,
          cloudT: _cloudAnim.value,
        ),
        size: const Size(double.infinity, 140),
      ),
    );
  }
}

class _NaturePainter extends CustomPainter {
  _NaturePainter({required this.birdT, required this.cloudT});
  final double birdT, cloudT;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // ── Sky gradient ────────────────────────────────────────────────────────
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A1628), Color(0xFF1A2D45), Color(0xFF243650)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // ── Stars ────────────────────────────────────────────────────────────────
    final starPaint = Paint()..color = Colors.white.withOpacity(0.6);
    final rng = math.Random(42);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * w, rng.nextDouble() * (h * 0.6)),
        rng.nextDouble() * 1.2 + 0.3,
        starPaint,
      );
    }

    // ── Clouds ───────────────────────────────────────────────────────────────
    _drawCloud(canvas, Offset((w * cloudT + w * 0.2) % (w + 80) - 40, h * 0.15), 36, 0.25);
    _drawCloud(canvas, Offset((w * cloudT + w * 0.6) % (w + 80) - 40, h * 0.25), 24, 0.18);

    // ── Far hills ────────────────────────────────────────────────────────────
    _drawHill(canvas, w, h, 0.6, const Color(0xFF0D2035), 0.5);

    // ── Mid hills ────────────────────────────────────────────────────────────
    _drawHill(canvas, w, h, 0.75, const Color(0xFF112A3C), 0.35);

    // ── Trees (back) ─────────────────────────────────────────────────────────
    _drawTree(canvas, Offset(w * 0.08, h * 0.7), 28, const Color(0xFF1A4D3E));
    _drawTree(canvas, Offset(w * 0.15, h * 0.72), 22, const Color(0xFF1A4D3E));
    _drawTree(canvas, Offset(w * 0.82, h * 0.70), 30, const Color(0xFF1A4D3E));
    _drawTree(canvas, Offset(w * 0.90, h * 0.72), 20, const Color(0xFF1A4D3E));

    // ── Front ground ─────────────────────────────────────────────────────────
    _drawHill(canvas, w, h, 0.88, const Color(0xFF0E1F2E), 0.0);

    // ── Trees (front) ────────────────────────────────────────────────────────
    _drawTree(canvas, Offset(w * 0.03, h * 0.84), 34, const Color(0xFF1E5C44));
    _drawTree(canvas, Offset(w * 0.75, h * 0.82), 36, const Color(0xFF1E5C44));
    _drawTree(canvas, Offset(w * 0.88, h * 0.85), 28, const Color(0xFF1E5C44));

    // ── Glowing tree (accent) ────────────────────────────────────────────────
    _drawGlowTree(canvas, Offset(w * 0.55, h * 0.75), 40,
        const Color(0xFF3DD68C), const Color(0xFF1E5C44));

    // ── Birds ────────────────────────────────────────────────────────────────
    final bx = (w * birdT * 1.3 - w * 0.1) % (w + 80);
    _drawBird(canvas, Offset(bx, h * 0.28), 7, const Color(0xFF8BC4E8));
    _drawBird(canvas, Offset(bx - 22, h * 0.22), 5, const Color(0xFF8BC4E8));
    _drawBird(canvas, Offset(bx - 40, h * 0.30), 5.5, const Color(0xFF8BC4E8));
  }

  void _drawHill(Canvas c, double w, double h, double yFrac, Color color, double controlY) {
    final p = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * yFrac)
      ..quadraticBezierTo(w * 0.5, h * (yFrac - 0.18), w, h * yFrac)
      ..lineTo(w, h)
      ..close();
    c.drawPath(p, Paint()..color = color);
  }

  void _drawTree(Canvas c, Offset base, double size, Color color) {
    final trunk = Paint()..color = const Color(0xFF2D1B0E);
    c.drawRect(Rect.fromCenter(center: Offset(base.dx, base.dy + size * 0.3),
        width: size * 0.22, height: size * 0.5), trunk);
    final leaves = Paint()..color = color;
    final path = Path()
      ..moveTo(base.dx, base.dy - size * 0.6)
      ..lineTo(base.dx + size * 0.5, base.dy + size * 0.15)
      ..lineTo(base.dx - size * 0.5, base.dy + size * 0.15)
      ..close();
    c.drawPath(path, leaves);
    final path2 = Path()
      ..moveTo(base.dx, base.dy - size * 0.9)
      ..lineTo(base.dx + size * 0.38, base.dy - size * 0.2)
      ..lineTo(base.dx - size * 0.38, base.dy - size * 0.2)
      ..close();
    c.drawPath(path2, leaves);
  }

  void _drawGlowTree(Canvas c, Offset base, double sz, Color glow, Color dark) {
    final gp = Paint()
      ..color = glow.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    c.drawCircle(Offset(base.dx, base.dy - sz * 0.3), sz * 0.7, gp);
    _drawTree(c, base, sz, dark);
    // Glowing fruit dots
    final dp = Paint()..color = glow;
    c.drawCircle(Offset(base.dx - sz * 0.18, base.dy - sz * 0.5), 3, dp);
    c.drawCircle(Offset(base.dx + sz * 0.12, base.dy - sz * 0.65), 3, dp);
    c.drawCircle(Offset(base.dx + sz * 0.28, base.dy - sz * 0.35), 2.5, dp);
  }

  void _drawCloud(Canvas c, Offset center, double sz, double opacity) {
    final p = Paint()..color = Colors.white.withOpacity(opacity);
    for (final off in [
      Offset.zero, Offset(-sz * 0.4, sz * 0.1),
      Offset(sz * 0.4, sz * 0.1), Offset(-sz * 0.15, -sz * 0.2),
      Offset(sz * 0.15, -sz * 0.2),
    ]) {
      c.drawCircle(center + off, sz * 0.35, p);
    }
  }

  void _drawBird(Canvas c, Offset pos, double sz, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(pos.dx - sz, pos.dy)
      ..quadraticBezierTo(pos.dx - sz * 0.5, pos.dy - sz * 0.6, pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + sz * 0.5, pos.dy - sz * 0.6, pos.dx + sz, pos.dy);
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_NaturePainter old) =>
      old.birdT != birdT || old.cloudT != cloudT;
}
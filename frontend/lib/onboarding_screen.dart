import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8E3),
      body: SafeArea(
        child: Column(
          children: [
            // Main content - takes up available space
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container with dashed border
                      _DashedBorderContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 24),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Vyral logo text
                            Text(
                              'vyral',
                              style: TextStyle(
                                fontSize: 58,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2A2A2A),
                                letterSpacing: -2,
                                fontFamily: 'Georgia',
                                height: 1.1,
                              ),
                            ),
                            // Diamond sparkle top right
                            Positioned(
                              top: -8,
                              right: -12,
                              child: _DiamondIcon(size: 18),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Tagline with dashed border
                      _DashedBorderContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text(
                          'POST IT. PIN IT. OWN IT.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3A3A3A),
                            letterSpacing: 2.5,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Description with dashed border
                      _DashedBorderContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          'The space to curate your world, share\nyour vision, and own your influence.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: const Color(0xFF3A3A3A),
                            fontFamily: 'Georgia',
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom section with divider line
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2E8E3),
                border: Border(
                  top: BorderSide(color: Color(0xFFD9C9C0), width: 0.8),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Column(
                children: [
                  // Create account button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB87878),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Log in text
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diamond/sparkle icon widget
class _DiamondIcon extends StatelessWidget {
  final double size;
  const _DiamondIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DiamondPainter(),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB87878)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw a 4-pointed star/diamond
    path.moveTo(cx, 0);
    path.lineTo(cx + size.width * 0.15, cy - size.height * 0.15);
    path.lineTo(size.width, cy);
    path.lineTo(cx + size.width * 0.15, cy + size.height * 0.15);
    path.lineTo(cx, size.height);
    path.lineTo(cx - size.width * 0.15, cy + size.height * 0.15);
    path.lineTo(0, cy);
    path.lineTo(cx - size.width * 0.15, cy - size.height * 0.15);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Container with dashed border
class _DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _DashedBorderContainer({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0C4D8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = Radius.circular(4);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    _drawDashedRRect(canvas, paint, rrect, dashWidth, dashSpace);
  }

  void _drawDashedRRect(Canvas canvas, Paint paint, RRect rrect,
      double dashWidth, double dashSpace) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(
          metric.extractPath(start.toDouble(), end.toDouble()),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class DashboardBackground extends StatelessWidget {
  final Widget child;

  const DashboardBackground({super.key, required this.child});

  Widget flower({
    required double top,
    required double left,
    double? right,
    double? bottom,
    required double size,
    double opacity = 1.0,
    double rotation = 0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            "assets/images/rhododendron_bg.png",
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
             Color(0xFF1565C0),
              Color(0xFF1976D2),
              Color(0xFF64B5F6),
              Color(0xFFF5FAFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            /// Soft decorative circles
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade200.withOpacity(.25),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade200.withOpacity(.12),
                ),
              ),
            ),

            /// Rhododendron 1
            flower(top: 20, left: 20, size: 80, opacity: .30, rotation: -.4),

            /// Rhododendron 2
            flower(top: 80, left: 290, size: 55, opacity: .24, rotation: .3),

            /// Rhododendron 3
            flower(top: 170, left: 130, size: 70, opacity: .28, rotation: -.2),

            /// Rhododendron 4
            flower(top: 250, left: 20, size: 90, opacity: .22, rotation: .5),

            /// Rhododendron 5
            flower(top: 300, left: 280, size: 60, opacity: .30, rotation: -.5),

            /// Rhododendron 6
            flower(top: 420, left: 120, size: 75, opacity: .20, rotation: .4),

            /// Rhododendron 7
            flower(top: 500, left: 15, size: 65, opacity: .26, rotation: -.3),

            /// Rhododendron 8
            flower(top: 560, left: 270, size: 85, opacity: .24, rotation: .6),

            /// Rhododendron 9
            flower(top: 660, left: 90, size: 55, opacity: .30, rotation: -.5),

            /// Rhododendron 10
            flower(top: 730, left: 250, size: 95, opacity: .22, rotation: .2),

            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

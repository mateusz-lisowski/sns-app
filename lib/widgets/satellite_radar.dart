import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/location_controller.dart';
import 'package:sns_app/models/satellite.dart';

class SatelliteRadar extends StatefulWidget {
  const SatelliteRadar({super.key});

  @override
  State<SatelliteRadar> createState() => _SatelliteRadarState();
}

class _SatelliteRadarState extends State<SatelliteRadar> {
  final LocationController _locationController = Get.find();
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _heading;

  @override
  void initState() {
    super.initState();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _heading = event.heading;
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomPaint(
          size: const Size(300, 300),
          painter: RadarPainter(satellites: _locationController.satellites.value, heading: _heading),
        ));
  }
}

class RadarPainter extends CustomPainter {
  final List<Satellite> satellites;
  final double? heading;

  RadarPainter({required this.satellites, this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final backgroundPaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke;

    // Draw concentric circles for elevation
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, backgroundPaint);
    }

    // Draw lines for azimuth
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final p1 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      final p2 = Offset(center.dx - radius * cos(angle), center.dy - radius * sin(angle));
      canvas.drawLine(p1, p2, backgroundPaint);
    }

    // Draw North arrow
    final northArrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    final northArrowPath = Path();
    northArrowPath.moveTo(center.dx, center.dy - radius - 10);
    northArrowPath.lineTo(center.dx - 5, center.dy - radius);
    northArrowPath.lineTo(center.dx + 5, center.dy - radius);
    northArrowPath.close();
    canvas.drawPath(northArrowPath, northArrowPaint);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - radius - 30));

    // Draw satellites
    final satellitePaint = Paint()..color = Colors.yellow;
    for (final satellite in satellites) {
      final angle = (satellite.azimuth - 90) * pi / 180;
      final distance = (90 - satellite.elevation) / 90 * radius;
      final satellitePosition = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );
      canvas.drawCircle(satellitePosition, 5, satellitePaint);
    }

    // Draw compass in the center
    if (heading != null) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-heading! * pi / 180);

      // North needle (red)
      final northPaint = Paint()..color = Colors.red..style = PaintingStyle.fill;
      final northPath = Path();
      northPath.moveTo(0, -20);
      northPath.lineTo(-7, 0);
      northPath.lineTo(7, 0);
      northPath.close();
      canvas.drawPath(northPath, northPaint);

      // South needle (blue)
      final southPaint = Paint()..color = Colors.blue..style = PaintingStyle.fill;
      final southPath = Path();
      southPath.moveTo(0, 20);
      southPath.lineTo(-7, 0);
      southPath.lineTo(7, 0);
      southPath.close();
      canvas.drawPath(southPath, southPaint);

      canvas.drawCircle(Offset.zero, 25,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.satellites != satellites || oldDelegate.heading != heading;
  }
}

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

  void _drawText(Canvas canvas, Offset position, String text, {Color color = Colors.white, double fontSize = 12}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2));
  }

  Color _getSatelliteColor(double signalStrength) {
    if (signalStrength > 30) {
      return Colors.green;
    } else if (signalStrength > 20) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

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

    // Draw elevation labels
    for (int i = 1; i <= 2; i++) {
      final r = radius * i / 3;
      final angle = -pi / 4; // Top-right quadrant
      final position = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      _drawText(canvas, position, '${90 - i * 30}°', color: Colors.green.withOpacity(0.8));
    }

    // Draw lines for azimuth
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final p1 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      final p2 = Offset(center.dx - radius * cos(angle), center.dy - radius * sin(angle));
      canvas.drawLine(p1, p2, backgroundPaint);
    }

    // Draw cardinal direction labels
    _drawText(canvas, Offset(center.dx, center.dy - radius - 20), 'N', color: Colors.red, fontSize: 16);
    _drawText(canvas, Offset(center.dx + radius + 20, center.dy), 'E', color: Colors.white, fontSize: 16);
    _drawText(canvas, Offset(center.dx, center.dy + radius + 20), 'S', color: Colors.white, fontSize: 16);
    _drawText(canvas, Offset(center.dx - radius - 20, center.dy), 'W', color: Colors.white, fontSize: 16);

    // Draw satellites
    for (final satellite in satellites) {
      final satellitePaint = Paint()..color = _getSatelliteColor(satellite.signalStrength);
      final angle = (satellite.azimuth - 90) * pi / 180;
      final distance = (90 - satellite.elevation) / 90 * radius;
      final satellitePosition = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );
      canvas.drawCircle(satellitePosition, 5, satellitePaint);

      final prnTextPainter = TextPainter(
        text: TextSpan(
          text: '${satellite.prn}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      prnTextPainter.layout();
      prnTextPainter.paint(canvas, Offset(satellitePosition.dx - prnTextPainter.width / 2, satellitePosition.dy + 5));
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

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PathPainter extends CustomPainter {
  final List<Position> path;

  PathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final completePath = Path();
    final startPoint = _scalePosition(path.first, size);
    completePath.moveTo(startPoint.dx, startPoint.dy);

    for (var i = 1; i < path.length; i++) {
      final point = _scalePosition(path[i], size);
      completePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(completePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Offset _scalePosition(Position position, Size size) {
    // Simple scaling for now, will need a proper projection for a real map
    double minLat = path.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = path.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLon = path.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLon = path.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    double latRange = maxLat - minLat;
    double lonRange = maxLon - minLon;

    double scaleX = size.width / (lonRange == 0 ? 1 : lonRange);
    double scaleY = size.height / (latRange == 0 ? 1 : latRange);

    double x = (position.longitude - minLon) * scaleX;
    double y = (maxLat - position.latitude) * scaleY;

    return Offset(x, y);
  }
}

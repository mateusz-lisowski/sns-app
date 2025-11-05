import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class PathPainter extends CustomPainter {
  final List<Position> path;
  final double padding = 50.0;

  PathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    final bounds = _getBounds(path);
    _drawGrid(canvas, size, bounds);
    _drawPath(canvas, size, bounds);
  }

  void _drawGrid(Canvas canvas, Size size, LatLngBounds bounds) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final numLines = 5;
    final latStep = (bounds.maxLat - bounds.minLat) / numLines;
    final lonStep = (bounds.maxLon - bounds.minLon) / numLines;

    for (int i = 0; i <= numLines; i++) {
      // Latitude lines and labels
      final lat = bounds.minLat + i * latStep;
      final y = _scaleLat(lat, size, bounds);
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
      _drawText(canvas, lat.toStringAsFixed(4), Offset(padding - 45, y));

      // Longitude lines and labels
      final lon = bounds.minLon + i * lonStep;
      final x = _scaleLon(lon, size, bounds);
      canvas.drawLine(Offset(x, padding), Offset(x, size.height - padding), gridPaint);
      _drawText(canvas, lon.toStringAsFixed(4), Offset(x, padding - 20), vertical: true);
    }
  }

  void _drawPath(Canvas canvas, Size size, LatLngBounds bounds) {
    final pathPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final completePath = Path();
    final startPoint = _scalePosition(path.first, size, bounds);
    completePath.moveTo(startPoint.dx, startPoint.dy);

    for (var i = 1; i < path.length; i++) {
      final point = _scalePosition(path[i], size, bounds);
      completePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(completePath, pathPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, {bool vertical = false}) {
    final textSpan = TextSpan(text: text, style: TextStyle(color: Colors.grey, fontSize: 10));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    if (vertical) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(-math.pi / 4);
      textPainter.paint(canvas, Offset(0, 0));
      canvas.restore();
    } else {
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Offset _scalePosition(Position position, Size size, LatLngBounds bounds) {
    return Offset(
      _scaleLon(position.longitude, size, bounds),
      _scaleLat(position.latitude, size, bounds),
    );
  }

  double _scaleLon(double lon, Size size, LatLngBounds bounds) {
    final lonRange = bounds.maxLon - bounds.minLon;
    final scaleX = (size.width - 2 * padding) / (lonRange == 0 ? 1 : lonRange);
    return padding + (lon - bounds.minLon) * scaleX;
  }

  double _scaleLat(double lat, Size size, LatLngBounds bounds) {
    final latRange = bounds.maxLat - bounds.minLat;
    final scaleY = (size.height - 2 * padding) / (latRange == 0 ? 1 : latRange);
    return padding + (bounds.maxLat - lat) * scaleY;
  }

  LatLngBounds _getBounds(List<Position> path) {
    double minLat = path.first.latitude;
    double maxLat = path.first.latitude;
    double minLon = path.first.longitude;
    double maxLon = path.first.longitude;

    for (var position in path) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLon) minLon = position.longitude;
      if (position.longitude > maxLon) maxLon = position.longitude;
    }

    return LatLngBounds(minLat, maxLat, minLon, maxLon);
  }
}

class LatLngBounds {
  final double minLat, maxLat, minLon, maxLon;
  LatLngBounds(this.minLat, this.maxLat, this.minLon, this.maxLon);
}

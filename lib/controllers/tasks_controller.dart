
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gpx/gpx.dart';
import 'package:vector_math/vector_math_64.dart';

class TasksController extends GetxController {
  // ... (previous task variables)

  // Task 5: Map Matching
  final RxList<Wpt> task5TrackPoints = <Wpt>[].obs;
  final Rx<Wpt?> task5NearestPoint = Rx<Wpt?>(null);
  final RxDouble task5DistanceToNearestPoint = 0.0.obs;

  // ... (other controller properties)
  // Task 0: Angle Calculation
  final Rx<Vector2?> point1 = Rx<Vector2?>(null);
  final Rx<Vector2?> point2 = Rx<Vector2?>(null);
  final Rx<double?> angle = Rx<double?>(null);
  final Rx<double?> azimuth = Rx<double?>(null);
  final Rx<bool> isWithinThreshold = Rx<bool>(false);

  final TextEditingController lat1Controller = TextEditingController();
  final TextEditingController lon1Controller = TextEditingController();
  final TextEditingController lat2Controller = TextEditingController();
  final TextEditingController lon2Controller = TextEditingController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final double _angleThreshold = 0.1;

  // Task 1: Parallel Line
  final Rx<Vector2?> task1Point1 = Rx<Vector2?>(null);
  final Rx<Vector2?> task1Point2 = Rx<Vector2?>(null);
  final Rx<Vector2?> task1Point3 = Rx<Vector2?>(null);
  final Rx<String?> parallelLineDirection = Rx<String?>(null);

  final TextEditingController task1Lat1Controller = TextEditingController();
  final TextEditingController task1Lon1Controller = TextEditingController();
  final TextEditingController task1Lat2Controller = TextEditingController();
  final TextEditingController task1Lon2Controller = TextEditingController();
  final TextEditingController task1Lat3Controller = TextEditingController();
  final TextEditingController task1Lon3Controller = TextEditingController();

  // Task 2: Points on a Line
  final Rx<Vector2?> task2Point1 = Rx<Vector2?>(null);
  final Rx<Vector2?> task2Point2 = Rx<Vector2?>(null);
  final Rx<double?> distanceFromLine = Rx<double?>(null);

  final TextEditingController task2Lat1Controller = TextEditingController();
  final TextEditingController task2Lon1Controller = TextEditingController();
  final TextEditingController task2Lat2Controller = TextEditingController();
  final TextEditingController task2Lon2Controller = TextEditingController();

  // Task 3: Distance from Line (Azimuth/Distance)
  final Rx<Vector2?> task3Point1 = Rx<Vector2?>(null);
  final Rx<Vector2?> task3Point2 = Rx<Vector2?>(null); // Calculated point
  final Rx<double?> task3DistanceFromLine = Rx<double?>(null);

  final TextEditingController task3Lat1Controller = TextEditingController();
  final TextEditingController task3Lon1Controller = TextEditingController();
  final TextEditingController task3AzimuthController = TextEditingController();
  final TextEditingController task3DistanceController = TextEditingController();

    // Task 4
  final RxBool task4IsTracking = false.obs;
  final RxList<Vector2> task4RoutePoints = <Vector2>[].obs;
  final RxDouble task4CurrentDistance = 0.0.obs;


  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    _listenToLocationChanges();

    // Add all listeners
    lat1Controller.addListener(setPoint1FromUI);
    lon1Controller.addListener(setPoint1FromUI);
    lat2Controller.addListener(setPoint2FromUI);
    lon2Controller.addListener(setPoint2FromUI);

    task1Lat1Controller.addListener(setTask1Point1FromUI);
    task1Lon1Controller.addListener(setTask1Point1FromUI);
    task1Lat2Controller.addListener(setTask1Point2FromUI);
    task1Lon2Controller.addListener(setTask1Point2FromUI);
    task1Lat3Controller.addListener(setTask1Point3FromUI);
    task1Lon3Controller.addListener(setTask1Point3FromUI);

    task2Lat1Controller.addListener(setTask2Point1FromUI);
    task2Lon1Controller.addListener(setTask2Point1FromUI);
    task2Lat2Controller.addListener(setTask2Point2FromUI);
    task2Lon2Controller.addListener(setTask2Point2FromUI);

    task3Lat1Controller.addListener(setTask3Point1FromUI);
    task3Lon1Controller.addListener(setTask3Point1FromUI);
    task3AzimuthController.addListener(_calculateTask3Point2);
    task3DistanceController.addListener(_calculateTask3Point2);
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    // Dispose all controllers
    lat1Controller.dispose();
    lon1Controller.dispose();
    lat2Controller.dispose();
    lon2Controller.dispose();
    task1Lat1Controller.dispose();
    task1Lon1Controller.dispose();
    task1Lat2Controller.dispose();
    task1Lon2Controller.dispose();
    task1Lat3Controller.dispose();
    task1Lon3Controller.dispose();
    task2Lat1Controller.dispose();
    task2Lon1Controller.dispose();
    task2Lat2Controller.dispose();
    task2Lon2Controller.dispose();
    task3Lat1Controller.dispose();
    task3Lon1Controller.dispose();
    task3AzimuthController.dispose();
    task3DistanceController.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _listenToLocationChanges() {
    _positionStream = Geolocator.getPositionStream().listen((position) {
      final currentPosition = Vector2(position.latitude, position.longitude);

      if (point1.value != null && point2.value != null) {
        _calculateAngleAndAzimuth(point1.value!, point2.value!, currentPosition);
      }
      if (task1Point1.value != null &&
          task1Point2.value != null &&
          task1Point3.value != null) {
        _calculateParallelLineDirection(task1Point1.value!, task1Point2.value!,
            task1Point3.value!, currentPosition);
      }
      if (task2Point1.value != null && task2Point2.value != null) {
        _calculateDistanceToLine(
            'task2', task2Point1.value!, task2Point2.value!, currentPosition);
      }
      if (task3Point1.value != null && task3Point2.value != null) {
        _calculateDistanceToLine(
            'task3', task3Point1.value!, task3Point2.value!, currentPosition);
      }
      if (task4IsTracking.value) {
        _updateCurrentRoute(currentPosition);
      }
      if (task5TrackPoints.isNotEmpty) {
        _findNearestPointOnTrack(currentPosition);
      }
    });
  }

  // ... (previous task methods)
  // --- Task 0 ---
  void setPoint1FromUI() {
    final lat = double.tryParse(lat1Controller.text);
    final lon = double.tryParse(lon1Controller.text);
    if (lat != null && lon != null) point1.value = Vector2(lat, lon);
  }

  void setPoint2FromUI() {
    final lat = double.tryParse(lat2Controller.text);
    final lon = double.tryParse(lon2Controller.text);
    if (lat != null && lon != null) point2.value = Vector2(lat, lon);
  }

  Future<void> setPoint1FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      point1.value = Vector2(pos.latitude, pos.longitude);
      lat1Controller.text = pos.latitude.toString();
      lon1Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  Future<void> setPoint2FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      point2.value = Vector2(pos.latitude, pos.longitude);
      lat2Controller.text = pos.latitude.toString();
      lon2Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  // --- Task 1 ---
  void setTask1Point1FromUI() {
    final lat = double.tryParse(task1Lat1Controller.text);
    final lon = double.tryParse(task1Lon1Controller.text);
    if (lat != null && lon != null) task1Point1.value = Vector2(lat, lon);
  }

  void setTask1Point2FromUI() {
    final lat = double.tryParse(task1Lat2Controller.text);
    final lon = double.tryParse(task1Lon2Controller.text);
    if (lat != null && lon != null) task1Point2.value = Vector2(lat, lon);
  }

  void setTask1Point3FromUI() {
    final lat = double.tryParse(task1Lat3Controller.text);
    final lon = double.tryParse(task1Lon3Controller.text);
    if (lat != null && lon != null) task1Point3.value = Vector2(lat, lon);
  }

  Future<void> setTask1Point1FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task1Point1.value = Vector2(pos.latitude, pos.longitude);
      task1Lat1Controller.text = pos.latitude.toString();
      task1Lon1Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  Future<void> setTask1Point2FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task1Point2.value = Vector2(pos.latitude, pos.longitude);
      task1Lat2Controller.text = pos.latitude.toString();
      task1Lon2Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  Future<void> setTask1Point3FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task1Point3.value = Vector2(pos.latitude, pos.longitude);
      task1Lat3Controller.text = pos.latitude.toString();
      task1Lon3Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  // --- Task 2 ---
  void setTask2Point1FromUI() {
    final lat = double.tryParse(task2Lat1Controller.text);
    final lon = double.tryParse(task2Lon1Controller.text);
    if (lat != null && lon != null) task2Point1.value = Vector2(lat, lon);
  }

  void setTask2Point2FromUI() {
    final lat = double.tryParse(task2Lat2Controller.text);
    final lon = double.tryParse(task2Lon2Controller.text);
    if (lat != null && lon != null) task2Point2.value = Vector2(lat, lon);
  }

  Future<void> setTask2Point1FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task2Point1.value = Vector2(pos.latitude, pos.longitude);
      task2Lat1Controller.text = pos.latitude.toString();
      task2Lon1Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  Future<void> setTask2Point2FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task2Point2.value = Vector2(pos.latitude, pos.longitude);
      task2Lat2Controller.text = pos.latitude.toString();
      task2Lon2Controller.text = pos.longitude.toString();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  // --- Task 3 ---
  void setTask3Point1FromUI() {
    final lat = double.tryParse(task3Lat1Controller.text);
    final lon = double.tryParse(task3Lon1Controller.text);
    if (lat != null && lon != null) {
      task3Point1.value = Vector2(lat, lon);
      _calculateTask3Point2();
    }
  }

  Future<void> setTask3Point1FromCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      task3Point1.value = Vector2(pos.latitude, pos.longitude);
      task3Lat1Controller.text = pos.latitude.toString();
      task3Lon1Controller.text = pos.longitude.toString();
      _calculateTask3Point2();
    } catch (e) {
      Get.snackbar('Error', 'Could not get current location');
    }
  }

  void _calculateTask3Point2() {
    final p1 = task3Point1.value;
    final azimuth = double.tryParse(task3AzimuthController.text);
    final distance = double.tryParse(task3DistanceController.text);

    if (p1 == null || azimuth == null || distance == null) {
      task3Point2.value = null;
      return;
    }

    const earthRadius = 6371e3;
    final lat1Rad = radians(p1.x);
    final lon1Rad = radians(p1.y);
    final azimuthRad = radians(azimuth);

    final lat2Rad = math.asin(math.sin(lat1Rad) * math.cos(distance / earthRadius) +
        math.cos(lat1Rad) * math.sin(distance / earthRadius) * math.cos(azimuthRad));
    final lon2Rad = lon1Rad +
        math.atan2(
            math.sin(azimuthRad) * math.sin(distance / earthRadius) * math.cos(lat1Rad),
            math.cos(distance / earthRadius) - math.sin(lat1Rad) * math.sin(lat2Rad));

    task3Point2.value = Vector2(degrees(lat2Rad), degrees(lon2Rad));
  }

  // --- Task 4 ---
  void toggleTask4Tracking() {
    task4IsTracking.value = !task4IsTracking.value;
    if (task4IsTracking.value) {
      task4RoutePoints.clear();
      task4CurrentDistance.value = 0.0;
    }
  }

  void _updateCurrentRoute(Vector2 currentPosition) {
    if (task4RoutePoints.isNotEmpty) {
      final lastPoint = task4RoutePoints.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.x,
        lastPoint.y,
        currentPosition.x,
        currentPosition.y,
      );
      task4CurrentDistance.value += distance;
    }
    task4RoutePoints.add(currentPosition);
  }

  // --- Task 5 Methods ---
  Future<void> loadGpxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Use 'any' to avoid platform issues
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.path.toLowerCase().endsWith('.gpx')) {
        final gpxString = await file.readAsString();
        final gpx = GpxReader().fromString(gpxString);

        List<Wpt> trackPoints = [];
        if (gpx.trks.isNotEmpty) {
          for (var trk in gpx.trks) {
            for (var seg in trk.trksegs) {
              trackPoints.addAll(seg.trkpts);
            }
          }
        } else if (gpx.rtes.isNotEmpty) {
          for (var rte in gpx.rtes) {
            trackPoints.addAll(rte.rtepts);
          }
        } else {
          trackPoints.addAll(gpx.wpts);
        }

        if (trackPoints.isEmpty) {
          Get.snackbar('Error',
              'No track points, routes, or waypoints found in the GPX file.');
          return;
        }

        task5TrackPoints.value = trackPoints;
        Get.snackbar('Success', 'GPX file loaded with ${trackPoints.length} points.');
      } else {
        Get.snackbar('Error', 'Invalid file type. Please select a GPX file.');
      }
    } else {
      // User canceled the picker
      Get.snackbar('Info', 'File picking canceled.');
    }
  }

  void _findNearestPointOnTrack(Vector2 currentPosition) {
    Wpt? nearestPoint;
    double minDistance = double.infinity;

    if (task5TrackPoints.isEmpty) {
      return;
    }

    for (int i = 0; i < task5TrackPoints.length - 1; i++) {
      final p1 = task5TrackPoints[i];
      final p2 = task5TrackPoints[i + 1];

      // Ensure points are valid
      if (p1.lat == null || p1.lon == null || p2.lat == null || p2.lon == null) continue;

      final p1Vec = Vector2(p1.lat!, p1.lon!);
      final p2Vec = Vector2(p2.lat!, p2.lon!);

      final closestPointOnSegment =
          _getClosestPointOnSegment(p1Vec, p2Vec, currentPosition);

      final distance = Geolocator.distanceBetween(
        currentPosition.x,
        currentPosition.y,
        closestPointOnSegment.x,
        closestPointOnSegment.y,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = Wpt(
          lat: closestPointOnSegment.x,
          lon: closestPointOnSegment.y,
        );
      }
    }

    // Also check the last point
    final lastPoint = task5TrackPoints.last;
    if (lastPoint.lat != null && lastPoint.lon != null) {
      final distance = Geolocator.distanceBetween(
          currentPosition.x, currentPosition.y, lastPoint.lat!, lastPoint.lon!);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = lastPoint;
      }
    }

    task5NearestPoint.value = nearestPoint;
    task5DistanceToNearestPoint.value = minDistance;
  }

  Vector2 _getClosestPointOnSegment(Vector2 p1, Vector2 p2, Vector2 a) {
    final p1a = a - p1;
    final p1p2 = p2 - p1;
    final dot = p1a.dot(p1p2);
    final lenSq = p1p2.length2;

    if (lenSq == 0) {
      return p1;
    }

    final t = (dot / lenSq).clamp(0.0, 1.0);
    return p1 + p1p2 * t;
  }

  // --- Generic Calculation Methods ---
  void _calculateAngleAndAzimuth(
      Vector2 p1, Vector2 p2, Vector2 currentPosition) {
    final v1 = p1 - currentPosition;
    final v2 = p2 - currentPosition;
    angle.value = degrees(v1.angleTo(v2));

    if ((angle.value?.abs() ?? double.infinity) < _angleThreshold) {
      if (!isWithinThreshold.value) {
        isWithinThreshold.value = true;
        _playSound();
      }
    } else {
      isWithinThreshold.value = false;
    }

    final north = Vector2(0, 1);
    final p1p2 = p2 - p1;
    azimuth.value = degrees(north.angleTo(p1p2));
  }

  void _calculateParallelLineDirection(
      Vector2 p1, Vector2 p2, Vector2 p3, Vector2 currentPosition) {
    final baseVector = p2 - p1;
    final perpendicular = Vector2(-baseVector.y, baseVector.x);
    final userVector = currentPosition - p3;
    final dotProduct = userVector.dot(perpendicular);
    const distanceThreshold = 0.0001;

    if (dotProduct.abs() < distanceThreshold) {
      parallelLineDirection.value = 'On the line';
    } else if (dotProduct > 0) {
      parallelLineDirection.value = 'Move Left';
    } else {
      parallelLineDirection.value = 'Move Right';
    }
  }

  void _calculateDistanceToLine(
      String task, Vector2 p1, Vector2 p2, Vector2 currentPosition) {
    final metersPerDegreeLat = 111320.0;
    final metersPerDegreeLon = 111320.0 * math.cos(radians(currentPosition.x));

    final p1m = Vector2(
        (p1.y - currentPosition.y) * metersPerDegreeLon,
        (p1.x - currentPosition.x) * metersPerDegreeLat);
    final p2m = Vector2(
        (p2.y - currentPosition.y) * metersPerDegreeLon,
        (p2.x - currentPosition.x) * metersPerDegreeLat);

    final p1p2m = p2m - p1m;
    final area = p1m.cross(p2m);
    final length = p1p2m.length;
    double distance;

    if (length == 0) {
      distance = p1m.length;
    } else {
      distance = area.abs() / length;
    }

    if (task == 'task2') {
      distanceFromLine.value = distance;
    } else if (task == 'task3') {
      task3DistanceFromLine.value = distance;
    }
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }
}


import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sns_app/models/satellite.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLocationEnabled = false.obs;
  StreamSubscription<Position>? _positionStream;
  final Rx<List<Satellite>> satellites = Rx<List<Satellite>>([]);
  StreamSubscription? _satelliteStream;
  final RxList<Position> path = <Position>[].obs;

  static const _satelliteChannel = EventChannel('com.github.sindbad/satellite');

  void toggleLocationServices() {
    isLocationEnabled.value = !isLocationEnabled.value;
    if (isLocationEnabled.value) {
      _startLocationUpdates();
    } else {
      _stopLocationUpdates();
    }
  }

  Future<void> _startLocationUpdates() async {
    if (await Permission.location.request().isGranted) {
      path.clear();
      _positionStream = Geolocator.getPositionStream().listen((Position position) {
        currentPosition.value = position;
        path.add(position);
      });

      _satelliteStream = _satelliteChannel.receiveBroadcastStream().listen((dynamic data) {
        if (data is List) {
          satellites.value = data.map((item) {
            if (item is Map) {
              final prn = item['prn'];
              final name = item['name'];
              final signalStrength = item['signalStrength'];
              final azimuth = item['azimuth'];
              final elevation = item['elevation'];
              if (prn is int &&
                  name is String &&
                  signalStrength is double &&
                  azimuth is double &&
                  elevation is double) {
                return Satellite(
                  prn: prn,
                  name: name,
                  signalStrength: signalStrength,
                  azimuth: azimuth,
                  elevation: elevation,
                );
              }
            }
            return null;
          }).whereType<Satellite>().toList();
        }
      });
    }
  }

  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _satelliteStream?.cancel();
    currentPosition.value = null;
    satellites.value = [];
    path.clear();
  }
}

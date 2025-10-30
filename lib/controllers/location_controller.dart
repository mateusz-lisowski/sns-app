import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLocationEnabled = false.obs;
  StreamSubscription<Position>? _positionStream;

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
      _positionStream = Geolocator.getPositionStream().listen((Position position) {
        currentPosition.value = position;
      });
    }
  }

  void _stopLocationUpdates() {
    _positionStream?.cancel();
    currentPosition.value = null;
  }
}

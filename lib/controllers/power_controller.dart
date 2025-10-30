import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PowerController extends GetxController {
  static const batteryChannel = EventChannel('com.github.sindbad/battery');
  final List<int> currentMeasurements = <int>[];
  final RxDouble averageCurrentFlow = 0.0.obs;
  StreamSubscription? _batteryStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _startListeningToBatteryStream();
  }

  void _startListeningToBatteryStream() {
    _batteryStreamSubscription = batteryChannel
        .receiveBroadcastStream()
        .listen((dynamic data) {
      if (data is int) {
        if (currentMeasurements.length >= 10) {
          currentMeasurements.removeAt(0);
        }
        currentMeasurements.add(data);
        _calculateAverage();
      }
    }, onError: (dynamic error) {
      // Handle error
    });
  }

  void _calculateAverage() {
    if (currentMeasurements.isEmpty) {
      averageCurrentFlow.value = 0.0;
    } else {
      averageCurrentFlow.value = currentMeasurements.reduce((a, b) => a + b) / currentMeasurements.length;
    }
  }

  @override
  void onClose() {
    _batteryStreamSubscription?.cancel();
    super.onClose();
  }
}

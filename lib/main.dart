import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const SnsApp());
}

class PowerController extends GetxController {
  static const batteryChannel = EventChannel('com.github.sindbad/battery');
  final RxList<int> currentMeasurements = <int>[].obs;
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

class SnsApp extends StatelessWidget {
  const SnsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers once, here at the root.
    Get.put(LocationController());
    Get.put(PowerController());

    return GetMaterialApp(
      title: 'SNS Demo App',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    // Find the existing controllers.
    final LocationController lc = Get.find();
    final PowerController pc = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text("SNS Demo App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
                  () => SwitchListTile(
                title: const Text("Enable Location"),
                value: lc.isLocationEnabled.value,
                onChanged: (bool value) {
                  lc.toggleLocationServices();
                },
              ),
            ),
            Obx(() {
              if (lc.isLocationEnabled.value && lc.currentPosition.value != null) {
                final position = lc.currentPosition.value!;
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Text('Latitude: ${position.latitude}'),
                    Text('Longitude: ${position.longitude}'),
                  ],
                );
              } else {
                return const SizedBox.shrink(); // Return an empty widget if location is off
              }
            }),
            const SizedBox(height: 20),
            Obx(() => Text("Average current flow: ${pc.averageCurrentFlow.value.toStringAsFixed(2)} µA")),
            const SizedBox(height: 10),
            Obx(() => Text("Raw measurements: [${pc.currentMeasurements.join(', ')}]")),
          ],
        ),
      ),
    );
  }
}

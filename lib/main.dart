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
      title: 'Device Power & Location',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
      appBar: AppBar(
        title: const Text("Device Power & Location"),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("Location"),
                      trailing: Obx(
                        () => Switch(
                          value: lc.isLocationEnabled.value,
                          onChanged: (bool value) {
                            lc.toggleLocationServices();
                          },
                        ),
                      ),
                    ),
                    Obx(() {
                      if (lc.isLocationEnabled.value) {
                        if (lc.currentPosition.value != null) {
                          final position = lc.currentPosition.value!;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Latitude",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position.latitude.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Longitude",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position.longitude.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.power),
                      title: Text("Power Consumption"),
                    ),
                    Obx(() => Text(
                          "${pc.averageCurrentFlow.value.toStringAsFixed(2)} µA",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.greenAccent,
                              ),
                        )),
                    const Text("Average Current Flow"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

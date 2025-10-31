import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/screens/path_tracking_screen.dart';
import 'package:sns_app/screens/satellite_radar_screen.dart';

import 'controllers/location_controller.dart';
import 'controllers/power_controller.dart';
import 'screens/device_power_and_location_screen.dart';

void main() {
  runApp(const SnsApp());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("SNS App"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.insights),
                title: const Text('Lab 1 (Device Power & Location)'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => const DevicePowerAndLocationScreen());
                },
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.satellite_alt),
                title: const Text('Satellite Radar'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => const SatelliteRadarScreen());
                },
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.moving_outlined),
                title: const Text('Path Tracking'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => PathTrackingScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

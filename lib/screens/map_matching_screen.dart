
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class MapMatchingScreen extends StatelessWidget {
  const MapMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Matching'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: controller.loadGpxFile,
              child: const Text('Load GPX File'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nearest Point on Track',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final nearestPoint = controller.task5NearestPoint.value;
              if (nearestPoint == null) {
                return const Text('--', style: TextStyle(fontSize: 16));
              }
              return Text(
                'Lat: ${nearestPoint.lat?.toStringAsFixed(6)}, Lon: ${nearestPoint.lon?.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Distance to Nearest Point (meters)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.task5DistanceToNearestPoint.value
                      .toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24, color: Colors.green),
                )),
          ],
        ),
      ),
    );
  }
}

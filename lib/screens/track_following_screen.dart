
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class TrackFollowingScreen extends StatelessWidget {
  const TrackFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Following & Distance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => ElevatedButton(
                  onPressed: controller.toggleTask4Tracking,
                  child: Text(controller.task4IsTracking.value
                      ? 'Stop Tracking'
                      : 'Start Current Route'),
                )),
            const SizedBox(height: 24),
            const Text(
              'Current Route Distance (meters)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.task4CurrentDistance.value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24, color: Colors.green),
                )),
          ],
        ),
      ),
    );
  }
}
